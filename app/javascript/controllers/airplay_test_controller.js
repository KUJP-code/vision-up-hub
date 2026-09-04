import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["player", "ready", "remote", "startButton", "routeButton", "playButton", "time", "status", "error", "errorMessage"];
  static values = { source: String };

  connect() {
    this.events = new AbortController();
    const options = { signal: this.events.signal };

    this.playerTarget.addEventListener("play", () => this.playbackChanged(true), options);
    this.playerTarget.addEventListener("pause", () => this.playbackChanged(false), options);
    this.playerTarget.addEventListener("timeupdate", () => this.updateTime(), options);
    this.playerTarget.addEventListener("ended", () => this.stop(), options);
    this.playerTarget.addEventListener("error", () => this.mediaError(), options);
    this.playerTarget.addEventListener("webkitplaybacktargetavailabilitychanged", (event) => this.availabilityChanged(event), options);
    this.playerTarget.addEventListener("webkitcurrentplaybacktargetiswirelesschanged", () => this.routeChanged(), options);

    if (typeof this.playerTarget.webkitShowPlaybackTargetPicker !== "function") {
      this.startButtonTarget.disabled = true;
      this.statusTarget.textContent = "Open this page in Safari on an iPad to run the AirPlay test.";
    } else {
      this.startButtonTarget.disabled = false;
    }
  }

  disconnect() {
    window.clearTimeout(this.routeTimer);
    window.clearTimeout(this.restoreTimer);
    this.events?.abort();
  }

  start() {
    if (typeof this.playerTarget.webkitShowPlaybackTargetPicker !== "function") {
      return this.showError("This browser cannot open Apple's AirPlay device picker. Use Safari on the iPad.");
    }

    this.playerTarget.play().catch(() => {
      this.showError("Playback did not start. Tap Play again, or use Choose Apple TV.");
    });

    this.statusTarget.textContent = "Starting video on the current mirrored Apple TV…";
    window.clearTimeout(this.routeTimer);
    this.routeTimer = window.setTimeout(() => {
      if (!this.playerTarget.webkitCurrentPlaybackTargetIsWireless) {
        this.routeButtonTarget.classList.remove("hidden");
        this.statusTarget.textContent = "The current mirror did not take over. Use the fallback selector below.";
      }
    }, 2000);
  }

  chooseTarget() {
    // Apple requires the route picker to be opened directly from a user gesture.
    this.playerTarget.webkitShowPlaybackTargetPicker();
  }

  togglePlayback() {
    if (this.playerTarget.paused) {
      this.playerTarget.play().catch(() => this.showError("The video could not resume."));
    } else {
      this.playerTarget.pause();
    }
  }

  back() { this.seekBy(-5); }
  forward() { this.seekBy(5); }

  seekBy(seconds) {
    this.playerTarget.currentTime = Math.max(0, this.playerTarget.currentTime + seconds);
    this.updateTime();
  }

  stop() {
    window.clearTimeout(this.routeTimer);
    this.playerTarget.pause();
    this.playerTarget.currentTime = 0;

    // Reloading tears down the media's wireless playback session so the existing
    // Control Centre screen-mirroring session can become visible again.
    this.playerTarget.removeAttribute("src");
    this.playerTarget.load();
    window.clearTimeout(this.restoreTimer);
    this.restoreTimer = window.setTimeout(() => this.restoreSource(), 2000);
    this.showReady();
  }

  restoreSource() {
    if (this.playerTarget.getAttribute("src")) return;

    this.playerTarget.src = this.sourceValue;
    this.playerTarget.load();
  }

  availabilityChanged(event) {
    const available = event.availability === "available";
    this.statusTarget.textContent = available
      ? "Apple TV available. Start the video using the current mirror."
      : "No AirPlay device found. Check that the iPad and Apple TV are on the same network.";
  }

  routeChanged() {
    if (this.playerTarget.webkitCurrentPlaybackTargetIsWireless) {
      window.clearTimeout(this.routeTimer);
      this.readyTarget.classList.add("hidden");
      this.remoteTarget.classList.remove("hidden");
      this.routeButtonTarget.classList.add("hidden");
      this.statusTarget.textContent = "Video is playing directly on the Apple TV.";
    } else {
      this.restoreSource();
      this.showReady();
    }
  }

  playbackChanged(playing) {
    this.playButtonTarget.textContent = playing ? "⏸ Pause" : "▶ Play";
  }

  updateTime() {
    const seconds = Math.max(0, Math.floor(Number(this.playerTarget.currentTime || 0)));
    const minutes = Math.floor(seconds / 60);
    this.timeTarget.textContent = `${minutes}:${String(seconds % 60).padStart(2, "0")}`;
  }

  showReady() {
    this.readyTarget.classList.remove("hidden");
    this.remoteTarget.classList.add("hidden");
    this.routeButtonTarget.classList.add("hidden");
    this.playbackChanged(false);
    this.updateTime();
  }

  mediaError() {
    if (this.playerTarget.networkState === HTMLMediaElement.NETWORK_NO_SOURCE) {
      this.showError("The HLS test video could not be loaded. Check the iPad's internet connection.");
    }
  }

  showError(message) {
    this.errorMessageTarget.textContent = message;
    this.errorTarget.classList.remove("hidden");
  }
}
