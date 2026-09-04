import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["player", "setup", "remote", "playButton", "time", "error"];

  connect() {
    this.events = new AbortController();
    const options = { signal: this.events.signal };

    this.playerTarget.addEventListener("play", () => this.updatePlayButton(), options);
    this.playerTarget.addEventListener("pause", () => this.updatePlayButton(), options);
    this.playerTarget.addEventListener("timeupdate", () => this.updateTime(), options);
    this.playerTarget.addEventListener("ended", () => this.stop(), options);
    this.playerTarget.addEventListener("error", () => this.showError(), options);
  }

  disconnect() {
    this.events?.abort();
  }

  start() {
    this.playerTarget.play().then(() => {
      this.setupTarget.classList.add("hidden");
      this.remoteTarget.classList.remove("hidden");
    }).catch(() => this.showError());
  }

  togglePlayback() {
    if (this.playerTarget.paused) {
      this.playerTarget.play().catch(() => this.showError());
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
    this.playerTarget.pause();
    this.playerTarget.currentTime = 0;
    this.setupTarget.classList.remove("hidden");
    this.remoteTarget.classList.add("hidden");
    this.updateTime();
  }

  updatePlayButton() {
    this.playButtonTarget.textContent = this.playerTarget.paused ? "▶ Play" : "⏸ Pause";
  }

  updateTime() {
    const seconds = Math.max(0, Math.floor(Number(this.playerTarget.currentTime || 0)));
    const minutes = Math.floor(seconds / 60);
    this.timeTarget.textContent = `${minutes}:${String(seconds % 60).padStart(2, "0")}`;
  }

  showError() {
    this.errorTarget.classList.remove("hidden");
  }
}
