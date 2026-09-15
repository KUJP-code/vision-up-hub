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
  controller.fullscreenButtonTarget = { hidden: true };
  controller.fullscreenStatusTarget = { textContent: '' };
  controller.speechStatusTarget = { textContent: '' };
  return controller;
}

test('lesson fullscreen targets the document and reports rejection instead of silently succeeding', async () => {
  let requested = false;
  const document = { documentElement: { requestFullscreen() { requested = true; return Promise.reject(new Error('denied')); } } };
  const controller = fixture(document);
  controller.enterFullscreen();
  await new Promise(resolve => setImmediate(resolve));
  assert.equal(requested, true);
  assert.equal(controller.fullscreenButtonTarget.hidden, false);
  assert.notEqual(controller.fullscreenStatusTarget.textContent, '');
});

test('missing fullscreen support exposes the retry state', () => {
  const controller = fixture({ documentElement: {} });
  controller.enterFullscreen();
  assert.equal(controller.fullscreenButtonTarget.hidden, false);
});

test('2.7.9.1 playback order: container fullscreen, fixed viewport, play, then remote', async () => {
  const calls = [];
  let finishPlay;
  const controller = fixture();
  controller.stageTarget = {
    hidden: true,
    requestFullscreen() { calls.push('fullscreen'); assert.equal(this, controller.stageTarget); return Promise.resolve(); },
    classList: { add(...names) { calls.push(['fixed', ...names]); } }
  };
  controller.playerTargets = [{
    dataset: { kind: 'basic' }, readyState: 1,
    pause() {}, play() { calls.push('play'); return new Promise(resolve => { finishPlay = resolve; }); }
  }];
  for (const target of ['speed','videoTitle','error','remote','menu','splash']) controller[`${target}Target`] = { hidden: false };
  controller.playButtonTarget = { focus() {} };
  controller.playbackGeneration = 0;
  controller.closeMenus = controller.cancelSpeech = controller.setChapters = controller.updateRemote = () => {};
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
