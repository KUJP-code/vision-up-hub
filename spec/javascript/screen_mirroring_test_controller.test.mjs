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
  return controller;
}

test('starting the lesson opens the splash without requesting fullscreen', () => {
  const controller = fixture({ activeElement: {}, body: { children: [] }, documentElement: { requestFullscreen() { throw Error('Lesson should not request fullscreen'); } } });
  controller.element = { children: [] };
  controller.lessonDialogTarget = { hidden: true };
  controller.menuTarget = { querySelector() { return { focus() {} }; } };
  controller.start();
  assert.equal(controller.lessonDialogTarget.hidden, false);
});

test('2.7.9.1 playback order: container fullscreen, fixed viewport, play, then remote', async () => {
  const calls = [];
  let finishPlay;
  const controller = fixture();
  controller.stageTarget = {
    hidden: true,
    getBoundingClientRect() {},
    requestFullscreen() { calls.push('fullscreen'); assert.equal(this, controller.stageTarget); return Promise.resolve(); },
    classList: { add(...names) { calls.push(['fixed', ...names]); } }
  };
  controller.playerTarget = {
    dataset: { kind: 'basic' }, readyState: 1,
    pause() {}, play() { calls.push('play'); return new Promise(resolve => { finishPlay = resolve; }); }
  };
  for (const target of ['speed','videoTitle','error','remote','menu','splash']) controller[`${target}Target`] = { hidden: false };
  controller.playButtonTarget = { focus() {} };
  controller.showRemote = () => {};
  controller.playbackGeneration = 0;
  controller.closePicker = controller.closeMenus = controller.cancelSpeech = controller.setChapters = controller.updateRemote = controller.loadVideoSource = controller.resetGuide = () => {};
  controller.playVideo({ currentTarget: { dataset: { kind: 'basic', title: 'Lesson' } } });
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

test('preparing a different lesson reuses the single video and does not reload a matching source', () => {
  const controller = fixture();
  let loads = 0;
  controller.playerTarget = { src: 'basic.m3u8', dataset: {}, getAttribute() { return this.src; }, load() { loads++; } };
  controller.loadVideoSource({ src: 'story.m3u8', kind: 'story' });
  assert.equal(controller.playerTarget.src, 'story.m3u8');
  assert.equal(loads, 1);
  controller.loadVideoSource({ src: 'story.m3u8', kind: 'story' });
  assert.equal(loads, 1);
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
  controller.stageTarget = { hidden: false };
  controller.playerTarget = { play() { return new Promise(resolve => { finishPlay = resolve; }); } };
  controller.remoteTarget = { hidden: true };
  controller.play();
  controller.playbackGeneration++;
  controller.stageTarget.hidden = true;
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
