import { Controller } from "@hotwired/stimulus";

// This controller belongs exclusively to the admin-only lesson mockup.
export default class extends Controller {
  static targets = ["lessonDialog", "lessonScreen", "stage", "player", "menu", "remote", "playButton", "time", "error", "date", "resource", "resourceTitle", "videoTitle", "chapterTitle", "guide", "speed", "chapterPicker", "splash", "speechStatus", "phraseAudio", "fullscreenButton", "fullscreenStatus"];

  connect() {
    this.chapterSets = {
      basic: [
        [0, "はじめのあいさつ", "笑顔で手を振って、Hello! とあいさつしましょう。子どもたちが画面に注目できたら始めます。"],
        [90, "Hello! を言ってみよう", "動画のまねをして、みんなで Hello! と言いましょう。一時停止して、一人ずつ声をかけてみましょう。"],
        [180, "はじめまして", "Nice to meet you! を聞いて、先生といっしょに繰り返しましょう。ジェスチャーも添えてみましょう。"],
        [240, "お友だちと練習", "隣のお友だちと向かい合って、あいさつを交代で練習しましょう。返事を待つ時間をつくります。"],
        [420, "See you! でさようなら", "手を振りながら See you! と言ってみましょう。先生が先にお手本を見せます。"],
        [480, "今日のふりかえり", "３つのあいさつを、場面に合わせて言ってみましょう。できたらみんなで拍手をしましょう！"]
      ],
      story: [
        [0, "お話のはじまり", "絵を見て、どんなお話か想像してみましょう。登場人物を指さして、注目を集めます。"],
        [120, "だれが出てきたかな？", "ここまでに登場したキャラクターを確認しましょう。子どもたちが気づいたことを聞いてみます。"],
        [180, "次はどうなる？", "動画を一時停止し、次に何が起こるか予想してみましょう。短い言葉やジェスチャーで答えてもらいます。"],
        [300, "気持ちを考えよう", "登場人物はどんな気持ちかな？表情をまねして、みんなで考えてみましょう。"],
        [360, "お話を楽しもう", "お話の続きを見ましょう。最後に、好きだった場面を一つ教えてもらいます。"]
      ],
      activity: [
        [0, "準備しよう", "プリントと必要な道具がそろっているか確認しましょう。完成見本を見せてから始めます。"],
        [45, "先生のお手本", "動画を見ながら、最初の手順を先生が見せましょう。子どもたちの手元も確認します。"],
        [90, "いっしょにやってみよう", "動画を一時停止して、同じ手順をやってみましょう。困っている子には声をかけます。"],
        [120, "自分でチャレンジ", "続きを自分で進めてもらいましょう。色や形など、使える英語で声をかけてみましょう。"],
        [150, "できたものを見せよう", "作品やプリントを見せ合いましょう。一人ひとりのがんばりをほめて、片づけにつなげます。"]
      ]
    };
    this.setChapters("basic");
    this.events = new AbortController();
    const options = { signal: this.events.signal };
    this.playbackGeneration = 0;
    this.playerTargets.forEach(player => {
      ["play", "pause", "timeupdate", "loadedmetadata", "durationchange"].forEach(event => {
        player.addEventListener(event, () => { if (player === this.playerTarget) this.updateRemote(); }, options);
      });
      player.addEventListener("ended", () => { if (player === this.playerTarget) this.stop(); }, options);
      player.addEventListener("error", () => { if (player === this.playerTarget) this.showError(); }, options);
    });
    ["fullscreenchange", "webkitfullscreenchange"].forEach(event => {
      document.addEventListener(event, () => {
        this.fullscreenButtonTarget.hidden = !!(document.fullscreenElement || document.webkitFullscreenElement);
        if (this.lessonDialogTarget.hidden) this.exitFullscreen(true);
      }, options);
    });

    this.lessonScreenTarget.addEventListener("click", event => {
      const selected = event.target.closest("details");
      this.closeMenus(selected);
    }, options);
    this.lessonScreenTarget.addEventListener("keydown", event => {
      if (event.key === "Escape" && this.menuTarget.querySelector("details[open]")) {
        event.preventDefault();
        this.closeMenus();
      } else if (event.key === "Escape") {
        event.preventDefault();
        if (!this.stageTarget.hidden) this.stop();
        else this.closeLesson();
      } else if (event.key === "Tab") {
        const buttons = [...this.lessonDialogTarget.querySelectorAll("button, summary, select, [tabindex]")].filter(element => element.getClientRects().length);
        const first = buttons[0], last = buttons[buttons.length - 1];
        if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last?.focus(); }
        else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first?.focus(); }
      }
    }, options);
    this.updateRemote();
  }

  // Keep one preloaded video per source, as in vimeo_test; do not replace src on the play tap.
  get playerTarget() {
    return this.playerTargets.find(player => player.dataset.kind === (this.activeKind || "basic"));
  }

  setChapters(kind) {
    this.chapters = this.chapterSets[kind].map(([time, title, guide], index) => ({ time, title: `${index + 1}. ${title}`, guide }));
    this.chapterPickerTarget.replaceChildren(...this.chapters.map(chapter => {
      const option = document.createElement("option");
      option.value = chapter.time;
      option.textContent = `${this.formatTime(chapter.time)} · ${chapter.title}`;
      return option;
    }));
  }

  selectChapter() { this.seekTo(Number(this.chapterPickerTarget.value)); }

  closeMenus(except = null) {
    this.menuTarget.querySelectorAll("details").forEach(details => {
      if (details !== except) details.open = false;
    });
  }

  speak(event) {
    this.cancelSpeech();
    const audio = this.phraseAudioTargets.find(clip => clip.dataset.phrase === event.currentTarget.dataset.phrase);
    if (!audio) return;
    this.speechStatusTarget.textContent = "";
    audio.play().catch(() => {
      this.speechStatusTarget.textContent = "音声を再生できませんでした。もう一度タップしてください。";
    });
  }

  cancelSpeech() {
    this.phraseAudioTargets.forEach(audio => {
      audio.pause();
      if (audio.readyState > 0) audio.currentTime = 0;
    });
  }

  disconnect() {
    this.events?.abort();
    this.cancelSpeech();
    this.playbackGeneration += 1;
    this.playerTargets.forEach(player => player.pause());
    this.exitFullscreen(true);
    this.lessonDialogTarget.hidden = true;
    this.restoreBackground();
    if (this.resourceTarget.open) this.resourceTarget.close();
  }

  changeDate(event) {
    const date = new Date(`${this.dateTarget.value}T12:00:00`);
    if (Number.isNaN(date.getTime())) return;
    date.setDate(date.getDate() + Number(event.currentTarget.dataset.offset));
    this.dateTarget.value = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
  }

  previewResource(event) {
    event.preventDefault();
    this.resourceTitleTarget.textContent = event.currentTarget.dataset.title;
    this.resourceTarget.showModal();
  }

  closeResource() { this.resourceTarget.close(); }

  start() {
    this.returnFocus = document.activeElement;
    this.lessonDialogTarget.hidden = false;
    // Fullscreen the document, rather than a descendant of a modal dialog.
    this.enterFullscreen();
    this.backgroundElements = [...this.element.children, ...document.body.children]
      .filter(element => element !== this.lessonDialogTarget && !element.contains(this.lessonDialogTarget) && !element.inert);
    this.backgroundElements.forEach(element => { element.inert = true; });
    this.menuTarget.querySelector("button").focus();
  }

  restoreBackground() {
    this.backgroundElements?.forEach(element => { element.inert = false; });
    this.backgroundElements = [];
  }

  enterFullscreen() {
    if (document.fullscreenElement || document.webkitFullscreenElement) return;
    const element = document.documentElement;
    const request = element.requestFullscreen || element.webkitRequestFullscreen || element.webkitRequestFullScreen;
    const failed = () => {
      if (this.lessonDialogTarget.hidden) return;
      this.fullscreenButtonTarget.hidden = false;
      this.fullscreenStatusTarget.textContent = "全画面表示を開始できませんでした。もう一度お試しください。";
    };
    if (!request) { failed(); return; }
    this.ownsFullscreen = true;
    try {
      const result = request.call(element);
      result?.then?.(() => {
        this.fullscreenStatusTarget.textContent = "";
        if (this.lessonDialogTarget.hidden) this.exitFullscreen(true);
      }).catch(failed);
    } catch (_) { failed(); }
  }

  // Fullscreen implementation copied from deployed 2.7.9.1 (06c57ab8).
  enterVideoFullscreen() {
    const request = this.stageTarget.requestFullscreen || this.stageTarget.webkitRequestFullscreen;
    if (!request) return;

    try {
      const result = request.call(this.stageTarget);
      result?.catch?.(() => {});
    } catch (_error) {
      // The fixed viewport layout below remains as a browser-fullscreen fallback.
    }
  }

  closeLesson(event) {
    event?.preventDefault();
    this.lessonDialogTarget.hidden = true;
    this.stop();
    this.exitFullscreen(true);
    this.restoreBackground();
    this.returnFocus?.focus();
  }

  playVideo(event) {
    const { title, kind } = event.currentTarget.dataset;
    this.closeMenus();
    this.cancelSpeech();
    this.setChapters(kind);
    this.playerTargets.forEach(player => { player.pause(); player.hidden = true; });
    this.activeKind = kind;
    if (this.playerTarget.readyState > 0) this.playerTarget.currentTime = 0;
    this.playerTarget.playbackRate = 1;
    this.speedTarget.value = "1";
    this.videoTitleTarget.textContent = title;
    this.errorTarget.hidden = true;
    this.playerTarget.hidden = false;
    this.remoteTarget.hidden = true;
    this.stageTarget.hidden = false;
    this.updateRemote();
    // 2.7.9.1 sequence: container fullscreen, fixed viewport, then video.play().
    this.enterVideoFullscreen();
    this.stageTarget.classList.add("fixed", "inset-0", "z-[60]", "rounded-none");
    this.play();
  }

  play() {
    const generation = ++this.playbackGeneration;
    this.playerTarget.play().then(() => {
      if (generation !== this.playbackGeneration || this.stageTarget.hidden) return;
      // 2.7.9.1 hides setup and reveals the remote after play() resolves.
      this.menuTarget.hidden = true;
      this.splashTarget.hidden = true;
      this.remoteTarget.hidden = false;
      this.playButtonTarget.focus();
    }).catch(error => {
      if (generation === this.playbackGeneration && error.name !== "AbortError") this.showError();
    });
  }

  togglePlayback() {
    this.errorTarget.hidden = true;
    if (this.playerTarget.paused) this.play();
    else this.playerTarget.pause();
  }

  back() { this.seekTo(this.playerTarget.currentTime - 5); }
  forward() { this.seekTo(this.playerTarget.currentTime + 5); }

  seekTo(seconds) {
    if (!Number.isFinite(this.playerTarget.duration)) return;
    this.playerTarget.currentTime = Math.min(this.playerTarget.duration, Math.max(0, seconds));
    this.updateRemote();
  }

  previousChapter() {
    const previous = this.chapters.filter(chapter => chapter.time < this.playerTarget.currentTime - 1).pop();
    this.seekTo(previous?.time || 0);
  }

  nextChapter() {
    const next = this.chapters.find(chapter => chapter.time > this.playerTarget.currentTime + 1 && chapter.time < this.playerTarget.duration);
    if (next) this.seekTo(next.time);
  }

  changeSpeed() { this.playerTarget.playbackRate = Number(this.speedTarget.value); }

  stop() {
    const wasPlaying = !this.stageTarget.hidden;
    this.playbackGeneration += 1;
    this.cancelSpeech();
    this.closeMenus();
    this.playerTarget.pause();
    if (this.playerTarget.readyState > 0) this.playerTarget.currentTime = 0;
    this.exitFullscreen();
    this.stageTarget.classList.remove("fixed", "inset-0", "z-[60]", "rounded-none");
    this.stageTarget.hidden = true;
    this.playerTarget.hidden = true;
    this.remoteTarget.hidden = true;
    this.menuTarget.hidden = false;
    this.splashTarget.hidden = false;
    this.errorTarget.hidden = true;
    if (wasPlaying && !this.lessonDialogTarget.hidden) this.menuTarget.querySelector("button").focus();
  }

  exitFullscreen(includeLesson = false) {
    const fullscreen = document.fullscreenElement || document.webkitFullscreenElement;
    if (fullscreen !== this.stageTarget && !(includeLesson && this.ownsFullscreen && fullscreen === document.documentElement)) return;
    const exit = document.exitFullscreen || document.webkitExitFullscreen;
    if (!exit) return;
    const result = exit.call(document);
    result?.catch?.(() => {});
  }

  updateRemote() {
    const current = this.playerTarget.currentTime || 0;
    const chapter = this.chapters.filter(item => item.time <= current).pop() || this.chapters[0];
    this.chapterTitleTarget.textContent = chapter.title;
    this.chapterPickerTarget.value = String(chapter.time);
    this.guideTarget.textContent = chapter.guide;
    this.playButtonTarget.textContent = this.playerTarget.paused ? "▶ 再生" : "Ⅱ 一時停止";
    this.timeTarget.textContent = `${this.formatTime(current)} / ${this.formatTime(this.playerTarget.duration)}`;
  }

  formatTime(value) {
    const seconds = Number.isFinite(value) ? Math.max(0, Math.floor(value)) : 0;
    return `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, "0")}`;
  }

  showError() {
    if (this.stageTarget.hidden) return;
    this.remoteTarget.hidden = false;
    this.errorTarget.hidden = false;
  }
}
