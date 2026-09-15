import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import test from 'node:test';
import assert from 'node:assert/strict';

const source = readFileSync(new URL('../../app/javascript/controllers/screen_mirroring_test_controller.js', import.meta.url), 'utf8')
  .replace('import { Controller } from "@hotwired/stimulus";', 'class Controller {}')
  .replace('export default class', 'globalThis.Mockup = class');
function fixture(document = {}) {
  const context = vm.createContext({ document });
  vm.runInContext(source, context);
  const controller = new context.Mockup();
  controller.lessonDialogTarget = { hidden: false };
  controller.speechStatusTarget = { textContent: '' };
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
  controller.playbackGeneration = 0;
  controller.closeMenus = controller.cancelSpeech = controller.setChapters = controller.updateRemote = controller.loadVideoSource = controller.resetGuide = () => {};
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
