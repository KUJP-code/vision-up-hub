import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import test from 'node:test';
import assert from 'node:assert/strict';

const source = readFileSync(new URL('../../app/javascript/controllers/screen_mirroring_test_controller.js', import.meta.url), 'utf8')
  .replace('import { Controller } from "@hotwired/stimulus";', 'class Controller {}')
  .replace('export default class', 'globalThis.Mockup = class');
function fixture(document = {}, globals = {}) {
  const context = vm.createContext({ document, ...globals });
  vm.runInContext(source, context);
  const controller = new context.Mockup();
  controller.lessonDialogTarget = { hidden: false };
  controller.speechStatusTarget = { textContent: '' };
  controller.lessonWeekTarget = { textContent: '' };
  controller.speedButtonTargets = [];
  controller.videoActive = false;
  return controller;
}

test('starting the lesson opens the splash without requesting fullscreen', () => {
  const controller = fixture({ activeElement: {}, body: { children: [] }, documentElement: { requestFullscreen() { throw Error('Lesson should not request fullscreen'); } } });
  controller.element = { children: [] };
  controller.lessonDialogTarget = { hidden: true };
  controller.stageTarget = { hidden: true };
  controller.menuTarget = { querySelector() { return { focus() {} }; } };
  controller.start();
  assert.equal(controller.lessonDialogTarget.hidden, false);
  assert.equal(controller.stageTarget.hidden, false);
  assert.equal(controller.videoActive, false);
});

test('2.7.9.1 playback order: container fullscreen, fixed viewport, play, then remote', async () => {
  const calls = [];
  let finishPlay;
  const controller = fixture();
  controller.stageTarget = {
    hidden: false,
    setAttribute() {},
    getBoundingClientRect() {},
    requestFullscreen() { calls.push('fullscreen'); assert.equal(this, controller.stageTarget); return Promise.resolve(); },
    classList: { add(...names) { calls.push(['fixed', ...names]); } }
  };
  controller.playerTarget = {
    dataset: { kind: 'basic' }, readyState: 1,
    getAttribute() { return 'basic.m3u8'; },
    get currentTime() { return 0; },
    set currentTime(_value) { throw Error('A prepared video must not seek on Play'); },
    get playbackRate() { return 1; },
    set playbackRate(_value) { throw Error('A prepared video must not reset its speed'); },
    pause() { throw Error('A prepared video must not pause before Play'); },
    load() { throw Error('A prepared video must not reload before Play'); },
    play() { calls.push('play'); return new Promise(resolve => { finishPlay = resolve; }); }
  };
  for (const target of ['speed','videoTitle','error','remote','menu','splash']) controller[`${target}Target`] = { hidden: false };
  controller.playButtonTarget = { focus() { throw Error('Starting playback must not force focus onto the remote'); } };
  controller.showRemote = () => {};
  controller.playbackGeneration = 0;
  controller.closePicker = restoreFocus => assert.equal(restoreFocus, false);
  controller.closeMenus = controller.cancelSpeech = controller.setChapters = controller.updateRemote = controller.resetGuide = () => {};
  controller.playVideo({ currentTarget: { dataset: { src: 'basic.m3u8', kind: 'basic', title: 'Lesson' } } });
  controller.playVideo({ currentTarget: { dataset: { src: 'basic.m3u8', kind: 'basic', title: 'Lesson' } } });
  assert.deepEqual(calls, ['fullscreen', ['fixed', 'fixed', 'inset-0', 'z-[60]', 'rounded-none'], 'play']);
  assert.equal(controller.remoteTarget.hidden, true);
  assert.equal(controller.menuTarget.hidden, false);
  finishPlay();
  await new Promise(resolve => setImmediate(resolve));
  assert.equal(controller.menuTarget.hidden, true);
  assert.equal(controller.splashTarget.hidden, true);
  assert.equal(controller.remoteTarget.hidden, false);
});

test('2.7.9.1 prefixed fullscreen fallback requests the video container', () => {
  const controller = fixture();
  let requested = false;
  controller.stageTarget = { webkitRequestFullscreen() { requested = true; assert.equal(this, controller.stageTarget); } };
  controller.enterVideoFullscreen();
  assert.equal(requested, true);
});

test('phrase taps play local media and stop the previous clip', () => {
  const controller = fixture();
  const played = [];
  controller.phraseAudioTargets = ['Hello!', 'See you!'].map(phrase => ({
    dataset: { phrase }, readyState: 1, currentTime: 2, paused: false,
    pause() { this.paused = true; }, play() { played.push(phrase); return Promise.resolve(); }
  }));
  controller.speak({ currentTarget: { dataset: { phrase: 'See you!' } } });
  assert.deepEqual(played, ['See you!']);
  assert.ok(controller.phraseAudioTargets.every(audio => audio.paused && audio.currentTime === 0));
});

test('a new source is assigned once without an explicit media reload', () => {
  const controller = fixture();
  let assignments = 0;
  let source = 'basic.m3u8';
  controller.playerTarget = {
    dataset: {},
    get src() { return source; },
    set src(value) { source = value; assignments++; },
    getAttribute() { return source; },
    load() { throw Error('Assigning src already starts media loading'); }
  };
  controller.loadVideoSource({ src: 'story.m3u8', kind: 'story' });
  assert.equal(controller.playerTarget.src, 'story.m3u8');
  assert.equal(assignments, 1);
  controller.loadVideoSource({ src: 'story.m3u8', kind: 'story' });
  assert.equal(assignments, 1);
});

test('switching videos also switches the caption file without reloading the video', () => {
  const controller = fixture();
  let caption = 'basic.en.vtt';
  controller.hasCaptionFallbackTarget = true;
  controller.captionFallbackTarget = {
    getAttribute() { return caption; },
    set src(value) { caption = value; }
  };
  controller.playerTarget = {
    dataset: {}, src: 'basic.m3u8', getAttribute() { return this.src; },
    load() { throw Error('Caption changes must not explicitly reload the video'); }
  };
  controller.loadVideoSource({ src: 'activity.m3u8', kind: 'activity', captionSrc: 'activity.en.vtt' });
  assert.equal(caption, 'activity.en.vtt');
  assert.equal(controller.playerTarget.src, 'activity.m3u8');
});

test('cards outside the lesson can prepare a source while playing videos ignore preparation', () => {
  const controller = fixture();
  const prepared = [];
  controller.lessonDialogTarget.hidden = true;
  controller.loadVideoSource = source => prepared.push(source.src);
  const event = { target: { closest: () => ({ dataset: { src: 'activity.m3u8', kind: 'activity' } }) } };
  controller.prepareVideo(event);
  assert.deepEqual(prepared, ['activity.m3u8']);
  controller.videoActive = true;
  controller.prepareVideo(event);
  assert.deepEqual(prepared, ['activity.m3u8']);
});

test('direct card launch does not focus Basic English and replace the prepared source', () => {
  const controller = fixture({ activeElement: {}, body: { children: [] } });
  controller.element = { children: [] };
  controller.lessonDialogTarget.hidden = true;
  controller.stageTarget = { hidden: true };
  controller.menuTarget = { querySelector() { throw Error('A direct launch must not focus another video'); } };
  let opened;
  controller.playVideo = event => { opened = event.currentTarget.dataset.src; };
  controller.launchVideo({ currentTarget: { dataset: { src: 'activity.m3u8', kind: 'activity' } } });
  assert.equal(opened, 'activity.m3u8');
  assert.equal(controller.videoOpenedFromMenu, true);
  assert.equal(controller.stageTarget.hidden, false);
  controller.videoActive = true;
  controller.playVideo = () => { throw Error('An active direct launch must not open a second time'); };
  controller.launchVideo({ currentTarget: { dataset: { src: 'activity.m3u8', kind: 'activity' } } });
  assert.equal(controller.videoOpenedFromMenu, true);
});

test('focus changes while closing a picker cannot replace the source being opened', () => {
  const controller = fixture();
  controller.stageTarget = { setAttribute() {} };
  controller.loadVideoSource = () => { throw Error('Focus must not replace the selected source'); };
  controller.closePicker = () => {
    controller.prepareVideo({ target: { closest: () => ({ dataset: { src: 'basic.m3u8', kind: 'basic' } }) } });
    throw Error('Checked focus restoration');
  };
  assert.throws(() => controller.playVideo({ currentTarget: { dataset: { src: 'activity.m3u8' } } }), /Checked focus restoration/);
});

test('cancelling idle phrase audio does not pause or seek its media elements', () => {
  const controller = fixture();
  controller.phraseAudioTargets = [{
    paused: true, readyState: 1,
    get currentTime() { return 0; },
    set currentTime(_value) { throw Error('Idle audio should not seek'); },
    pause() { throw Error('Idle audio should not pause'); }
  }];
  controller.cancelSpeech();
});

function subtitleFixture(tracks) {
  const controller = fixture();
  // TextTrackList is array-like; older Safari versions need not make it iterable.
  controller.playerTarget = { textTracks: Object.assign({ length: tracks.length }, tracks) };
  controller.subtitleButtonTarget = { setAttribute(name, value) { this[name] = value; } };
  controller.showRemote = () => {};
  return controller;
}

test('CC reflects native captions while leaving metadata tracks alone', () => {
  const tracks = [
    { kind: 'metadata', language: '', label: '', mode: 'hidden' },
    { kind: 'captions', language: 'en-x-autogen', label: 'English (auto-generated)', mode: 'showing' }
  ];
  const controller = subtitleFixture(tracks);
  controller.syncSubtitles();
  assert.equal(controller.subtitleButtonTarget.hidden, false);
  assert.equal(controller.subtitleButtonTarget['aria-pressed'], 'true');
  assert.equal(controller.subtitleButtonTarget['aria-label'], '字幕をオフにする');
  controller.toggleSubtitles();
  assert.equal(tracks[1].mode, 'disabled');
  assert.equal(tracks[0].mode, 'hidden');
  assert.equal(controller.subtitleButtonTarget['aria-pressed'], 'false');
});

test('one CC click enables available captions and the next turns them off', () => {
  const tracks = [{ kind: 'subtitles', language: 'en', label: 'English', mode: 'disabled' }];
  const controller = subtitleFixture(tracks);
  controller.syncSubtitles();
  controller.toggleSubtitles();
  assert.equal(tracks[0].mode, 'showing');
  controller.toggleSubtitles();
  assert.equal(tracks[0].mode, 'disabled');
  controller.toggleSubtitles();
  assert.equal(tracks[0].mode, 'showing');
});

test('CC restores the currently selected native language after toggling off and on', () => {
  const tracks = [
    { kind: 'subtitles', language: 'en', label: 'English', mode: 'disabled' },
    { kind: 'subtitles', language: 'ja', label: 'Japanese', mode: 'showing' }
  ];
  const controller = subtitleFixture(tracks);
  controller.toggleSubtitles();
  assert.deepEqual(tracks.map(track => track.mode), ['disabled', 'disabled']);
  controller.toggleSubtitles();
  assert.deepEqual(tracks.map(track => track.mode), ['disabled', 'showing']);
});

test('CC uses whichever language is available on the next video and preserves Off', () => {
  const controller = subtitleFixture([{ kind: 'subtitles', language: 'ja', label: 'Japanese', mode: 'disabled' }]);
  controller.toggleSubtitles();
  const english = { kind: 'captions', language: 'en', label: 'English', mode: 'disabled' };
  controller.playerTarget.textTracks = [english];
  controller.syncSubtitles(true);
  assert.equal(english.mode, 'showing');
  controller.toggleSubtitles();
  english.mode = 'showing';
  controller.syncSubtitles(true);
  assert.equal(english.mode, 'disabled');
});

test('CC hides without available captions and reappears when a track arrives', () => {
  const controller = subtitleFixture([{ kind: 'metadata', language: '', label: '', mode: 'hidden' }]);
  controller.syncSubtitles();
  assert.equal(controller.subtitleButtonTarget.hidden, true);
  controller.toggleSubtitles();
  const english = { kind: 'subtitles', language: 'en', label: 'English', mode: 'disabled' };
  controller.playerTarget.textTracks = [english];
  controller.syncSubtitles(true);
  assert.equal(controller.subtitleButtonTarget.hidden, false);
  assert.equal(controller.subtitleButtonTarget['aria-pressed'], 'false');
  controller.toggleSubtitles();
  assert.equal(english.mode, 'showing');
  controller.playerTarget.textTracks = [];
  controller.syncSubtitles(true);
  assert.equal(controller.subtitleButtonTarget.hidden, true);
});

test('native HLS subtitles replace an equivalent fallback without duplicate captions', () => {
  const fallback = { kind: 'subtitles', language: 'en', label: 'English (auto-generated)', mode: 'showing' };
  const controller = subtitleFixture([fallback]);
  controller.hasCaptionFallbackTarget = true;
  controller.captionFallbackTarget = { track: fallback };
  controller.syncSubtitles();
  const native = { kind: 'subtitles', language: 'en-x-autogen', label: 'English (auto-generated)', mode: 'hidden', cues: [{ text: 'Hello!' }] };
  controller.playerTarget.textTracks = [fallback, native];
  controller.syncSubtitles(true);
  assert.equal(native.mode, 'showing');
  assert.equal(fallback.mode, 'disabled');
  controller.toggleSubtitles();
  assert.equal(native.mode, 'disabled');
  assert.equal(fallback.mode, 'disabled');
});

test('CC ignores an empty native HLS track and enables the caption-file fallback', () => {
  const fallback = { kind: 'subtitles', language: 'en', label: 'English (auto-generated)', mode: 'disabled' };
  const native = { kind: 'subtitles', language: 'en-x-autogen', label: 'English (auto-generated)', mode: 'disabled', cues: null };
  const controller = subtitleFixture([fallback, native]);
  controller.hasCaptionFallbackTarget = true;
  controller.captionFallbackTarget = { track: fallback };
  controller.toggleSubtitles();
  assert.equal(fallback.mode, 'showing');
  assert.equal(native.mode, 'disabled');
  controller.toggleSubtitles();
  assert.equal(fallback.mode, 'disabled');
});

test('caption selection follows AirPlay routing and returns to the local fallback', () => {
  const fallback = { kind: 'subtitles', language: 'en', label: 'English (auto-generated)', mode: 'disabled' };
  const native = { kind: 'subtitles', language: 'en-x-autogen', label: 'English (auto-generated)', mode: 'disabled', cues: null };
  const controller = subtitleFixture([fallback, native]);
  controller.hasCaptionFallbackTarget = true;
  controller.captionFallbackTarget = { track: fallback };
  controller.toggleSubtitles();
  controller.playerTarget.webkitCurrentPlaybackTargetIsWireless = true;
  controller.syncSubtitles(true);
  assert.equal(native.mode, 'showing');
  assert.equal(fallback.mode, 'disabled');
  controller.playerTarget.webkitCurrentPlaybackTargetIsWireless = false;
  controller.syncSubtitles(true);
  assert.equal(fallback.mode, 'showing');
  assert.equal(native.mode, 'disabled');
});

test('captions clear the remote within the letterboxed picture and restore native positions for AirPlay', () => {
  const cue = { text: 'Hello, everyone.', line: 'auto', snapToLines: true, lineAlign: 'start' };
  const authored = { line: 10, snapToLines: false, lineAlign: 'start' };
  const controller = subtitleFixture([{ kind: 'subtitles', mode: 'showing', cues: [cue, authored] }]);
  controller.videoActive = true;
  Object.assign(controller.playerTarget, {
    videoWidth: 1600, videoHeight: 900,
    getBoundingClientRect: () => ({ top: 0, width: 800, height: 600 })
  });
  let remoteTop = 480;
  controller.remoteTarget = { hidden: false, getBoundingClientRect: () => ({ top: remoteTop }) };
  controller.stageTarget = { classList: { contains: () => false } };
  controller.positionSubtitles();
  assert.equal(cue.line, (480 - 75 - 16) / 450 * 100 - 12);
  assert.equal(cue.snapToLines, false);
  assert.equal(cue.lineAlign, 'start');
  assert.equal(authored.line, 10);
  remoteTop = 300; // Opening the guide increases the remote height.
  controller.positionSubtitles();
  assert.equal(cue.line, (300 - 75 - 16) / 450 * 100 - 12);
  controller.playerTarget.webkitCurrentPlaybackTargetIsWireless = true;
  controller.positionSubtitles();
  assert.deepEqual(cue, { text: 'Hello, everyone.', line: 'auto', snapToLines: true, lineAlign: 'start' });
  controller.playerTarget.webkitCurrentPlaybackTargetIsWireless = false;
  controller.positionSubtitles();
  controller.stageTarget.classList.contains = () => true;
  controller.positionSubtitles();
  assert.equal(cue.line, 'auto');
});

test('chapter stopping pauses once at a crossed boundary and allows resuming', () => {
  const controller = fixture();
  let pauses = 0;
  controller.pauseAtChapterEnd = true;
  controller.lastPlaybackTime = 89.9;
  controller.chapters = [{ time: 0, endTime: 90 }, { time: 90, endTime: 180 }];
  controller.playerTarget = {
    currentTime: 90.2, paused: false, seeking: false,
    pause() { this.paused = true; pauses++; }
  };
  controller.checkChapterEnd();
  assert.equal(controller.playerTarget.currentTime, 90);
  assert.equal(pauses, 1);
  controller.playerTarget.paused = false;
  controller.playerTarget.currentTime = 90.2;
  controller.checkChapterEnd();
  assert.equal(pauses, 1);
});

test('manual chapter jumps do not trigger chapter stopping', () => {
  const controller = fixture();
  controller.pauseAtChapterEnd = true;
  controller.lastPlaybackTime = 0;
  controller.chapters = [{ time: 0, endTime: 90 }, { time: 90, endTime: 180 }];
  controller.updateRemote = () => {};
  controller.playerTarget = {
    duration: 550, currentTime: 0, paused: false, seeking: false,
    pause() { throw Error('An explicit seek should not stop playback'); }
  };
  controller.seekTo(190);
  controller.checkChapterEnd();
  assert.equal(controller.playerTarget.currentTime, 190);
  controller.seekTo(900);
  assert.equal(controller.playerTarget.currentTime, 550);
  controller.seekTo(-5);
  assert.equal(controller.playerTarget.currentTime, 0);
});

test('timecodes retain frame precision and per-video chapter end times', () => {
  const controller = fixture();
  controller.contentValue = { fps: 24, lessons: {
    'activity-1': { chapters: [{ start: '00:01:41:22', end: '00:02:17:01', title: '貼る場所の確認', guide: 'Jotの場所を確認します。', pause_after: true }] },
    'activity-2': { chapters: [{ start: '00:02:22:16', end: '00:02:56:03', title: '色ぬり', guide: 'Color your name' }] }
  } };
  const craft = controller.lessonChapters('activity-1')[0];
  assert.equal(craft.time, 101 + 22 / 24);
  assert.equal(craft.endTime, 137 + 1 / 24);
  assert.equal(craft.pause_after, true);
  assert.match(controller.chapterLabel(craft), /1:41–2:17.*貼る場所の確認.*一時停止/);
  const coloring = controller.lessonChapters('activity-2')[0];
  assert.equal(coloring.time, 142 + 16 / 24);
  assert.equal(coloring.guide, 'Color your name');
});

test('marked activity pauses work with chapter stopping off and resume only once', () => {
  const controller = fixture();
  let pauses = 0;
  const end = 137 + 1 / 24;
  controller.pauseAtChapterEnd = false;
  controller.lastPlaybackTime = 136.9;
  controller.chapters = [
    { time: 101 + 22 / 24, endTime: end, pause_after: true },
    { time: 137 + 3 / 24, endTime: 167 }
  ];
  controller.playerTarget = {
    currentTime: 137.2, paused: false, seeking: false,
    pause() { this.paused = true; pauses++; }
  };
  controller.checkChapterEnd();
  assert.equal(controller.playerTarget.currentTime, end);
  assert.equal(pauses, 1);
  controller.playerTarget.paused = false;
  controller.playerTarget.currentTime = 137.2;
  controller.checkChapterEnd();
  assert.equal(pauses, 1);
  controller.playerTarget.currentTime = 168;
  controller.checkChapterEnd();
  assert.equal(pauses, 1);
});

function resumablePlaybackFixture() {
  const controller = fixture();
  controller.playbackGeneration = 0;
  controller.videoActive = true;
  controller.stageTarget = { hidden: false };
  controller.menuTarget = { hidden: false };
  controller.splashTarget = { hidden: false };
  controller.remoteTarget = { hidden: false };
  controller.errorTarget = { hidden: true };
  controller.playButtonTarget = { focus() {} };
  controller.showRemote = controller.updateRemote = () => {};
  controller.playerTarget = {
    currentTime: 0, duration: 200, paused: true, seeking: false,
    pause() { this.paused = true; },
    play() { this.paused = false; return Promise.resolve(); }
  };
  return controller;
}

for (const chapterStop of [false, true]) {
  test(`resuming just before an auto-pause skips it despite HLS rounding (chapter stop ${chapterStop})`, async () => {
    const controller = resumablePlaybackFixture();
    controller.pauseAtChapterEnd = chapterStop;
    controller.chapters = [
      { time: 0, endTime: 70, pause_after: !chapterStop },
      { time: 70, endTime: 100, pause_after: !chapterStop }
    ];
    controller.lastPlaybackTime = 69.9;
    controller.playerTarget.paused = false;
    controller.playerTarget.currentTime = 70.2;
    controller.checkChapterEnd();
    assert.equal(controller.playerTarget.paused, true);
    assert.equal(controller.playerTarget.currentTime, 70);

    // Model the HLS player landing a fraction of a second before the requested seek.
    controller.playerTarget.currentTime = 69.96;
    controller.togglePlayback();
    await Promise.resolve();
    controller.playerTarget.currentTime = 70.2;
    controller.checkChapterEnd();
    assert.equal(controller.playerTarget.paused, false);

    // A delayed update after buffering must not trigger the skipped point either.
    controller.playerTarget.currentTime = 76;
    controller.checkChapterEnd();
    assert.equal(controller.playerTarget.paused, false);
    controller.playerTarget.currentTime = 100.2;
    controller.checkChapterEnd();
    assert.equal(controller.playerTarget.paused, true);
    assert.equal(controller.playerTarget.currentTime, 100);
  });
}

test('play skips points within three video seconds and preserves later ones at different speeds', async () => {
  for (const rate of [0.5, 1.5]) {
    const controller = resumablePlaybackFixture();
    controller.pauseAtChapterEnd = true;
    controller.chapters = [{ endTime: 70 }, { endTime: 71 }];
    controller.playerTarget.playbackRate = rate;
    controller.playerTarget.currentTime = 67;
    controller.togglePlayback();
    await Promise.resolve();
    controller.playerTarget.currentTime = 70.1;
    controller.checkChapterEnd();
    assert.equal(controller.playerTarget.paused, false);
    controller.playerTarget.currentTime = 71.1;
    controller.checkChapterEnd();
    assert.equal(controller.playerTarget.paused, true);
  }
});

test('seeking back deliberately re-enables an earlier pause point', async () => {
  const controller = resumablePlaybackFixture();
  controller.pauseAtChapterEnd = true;
  controller.chapters = [{ endTime: 70 }];
  controller.playerTarget.currentTime = 70;
  controller.togglePlayback();
  await Promise.resolve();
  controller.seekTo(60);
  controller.playerTarget.currentTime = 70.2;
  controller.checkChapterEnd();
  assert.equal(controller.playerTarget.paused, true);
  assert.equal(controller.playerTarget.currentTime, 70);
});

test('a pending play promise cannot reveal the remote after leaving playback', async () => {
  const controller = fixture();
  let finishPlay;
  controller.playbackGeneration = 0;
  controller.videoActive = true;
  controller.stageTarget = { hidden: false };
  controller.playerTarget = { play() { return new Promise(resolve => { finishPlay = resolve; }); } };
  controller.remoteTarget = { hidden: true };
  controller.play();
  controller.playbackGeneration++;
  controller.videoActive = false;
  finishPlay();
  await new Promise(resolve => setImmediate(resolve));
  assert.equal(controller.remoteTarget.hidden, true);
});

test('thumbnail URLs are resolved from public, player, stream, and unlisted Vimeo links', () => {
  const controller = fixture({}, { URL });
  assert.equal(controller.vimeoPageUrl('https://vimeo.com/123'), 'https://vimeo.com/123');
  assert.equal(controller.vimeoPageUrl('https://player.vimeo.com/video/456?h=abc123'), 'https://vimeo.com/456/abc123');
  assert.equal(controller.vimeoPageUrl('https://player.vimeo.com/external/789.m3u8?s=stream-signature'), 'https://vimeo.com/789');
  assert.equal(controller.vimeoPageUrl('https://vimeo.com/123/privatehash'), 'https://vimeo.com/123/privatehash');
  assert.equal(controller.vimeoPageUrl('https://example.com/123'), null);
  assert.equal(controller.vimeoPageUrl('invalid URL'), null);
});

function thumbnailContainer(video) {
  const placeholder = { hidden: false };
  const image = {
    hidden: true,
    addEventListener(_event, listener) { this.loaded = listener; },
    set src(value) { this.url = value; this.loaded(); }
  };
  return {
    dataset: { video }, isConnected: true, image, placeholder,
    querySelector(selector) { return selector === 'img' ? image : placeholder; }
  };
}

test('duplicate cards share a thumbnail lookup and a different video gets its own thumbnail', async () => {
  const lookups = [];
  const controller = fixture({}, {
    URL,
    fetch: async endpoint => {
      lookups.push(endpoint.searchParams.get('url'));
      assert.equal(endpoint.searchParams.get('maxwidth'), '960');
      return { ok: true, json: async () => ({ thumbnail_url: `https://i.vimeocdn.com/${lookups.length}.jpg` }) };
    }
  });
  const first = thumbnailContainer('https://player.vimeo.com/external/123.m3u8?s=one');
  const duplicate = thumbnailContainer('https://vimeo.com/123');
  await Promise.all([controller.thumbnailTargetConnected(first), controller.thumbnailTargetConnected(duplicate)]);
  assert.deepEqual(lookups, ['https://vimeo.com/123']);
  assert.equal(first.image.url, duplicate.image.url);
  assert.equal(first.image.hidden, false);
  assert.equal(first.placeholder.hidden, true);
  const different = thumbnailContainer('https://vimeo.com/456');
  await controller.thumbnailTargetConnected(different);
  assert.deepEqual(lookups, ['https://vimeo.com/123', 'https://vimeo.com/456']);
  assert.notEqual(different.image.url, first.image.url);
});

test('unavailable thumbnail metadata leaves a usable placeholder', async () => {
  const controller = fixture({}, { URL, fetch: async () => { throw Error('offline'); } });
  const card = thumbnailContainer('https://vimeo.com/123');
  await controller.thumbnailTargetConnected(card);
  assert.equal(card.image.hidden, true);
  assert.equal(card.placeholder.hidden, false);
});

test('future-week previews start on the next calendar week and restore current content', () => {
  const controller = fixture();
  controller.sampleLessonDate = '2026-10-22';
  controller.dateTarget = { value: '2026-10-25' };
  controller.homeLessonTarget = { hidden: false };
  controller.homeUpcomingTarget = { hidden: true };
  controller.weekHeadingTarget = { textContent: '' };
  controller.upcomingWeekTarget = { textContent: '' };
  controller.updateWeek();
  assert.equal(controller.homeLessonTarget.hidden, false);
  controller.dateTarget.value = '2026-10-26';
  controller.updateWeek();
  assert.equal(controller.homeLessonTarget.hidden, true);
  assert.equal(controller.homeUpcomingTarget.hidden, false);
  assert.match(controller.upcomingWeekTarget.textContent, /第2週/);
  controller.dateTarget.value = '2026-11-02';
  controller.updateWeek();
  assert.match(controller.upcomingWeekTarget.textContent, /第3週/);
  controller.dateTarget.value = '2026-10-22';
  controller.updateWeek();
  assert.equal(controller.homeLessonTarget.hidden, false);
  assert.equal(controller.homeUpcomingTarget.hidden, true);
});
