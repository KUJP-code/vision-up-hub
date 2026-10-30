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
    "pickerScroll", "homeLesson", "homeUpcoming", "homeHeader", "weekHeading", "upcomingWeek", "cardClipRect",
    "guideObjective", "guideMaterials", "guideTip", "resourceObjective", "resourcePreparation",
    "resourceTip", "resourceChapters", "resourceScroll", "subtitleButton", "captionFallback"
  ];

  connect() {
    this.sampleLessonDate = this.dateTarget.value;
    this.setChapters("basic");
    this.events = new AbortController();
    const options = { signal: this.events.signal };
    this.playbackGeneration = 0;
    this.videoActive = false;
    this.lastPlaybackTime = 0;
    this.pauseAtChapterEnd = false;
    this.playerTargets.forEach(player => {
      ["play", "pause", "timeupdate", "loadedmetadata", "durationchange"].forEach(event => {
        player.addEventListener(event, () => {
          if (event === "timeupdate") this.checkChapterEnd();
          if (event === "loadedmetadata" || event === "play") this.syncSubtitles(true);
          this.updateRemote();
          if (event === "pause" && player === this.playerTarget) this.showRemote();
        }, options);
      });
      player.addEventListener("ended", () => { if (player === this.playerTarget) this.stop(); }, options);
      player.addEventListener("error", () => { if (player === this.playerTarget) this.showError(); }, options);
    });
    const textTracks = this.playerTarget.textTracks;
    const watchedTracks = new WeakSet();
    const watchCaptionCues = () => this.allSubtitleTracks().forEach(track => {
      if (watchedTracks.has(track)) return;
      watchedTracks.add(track);
      track.addEventListener("cuechange", () => this.positionSubtitles(), options);
    });
    ["addtrack", "removetrack"].forEach(event => {
      textTracks.addEventListener(event, () => { watchCaptionCues(); this.syncSubtitles(true); }, options);
    });
    watchCaptionCues();
    textTracks.addEventListener("change", () => this.syncSubtitles(), options);
    this.captionFallbackTarget.addEventListener("load", () => this.syncSubtitles(true), options);
    this.playerTarget.addEventListener("webkitcurrentplaybacktargetiswirelesschanged", () => this.syncSubtitles(true), options);
    this.captionResizeObserver = new ResizeObserver(() => this.positionSubtitles());
    this.captionResizeObserver.observe(this.playerTarget);
    this.captionResizeObserver.observe(this.remoteTarget);
    this.syncSubtitles();
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
    // Starting playback leaves focus alone, so Escape must also work when the
    // browser moves focus to the document after the launch button becomes inert.
    document.addEventListener("keydown", event => {
      if (this.lessonDialogTarget.hidden) return;
      // Native dialogs handle their own Escape key and focus trap.
      if (this.pickerTarget.open || this.flashcardsTarget.open || this.resourceTarget.open) return;
      if (event.key === "Escape" && this.lessonScreenTarget.querySelector("details[open]")) {
        event.preventDefault();
        this.closeMenus();
      } else if (event.key === "Escape") {
        event.preventDefault();
        if (this.videoActive) this.stop();
        else this.closeLesson();
      } else if (event.key === "Tab") {
        const buttons = [...this.lessonDialogTarget.querySelectorAll("button, summary, select, input, [tabindex]")]
          .filter(element => element.getClientRects().length && !element.closest("[inert]"));
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
    const titles = { home: "今週のレッスン", basic: "ベーシックイングリッシュのメニュー", activities: "アクティビティのメニュー", stories: "ストーリーのメニュー" };
    this.pageTargets.forEach(page => { page.hidden = page.dataset.view !== view; });
    this.navButtonTargets.forEach(button => {
      if (button.dataset.view === view) button.setAttribute("aria-current", "page");
      else button.removeAttribute("aria-current");
    });
    this.pageTitleTarget.textContent = titles[view];
    this.pageTitleTarget.hidden = view === "home";
    this.homeHeaderTarget.hidden = view !== "home";
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
    const choice = (activity ? this.pickerActivityTarget : this.pickerStoryTarget).querySelector("[data-src][data-kind]");
    if (choice) this.loadVideoSource(choice.dataset);
  }

  restoreLessonTabs(restoreFocus = true) {
    if (this.lessonTabsTarget.parentElement === this.menuTarget) return;
    this.menuTarget.insertBefore(this.lessonTabsTarget, this.menuTarget.querySelector(".lm-close"));
    this.lessonTabsTarget.querySelectorAll("[aria-expanded]").forEach(button => button.setAttribute("aria-expanded", "false"));
    if (restoreFocus && !this.lessonDialogTarget.hidden && !this.videoActive && !this.flashcardsTarget.open) this.pickerReturnFocus?.focus();
  }

  closePicker(restoreFocus = true) {
    if (this.pickerTarget.open) this.pickerTarget.close();
    this.restoreLessonTabs(restoreFocus);
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
    if (this.videoActive) return;
    const fromMenu = this.lessonDialogTarget.hidden;
    if (fromMenu) this.start();
    this.videoOpenedFromMenu = fromMenu;
    this.playVideo(event);
  }

  // Prepare the single player on pointer/focus events in every content view,
  // including cards outside the lesson screen, before their click starts playback.
  prepareVideo(event) {
    if (this.videoActive) return;
    const choice = event.target.closest("[data-src][data-kind]");
    if (choice) this.loadVideoSource(choice.dataset);
  }

  loadVideoSource({ src, kind, captionSrc }) {
    if (captionSrc && this.hasCaptionFallbackTarget && this.captionFallbackTarget.getAttribute("src") !== captionSrc) {
      this.captionFallbackTarget.src = captionSrc;
    }
    if (this.playerTarget.getAttribute("src") === src) return;
    // Assigning src invokes the media load algorithm. Calling load() as well
    // restarts that selection unnecessarily.
    this.playerTarget.src = src;
    this.playerTarget.dataset.kind = kind;
  }

  setVideoActive(active) {
    this.videoActive = active;
    this.stageTarget.inert = !active;
    this.stageTarget.setAttribute("aria-hidden", String(!active));
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
      if (!audio.paused) audio.pause();
      if (audio.readyState > 0 && audio.currentTime > 0) audio.currentTime = 0;
    });
  }

  disconnect() {
    clearTimeout(this.remoteTimeout);
    this.captionResizeObserver?.disconnect();
    this.events?.abort();
    this.cancelSpeech();
    this.playbackGeneration += 1;
    this.setVideoActive(false);
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
    // Keep a rendered 16:9 video surface under the splash before Play is tapped.
    this.stageTarget.hidden = false;
    this.backgroundElements = [...this.element.children, ...document.body.children]
      .filter(element => element !== this.lessonDialogTarget && !element.contains(this.lessonDialogTarget) && !element.matches("dialog") && !element.inert);
    this.backgroundElements.forEach(element => { element.inert = true; });
    // A direct card launch has already prepared its own source; focusing Basic
    // English here would replace it through the focusin preparation handler.
    if (event) this.menuTarget.querySelector("button").focus();
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
    if (this.videoActive) return;
    // Lock the launch before closing the picker: focus restoration must not
    // prepare another source, and another click must not reopen this player.
    this.setVideoActive(true);
    const { src, title, kind, captionSrc, contentKey = kind } = event.currentTarget.dataset;
    this.closePicker(false);
    this.closeMenus();
    this.cancelSpeech();
    this.setChapters(contentKey);
    // Pointer/focus normally prepared this already. Retain a synchronous fallback
    // for keyboard, assistive-technology, and programmatic clicks.
    this.loadVideoSource({ src, kind, captionSrc });
    this.resetGuide();
    if (this.playerTarget.playbackRate !== 1) this.playerTarget.playbackRate = 1;
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
    const current = this.playerTarget.currentTime || 0;
    this.lastPlaybackTime = current;
    // HLS seeks can settle just before a pause point. Skip nearby points for
    // this run, even if buffering delays the first timeupdate after resuming.
    this.autoPauseIgnoreUntil = current + 3;
    this.playerTarget.play().then(() => {
      if (generation !== this.playbackGeneration || !this.videoActive) return;
      // 2.7.9.1 hides setup and reveals the remote after play() resolves.
      this.menuTarget.hidden = true;
      this.splashTarget.hidden = true;
      this.remoteTarget.hidden = false;
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
    if (!this.videoActive || this.remoteTarget.hidden) return;
    this.stageTarget.classList.remove("lm-controls-hidden");
    this.remoteTarget.inert = false;
    this.positionSubtitles();
    this.remoteTimeout = setTimeout(() => this.hideRemote(), 5000);
  }

  hideRemote() {
    // Keep controls available while paused, reading the guide, or choosing a speed.
    if (!this.videoActive || this.playerTarget.paused || this.remoteInteraction ||
        !this.guidePanelTarget.hidden || !this.errorTarget.hidden ||
        this.remoteTarget.querySelector("details[open]")) return;
    if (this.remoteTarget.contains(document.activeElement)) this.stageTarget.focus({ preventScroll: true });
    clearTimeout(this.remoteTimeout);
    this.remoteTarget.inert = true;
    this.stageTarget.classList.add("lm-controls-hidden");
    this.positionSubtitles();
  }

  back() { this.seekTo(this.playerTarget.currentTime - 5); }
  forward() { this.seekTo(this.playerTarget.currentTime + 5); }

  seekTo(seconds) {
    if (!Number.isFinite(this.playerTarget.duration)) return;
    this.playerTarget.currentTime = Math.min(this.playerTarget.duration, Math.max(0, seconds));
    this.lastPlaybackTime = this.playerTarget.currentTime;
    this.autoPauseIgnoreUntil = 0;
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
          end > (this.autoPauseIgnoreUntil || 0) &&
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

  allSubtitleTracks() {
    return Array.from(this.playerTarget.textTracks || []).filter(track => ["subtitles", "captions"].includes(track.kind));
  }

  subtitleTracks() {
    const tracks = this.allSubtitleTracks();
    const fallback = this.hasCaptionFallbackTarget ? this.captionFallbackTarget.track : null;
    if (!fallback || !tracks.includes(fallback)) return tracks;
    const native = tracks.filter(track => track !== fallback && track.language.split("-")[0] === fallback.language.split("-")[0]);
    // An advertised HLS track can exist without usable cues on a laptop. Keep
    // the real WebVTT fallback until native cues exist, or AirPlay owns playback.
    const preferred = native.find(track => this.playerTarget.webkitCurrentPlaybackTargetIsWireless === true || track.cues?.length > 0);
    return tracks.filter(track => track === fallback ? !preferred : !native.includes(track) || track === preferred);
  }

  subtitleLabel(track, index) {
    const language = track.language.toLowerCase().split("-")[0];
    const label = { en: "英語", ja: "日本語" }[language] || track.label || `字幕 ${index + 1}`;
    return /autogen|auto.generated|自動生成/i.test(`${track.language} ${track.label}`) ? `${label}（自動生成）` : label;
  }

  preferredSubtitle(tracks, preference) {
    if (!preference) return null;
    return tracks.find(track => track.language === preference.language && track.label === preference.label) ||
      tracks.find(track => track.language && track.language.split("-")[0] === preference.language.split("-")[0]);
  }

  syncSubtitles(applyPreference = false) {
    const tracks = this.subtitleTracks();
    this.allSubtitleTracks().filter(track => !tracks.includes(track)).forEach(excluded => {
      const replacement = tracks.find(track => track.language.split("-")[0] === excluded.language.split("-")[0]);
      if (replacement && excluded.mode === "showing" && this.subtitlePreference !== null) replacement.mode = "showing";
      if (excluded.mode !== "disabled") excluded.mode = "disabled";
    });
    if (applyPreference && this.subtitlePreference !== undefined) {
      const preference = this.subtitlePreference;
      const selected = preference ? this.preferredSubtitle(tracks, preference) || tracks[0] : null;
      tracks.forEach(track => {
        const mode = track === selected ? "showing" : "disabled";
        if (track.mode !== mode) track.mode = mode;
      });
    }
    const showing = tracks.find(track => track.mode === "showing");
    if (showing) this.lastSubtitlePreference = { language: showing.language, label: showing.label };
    this.subtitleButtonTarget.hidden = tracks.length === 0;
    this.subtitleButtonTarget.setAttribute("aria-pressed", String(Boolean(showing)));
    this.subtitleButtonTarget.setAttribute("aria-label", showing ? "字幕をオフにする" : "字幕をオンにする");
    this.subtitleButtonTarget.setAttribute("title", showing ? `${this.subtitleLabel(showing, tracks.indexOf(showing))} · オン` : "字幕をオンにする");
    this.positionSubtitles();
  }

  positionSubtitles() {
    if (!this.videoActive) return;
    const tracks = this.allSubtitleTracks().filter(track => track.mode === "showing" && track.cues?.length);
    if (!tracks.length) return;
    const player = this.playerTarget;
    const bounds = player.getBoundingClientRect();
    if (!player.videoWidth || !player.videoHeight || !bounds.height) return;
    // Cue percentages refer to the contained video picture, excluding letterboxing.
    const height = Math.min(bounds.height, bounds.width * player.videoHeight / player.videoWidth);
    const top = bounds.top + (bounds.height - height) / 2;
    const remoteVisible = !this.remoteTarget.hidden && !this.stageTarget.classList.contains("lm-controls-hidden");
    const nativeDisplay = player.webkitCurrentPlaybackTargetIsWireless === true || player.webkitDisplayingFullscreen === true;
    const bottom = remoteVisible ? Math.min(top + height, this.remoteTarget.getBoundingClientRect().top) : top + height;
    this.captionPositions ||= new WeakMap();
    tracks.forEach(track => Array.from(track.cues).forEach(cue => {
      // Respect captions which already have an authored position.
      if (!this.captionPositions.has(cue)) {
        if (cue.line !== "auto") return;
        this.captionPositions.set(cue, { line: cue.line, snapToLines: cue.snapToLines, lineAlign: cue.lineAlign });
      }
      // Chromium positions percentage cues by their top even with lineAlign=end.
      // Reserve at least two default cue lines so the whole caption clears controls.
      const lines = Math.max(2, cue.text.split("\n").length);
      const line = Math.max(0, Math.min(95, (bottom - top - 16) / height * 100 - lines * 6));
      const position = nativeDisplay || !remoteVisible ? this.captionPositions.get(cue) : { line, snapToLines: false, lineAlign: "start" };
      Object.entries(position).forEach(([key, value]) => { if (cue[key] !== value) cue[key] = value; });
    }));
  }

  toggleSubtitles() {
    const tracks = this.subtitleTracks();
    if (tracks.length === 0) return;
    const showing = this.allSubtitleTracks().find(track => track.mode === "showing");
    if (showing) {
      this.lastSubtitlePreference = { language: showing.language, label: showing.label };
      this.subtitlePreference = null;
    } else {
      const selected = this.preferredSubtitle(tracks, this.lastSubtitlePreference) || tracks[0];
      this.subtitlePreference = { language: selected.language, label: selected.label };
    }
    this.syncSubtitles(true);
    this.showRemote();
  }

  stop() {
    clearTimeout(this.remoteTimeout);
    this.remoteInteraction = false;
    this.stageTarget.classList.remove("lm-controls-hidden");
    this.remoteTarget.inert = false;
    const wasPlaying = this.videoActive;
    this.setVideoActive(false);
    this.playbackGeneration += 1;
    this.cancelSpeech();
    this.closeMenus();
    if (!this.playerTarget.paused) this.playerTarget.pause();
    if (this.playerTarget.readyState > 0 && this.playerTarget.currentTime > 0) this.playerTarget.currentTime = 0;
    this.exitFullscreen();
    this.stageTarget.classList.remove("fixed", "inset-0", "z-[60]", "rounded-none");
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
    if (!this.videoActive) return;
    this.remoteTarget.hidden = false;
    this.errorTarget.hidden = false;
    this.showRemote();
  }
}
