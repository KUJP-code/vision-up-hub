import { Controller } from "@hotwired/stimulus";

// Shared by the AI Sensei event view and the admin lesson preview.
export default class extends Controller {
  static values = { content: Object };

  static targets = [
    "lessonDialog", "lessonScreen", "stage", "player", "menu", "remote", "playButton",
    "time", "error", "date", "resource", "resourceTitle", "videoTitle", "chapterTitle",
    "guide", "speedButton", "chapterPicker", "splash", "speechStatus", "phraseAudio",
    "guidePanel", "guideButton", "sidebar", "page", "pageTitle", "navButton", "filter",
    "resourceGuide", "resourceMaterials", "lessonWeek", "picker", "pickerActivity",
    "pickerStory", "flashcards", "cardPhrase", "cardImage", "progress",
    "playIcon", "pauseIcon", "chapterStop", "thumbnail", "lessonTabs", "pickerNavigation",
    "pickerScroll", "homeLesson", "homeUpcoming", "weekHeading", "upcomingWeek", "cardClipRect",
    "guideObjective", "guideMaterials", "guideTip", "resourceObjective", "resourcePreparation",
    "resourceTip", "resourceChapters", "resourceScroll"
  ];

  connect() {
    this.sampleLessonDate = this.dateTarget.value;
    this.setChapters("basic");
    this.events = new AbortController();
    const options = { signal: this.events.signal };
    this.playbackGeneration = 0;
    this.lastPlaybackTime = 0;
    this.pauseAtChapterEnd = false;
    this.playerTargets.forEach(player => {
      ["play", "pause", "timeupdate", "loadedmetadata", "durationchange"].forEach(event => {
        player.addEventListener(event, () => {
          if (event === "timeupdate") this.checkChapterEnd();
          this.updateRemote();
          if (event === "pause" && player === this.playerTarget) this.showRemote();
        }, options);
      });
      player.addEventListener("ended", () => { if (player === this.playerTarget) this.stop(); }, options);
      player.addEventListener("error", () => { if (player === this.playerTarget) this.showError(); }, options);
    });
    ["pointermove", "pointerdown", "pointerup", "click", "keydown", "focusin"].forEach(event => {
      this.stageTarget.addEventListener(event, () => this.showRemote(), options);
    });
    this.stageTarget.addEventListener("pointerdown", () => { this.remoteInteraction = true; }, options);
    ["pointerup", "pointercancel"].forEach(event => {
      document.addEventListener(event, () => {
        this.remoteInteraction = false;
        this.showRemote();
      }, options);
    });
    ["fullscreenchange", "webkitfullscreenchange"].forEach(event => {
      document.addEventListener(event, () => {
        if (this.lessonDialogTarget.hidden) this.exitFullscreen();
      }, options);
    });

    this.lessonScreenTarget.addEventListener("click", event => {
      const selected = event.target.closest("details");
      this.closeMenus(selected);
    }, options);
    this.lessonScreenTarget.addEventListener("keydown", event => {
      // Native dialogs handle their own Escape key and focus trap.
      if (this.pickerTarget.open || this.flashcardsTarget.open || this.resourceTarget.open) return;
      if (event.key === "Escape" && this.lessonScreenTarget.querySelector("details[open]")) {
        event.preventDefault();
        this.closeMenus();
      } else if (event.key === "Escape") {
        event.preventDefault();
        if (!this.stageTarget.hidden) this.stop();
        else this.closeLesson();
      } else if (event.key === "Tab") {
        const buttons = [...this.lessonDialogTarget.querySelectorAll("button, summary, select, input, [tabindex]")].filter(element => element.getClientRects().length);
        const first = buttons[0], last = buttons[buttons.length - 1];
        if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last?.focus(); }
        else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first?.focus(); }
      }
    }, options);
    this.flashcardsTarget.addEventListener("keydown", event => {
      if (event.key === "ArrowLeft") { event.preventDefault(); this.previousCard(); }
      if (event.key === "ArrowRight") { event.preventDefault(); this.nextCard(); }
    }, options);
    this.flashcardsTarget.addEventListener("close", () => this.cancelSpeech(), options);
    this.pickerTarget.addEventListener("close", () => {
      if (!this.pickerTarget.open) this.restoreLessonTabs();
    }, options);
    [this.resourceTarget, this.pickerTarget, this.flashcardsTarget].forEach(dialog => {
      dialog.addEventListener("click", event => this.dismissBackdrop(event), options);
    });
    this.updateRemote();
  }

  dismissBackdrop(event) {
    const dialog = event.currentTarget;
    if (event.target !== dialog) return;
    const bounds = dialog.getBoundingClientRect();
    const outside = event.clientX < bounds.left || event.clientX > bounds.right ||
      event.clientY < bounds.top || event.clientY > bounds.bottom;
    // The flashcard dialog fills the viewport; its empty area is its backdrop.
    if (dialog === this.flashcardsTarget || outside) dialog.close();
  }

  async thumbnailTargetConnected(container) {
    const videoUrl = this.vimeoPageUrl(container.dataset.video);
    if (!videoUrl) return;
    this.thumbnailRequests ||= new Map();
    if (!this.thumbnailRequests.has(videoUrl)) {
      const endpoint = new URL("https://vimeo.com/api/oembed.json");
      endpoint.searchParams.set("url", videoUrl);
      endpoint.searchParams.set("maxwidth", "960");
      const request = fetch(endpoint, { credentials: "omit" }).then(response => {
        if (!response.ok) throw new Error("Thumbnail unavailable");
        return response.json();
      }).then(metadata => metadata.thumbnail_url).catch(() => null);
      this.thumbnailRequests.set(videoUrl, request);
    }
    const thumbnail = await this.thumbnailRequests.get(videoUrl);
    if (!thumbnail || !container.isConnected) return;
    const image = container.querySelector("img");
    image.addEventListener("load", () => {
      image.hidden = false;
      container.querySelector(".lm-thumbnail-placeholder").hidden = true;
    }, { once: true });
    image.src = thumbnail;
  }

  vimeoPageUrl(value) {
    try {
      const url = new URL(value);
      if (!["vimeo.com", "www.vimeo.com", "player.vimeo.com"].includes(url.hostname)) return null;
      const match = url.pathname.match(/(?:^|\/)(\d+)(?:\.(?:m3u8|mp4))?(?:\/|$)/);
      if (!match) return null;
      const hash = url.searchParams.get("h") || url.pathname.match(/\/\d+\/([a-zA-Z0-9]+)\/?$/)?.[1];
      return `https://vimeo.com/${match[1]}${hash ? `/${hash}` : ""}`;
    } catch (_error) {
      return null;
    }
  }

  navigate(event) {
    const view = event.currentTarget.dataset.view;
    const titles = { home: "ホーム", basic: "ベーシックイングリッシュのメニュー", activities: "アクティビティのメニュー", stories: "ストーリーのメニュー" };
    this.pageTargets.forEach(page => { page.hidden = page.dataset.view !== view; });
    this.navButtonTargets.forEach(button => {
      if (button.dataset.view === view) button.setAttribute("aria-current", "page");
      else button.removeAttribute("aria-current");
    });
    this.pageTitleTarget.textContent = titles[view];
    this.sidebarTarget.classList.remove("lm-sidebar-open");
    const toggle = this.sidebarTarget.querySelector("button");
    toggle.setAttribute("aria-expanded", "false");
    toggle.setAttribute("aria-label", "メニューを開く");
    window.scrollTo(0, 0);
  }

  toggleSidebar(event) {
    const expanded = this.sidebarTarget.classList.toggle("lm-sidebar-open");
    event.currentTarget.setAttribute("aria-expanded", String(expanded));
    event.currentTarget.setAttribute("aria-label", expanded ? "メニューを閉じる" : "メニューを開く");
  }

  filterActivities(event) {
    const category = event.currentTarget.dataset.category;
    this.filterTargets.forEach(button => button.setAttribute("aria-pressed", String(button === event.currentTarget)));
    // Filter only menu cards; keep all category selectors visible.
    this.pageTargets.find(page => page.dataset.view === "activities").querySelectorAll(".lm-content-card[data-category]").forEach(card => {
      card.hidden = category !== "全て" && card.dataset.category !== category;
    });
  }

  openPicker(event) {
    this.cancelSpeech();
    const activity = event.currentTarget.dataset.kind === "activity";
    this.pickerActivityTarget.hidden = !activity;
    this.pickerStoryTarget.hidden = activity;
    this.pickerTarget.setAttribute("aria-label", activity ? "アクティビティを選ぶ" : "ストーリーを選ぶ");
    this.lessonTabsTarget.querySelectorAll("[aria-expanded]").forEach(button => {
      button.setAttribute("aria-expanded", String(button === event.currentTarget));
    });
    this.pickerScrollTarget.scrollTop = 0;
    if (!this.pickerTarget.open) {
      this.pickerReturnFocus = event.currentTarget;
      this.pickerNavigationTarget.append(this.lessonTabsTarget);
      this.pickerTarget.showModal();
    }
  }

  restoreLessonTabs() {
    if (this.lessonTabsTarget.parentElement === this.menuTarget) return;
    this.menuTarget.insertBefore(this.lessonTabsTarget, this.menuTarget.querySelector(".lm-close"));
    this.lessonTabsTarget.querySelectorAll("[aria-expanded]").forEach(button => button.setAttribute("aria-expanded", "false"));
    if (!this.lessonDialogTarget.hidden && this.stageTarget.hidden && !this.flashcardsTarget.open) this.pickerReturnFocus?.focus();
  }

  closePicker() {
    if (this.pickerTarget.open) this.pickerTarget.close();
    this.restoreLessonTabs();
  }

  openFlashcards() {
    this.closePicker();
    this.cardIndex = 0;
    this.updateCard();
    this.flashcardsTarget.showModal();
  }

  closeFlashcards() { this.cancelSpeech(); this.flashcardsTarget.close(); }
  previousCard() { this.cardIndex = (this.cardIndex + 2) % 3; this.updateCard(); }
  nextCard() { this.cardIndex = (this.cardIndex + 1) % 3; this.updateCard(); }

  updateCard() {
    this.cancelSpeech();
    const phrases = ["Hello!", "Nice to meet you!", "See you!"];
    this.cardPhraseTarget.textContent = phrases[this.cardIndex];
    this.cardPhraseTarget.dataset.readingFont = String(this.cardIndex === 0);
    const crops = ["540 180 520 665", "1070 380 620 470", "0 245 475 565"];
    this.cardImageTarget.setAttribute("viewBox", crops[this.cardIndex]);
    crops[this.cardIndex].split(" ").forEach((value, index) => {
      this.cardClipRectTarget.setAttribute(["x", "y", "width", "height"][index], value);
    });
    this.cardImageTarget.setAttribute("aria-label", [
      "手を振ってあいさつするキャラクター", "はじめましてのあいさつをする２人", "手を振ってさようならを言うキャラクター"
    ][this.cardIndex]);
  }

  speakCard() { this.speak({ currentTarget: { dataset: { phrase: this.cardPhraseTarget.textContent } } }); }

  launchVideo(event) {
    const fromMenu = this.lessonDialogTarget.hidden;
    if (fromMenu) this.start();
    this.videoOpenedFromMenu = fromMenu;
    this.playVideo(event);
  }

  // There is exactly one video element, as in 2.7.9.1. Selecting a menu prepares
  // its source before the video link is tapped; pointer/focus also cover direct links.
  prepareVideo(event) {
    if (!this.stageTarget.hidden) return;
    const choice = event.target.closest("[data-src][data-kind]");
    if (choice) this.loadVideoSource(choice.dataset);
  }

  loadVideoSource({ src, kind }) {
    if (this.playerTarget.getAttribute("src") === src) return;
    this.playerTarget.src = src;
    this.playerTarget.dataset.kind = kind;
    this.playerTarget.load();
  }

  toggleGuide() {
    const expanded = this.guidePanelTarget.hidden;
    this.guidePanelTarget.hidden = !expanded;
    this.guideButtonTarget.setAttribute("aria-expanded", String(expanded));
  }

  resetGuide() {
    this.guidePanelTarget.hidden = true;
    this.guideButtonTarget.setAttribute("aria-expanded", "false");
  }

  timecodeSeconds(timecode) {
    const [hours, minutes, seconds, frames] = timecode.split(":").map(Number);
    return hours * 3600 + minutes * 60 + seconds + frames / this.contentValue.fps;
  }

  lessonChapters(key) {
    return this.contentValue.lessons[key].chapters.map((chapter, index) => ({
      ...chapter,
      time: this.timecodeSeconds(chapter.start),
      endTime: chapter.end ? this.timecodeSeconds(chapter.end) : null,
      title: `${index + 1}. ${chapter.title}`
    }));
  }

  chapterLabel(chapter) {
    return `${this.formatTime(chapter.time)}–${chapter.endTime == null ? "最後" : this.formatTime(chapter.endTime)} ${chapter.title}${chapter.pause_after ? " · 一時停止" : ""}`;
  }

  setChapters(key) {
    const lesson = this.contentValue.lessons[key];
    this.chapters = this.lessonChapters(key);
    this.guideObjectiveTarget.textContent = lesson.objective;
    this.guideMaterialsTarget.textContent = lesson.materials;
    this.guideTipTarget.textContent = lesson.tip;
    this.chapterPickerTarget.replaceChildren(...this.chapters.map(chapter => {
      const option = document.createElement("option");
      option.value = chapter.time;
      option.textContent = this.chapterLabel(chapter);
      return option;
    }));
  }

  selectChapter() { this.seekTo(Number(this.chapterPickerTarget.value)); }

  closeMenus(except = null) {
    this.lessonScreenTarget.querySelectorAll("details").forEach(details => {
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
    clearTimeout(this.remoteTimeout);
    this.events?.abort();
    this.cancelSpeech();
    this.playbackGeneration += 1;
    this.playerTargets.forEach(player => player.pause());
    this.exitFullscreen();
    this.lessonDialogTarget.hidden = true;
    this.restoreBackground();
    if (this.resourceTarget.open) this.resourceTarget.close();
    if (this.pickerTarget.open) this.closePicker();
    if (this.flashcardsTarget.open) this.flashcardsTarget.close();
  }

  changeDate(event) {
    const date = new Date(`${this.dateTarget.value}T12:00:00`);
    if (Number.isNaN(date.getTime())) return;
    date.setDate(date.getDate() + Number(event.currentTarget.dataset.offset));
    this.dateTarget.value = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
    this.updateWeek();
  }

  updateWeek() {
    const weekStart = value => {
      const date = new Date(`${value}T12:00:00`);
      date.setDate(date.getDate() - (date.getDay() + 6) % 7);
      return date.getTime();
    };
    const weeksAhead = Math.round((weekStart(this.dateTarget.value) - weekStart(this.sampleLessonDate)) / 604800000);
    if (!Number.isFinite(weeksAhead)) return;
    this.homeLessonTarget.hidden = weeksAhead > 0;
    this.homeUpcomingTarget.hidden = weeksAhead <= 0;
    this.weekHeadingTarget.textContent = weeksAhead > 0 ? "これからのレッスン" : "今週のレッスン";
    this.upcomingWeekTarget.textContent = `第${Math.max(2, weeksAhead + 1)}週 · ベーシックイングリッシュ`;
  }

  previewResource(event) {
    event.preventDefault();
    const { title, resourceKind, contentKey = "basic" } = event.currentTarget.dataset;
    this.resourceTitleTarget.textContent = title;
    const materials = resourceKind === "materials";
    if (!materials) {
      const lesson = this.contentValue.lessons[contentKey];
      this.resourceObjectiveTarget.textContent = lesson.objective;
      this.resourcePreparationTarget.textContent = lesson.materials;
      this.resourceTipTarget.textContent = lesson.tip;
      this.resourceChaptersTarget.replaceChildren(...this.lessonChapters(contentKey).map(chapter => {
        const section = document.createElement("section");
        const heading = document.createElement("h3");
        const timing = document.createElement("p");
        const guide = document.createElement("p");
        heading.textContent = chapter.title;
        timing.textContent = `${chapter.start} – ${chapter.end || "最後"}${chapter.pause_after ? " · 一時停止" : ""}`;
        guide.textContent = chapter.guide;
        section.append(heading, timing, guide);
        return section;
      }));
    }
    this.resourceGuideTarget.hidden = materials;
    this.resourceMaterialsTarget.hidden = !materials;
    this.resourceTarget.showModal();
    this.resourceScrollTarget.scrollTop = 0;
  }

  closeResource() { this.resourceTarget.close(); }

  start(event) {
    this.returnFocus = document.activeElement;
    this.videoOpenedFromMenu = false;
    this.lessonWeekTarget.textContent = `第${event?.currentTarget.dataset.week || 1}週 · ベーシックイングリッシュ`;
    this.lessonDialogTarget.hidden = false;
    this.backgroundElements = [...this.element.children, ...document.body.children]
      .filter(element => element !== this.lessonDialogTarget && !element.contains(this.lessonDialogTarget) && !element.matches("dialog") && !element.inert);
    this.backgroundElements.forEach(element => { element.inert = true; });
    this.menuTarget.querySelector("button").focus();
  }

  restoreBackground() {
    this.backgroundElements?.forEach(element => { element.inert = false; });
    this.backgroundElements = [];
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
    if (this.pickerTarget.open) this.closePicker();
    if (this.flashcardsTarget.open) this.closeFlashcards();
    if (this.resourceTarget.open) this.closeResource();
    this.lessonDialogTarget.hidden = true;
    this.videoOpenedFromMenu = false;
    this.stop();
    this.exitFullscreen();
    this.restoreBackground();
    this.returnFocus?.focus();
  }

  playVideo(event) {
    const { src, title, kind, contentKey = kind } = event.currentTarget.dataset;
    this.closePicker();
    this.closeMenus();
    this.cancelSpeech();
    this.setChapters(contentKey);
    this.playerTarget.pause();
    this.loadVideoSource({ src, kind });
    this.resetGuide();
    if (this.playerTarget.readyState > 0) this.playerTarget.currentTime = 0;
    this.playerTarget.playbackRate = 1;
    this.lastPlaybackTime = 0;
    this.updateSpeedButtons();
    this.videoTitleTarget.textContent = title;
    this.errorTarget.hidden = true;
    this.remoteTarget.hidden = true;
    this.stageTarget.hidden = false;
    this.stageTarget.getBoundingClientRect();
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
      this.showRemote();
    }).catch(error => {
      if (generation === this.playbackGeneration && error.name !== "AbortError") this.showError();
    });
  }

  togglePlayback() {
    this.errorTarget.hidden = true;
    if (this.playerTarget.paused) this.play();
    else this.playerTarget.pause();
  }

  showRemote() {
    clearTimeout(this.remoteTimeout);
    if (this.stageTarget.hidden || this.remoteTarget.hidden) return;
    this.stageTarget.classList.remove("lm-controls-hidden");
    this.remoteTarget.inert = false;
    this.remoteTimeout = setTimeout(() => this.hideRemote(), 5000);
  }

  hideRemote() {
    // Keep controls available while paused, reading the guide, or choosing a speed.
    if (this.stageTarget.hidden || this.playerTarget.paused || this.remoteInteraction ||
        !this.guidePanelTarget.hidden || !this.errorTarget.hidden ||
        this.remoteTarget.querySelector("details[open]")) return;
    if (this.remoteTarget.contains(document.activeElement)) this.stageTarget.focus({ preventScroll: true });
    clearTimeout(this.remoteTimeout);
    this.remoteTarget.inert = true;
    this.stageTarget.classList.add("lm-controls-hidden");
  }

  back() { this.seekTo(this.playerTarget.currentTime - 5); }
  forward() { this.seekTo(this.playerTarget.currentTime + 5); }

  seekTo(seconds) {
    if (!Number.isFinite(this.playerTarget.duration)) return;
    this.playerTarget.currentTime = Math.min(this.playerTarget.duration, Math.max(0, seconds));
    this.lastPlaybackTime = this.playerTarget.currentTime;
    this.updateRemote();
  }

  scrub() { this.seekTo(Number(this.progressTarget.value)); }

  toggleChapterStop() {
    this.pauseAtChapterEnd = !this.pauseAtChapterEnd;
    this.lastPlaybackTime = this.playerTarget.currentTime;
    this.chapterStopTarget.setAttribute("aria-checked", String(this.pauseAtChapterEnd));
  }

  checkChapterEnd() {
    const current = this.playerTarget.currentTime;
    if (!this.playerTarget.paused && !this.playerTarget.seeking) {
      const boundary = this.chapters.find(chapter => {
        const end = chapter.endTime;
        return (this.pauseAtChapterEnd || chapter.pause_after) && end != null &&
          end > this.lastPlaybackTime && end <= current;
      });
      if (boundary) {
        this.playerTarget.pause();
        this.playerTarget.currentTime = boundary.endTime;
      }
    }
    this.lastPlaybackTime = this.playerTarget.currentTime;
  }

  previousChapter() {
    const previous = this.chapters.filter(chapter => chapter.time < this.playerTarget.currentTime - 1).pop();
    this.seekTo(previous?.time || 0);
  }

  nextChapter() {
    const next = this.chapters.find(chapter => chapter.time > this.playerTarget.currentTime + 1 && chapter.time < this.playerTarget.duration);
    if (next) this.seekTo(next.time);
  }

  changeSpeed(event) {
    this.playerTarget.playbackRate = Number(event.currentTarget.dataset.rate);
    this.updateSpeedButtons();
    this.closeMenus();
  }

  updateSpeedButtons() {
    this.speedButtonTargets.forEach(button => {
      button.setAttribute("aria-pressed", String(Number(button.dataset.rate) === this.playerTarget.playbackRate));
    });
  }

  stop() {
    clearTimeout(this.remoteTimeout);
    this.remoteInteraction = false;
    this.stageTarget.classList.remove("lm-controls-hidden");
    this.remoteTarget.inert = false;
    const wasPlaying = !this.stageTarget.hidden;
    this.playbackGeneration += 1;
    this.cancelSpeech();
    this.closeMenus();
    this.playerTarget.pause();
    if (this.playerTarget.readyState > 0) this.playerTarget.currentTime = 0;
    this.exitFullscreen();
    this.stageTarget.classList.remove("fixed", "inset-0", "z-[60]", "rounded-none");
    this.stageTarget.hidden = true;
    clearTimeout(this.remoteTimeout);
    this.remoteTarget.hidden = true;
    this.menuTarget.hidden = false;
    this.splashTarget.hidden = false;
    this.errorTarget.hidden = true;
    if (this.videoOpenedFromMenu) {
      this.videoOpenedFromMenu = false;
      this.lessonDialogTarget.hidden = true;
      this.restoreBackground();
      this.returnFocus?.focus();
    } else if (wasPlaying && !this.lessonDialogTarget.hidden) {
      this.menuTarget.querySelector("button").focus();
    }
  }

  exitFullscreen() {
    const fullscreen = document.fullscreenElement || document.webkitFullscreenElement;
    if (fullscreen !== this.stageTarget) return;
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
    this.playButtonTarget.setAttribute("aria-label", this.playerTarget.paused ? "再生" : "一時停止");
    this.playIconTarget.hidden = !this.playerTarget.paused;
    this.pauseIconTarget.hidden = this.playerTarget.paused;
    this.timeTarget.textContent = `${this.formatTime(current)} / ${this.formatTime(this.playerTarget.duration)}`;
    const duration = Number.isFinite(this.playerTarget.duration) ? this.playerTarget.duration : 0;
    this.progressTarget.max = String(duration || 100);
    this.progressTarget.value = String(current);
    this.progressTarget.disabled = duration <= 0;
    this.progressTarget.setAttribute("aria-valuetext", this.timeTarget.textContent);
    this.progressTarget.style.setProperty("--lm-progress", `${duration ? current / duration * 100 : 0}%`);
  }

  formatTime(value) {
    const seconds = Number.isFinite(value) ? Math.max(0, Math.floor(value)) : 0;
    return `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, "0")}`;
  }

  showError() {
    if (this.stageTarget.hidden) return;
    this.remoteTarget.hidden = false;
    this.errorTarget.hidden = false;
    this.showRemote();
  }
}
