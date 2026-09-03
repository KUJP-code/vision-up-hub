import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["player", "ready", "remote", "startButton", "playButton", "time", "error", "errorMessage"];
  static values = { videoId: String };

  connect() {
    this.playing = false;
    this.playerVisible = true;
    this.loadYouTubeApi();
  }

  disconnect() {
    window.clearInterval(this.timeTimer);
    if (this.player?.destroy) this.player.destroy();
  }

  loadYouTubeApi() {
    if (window.YT?.Player) return this.createPlayer();

    window.youtubeApiReadyCallbacks ||= [];
    window.youtubeApiReadyCallbacks.push(() => this.createPlayer());

    if (document.querySelector("script[data-youtube-iframe-api]")) return;

    const script = document.createElement("script");
    script.src = "https://www.youtube.com/iframe_api";
    script.dataset.youtubeIframeApi = "true";
    document.head.appendChild(script);
    window.onYouTubeIframeAPIReady = () => {
      window.youtubeApiReadyCallbacks.splice(0).forEach((callback) => callback());
    };
  }

  createPlayer() {
    if (!this.hasPlayerTarget || this.player) return;

    this.player = new window.YT.Player(this.playerTarget, {
      videoId: this.videoIdValue,
      playerVars: { playsinline: 1, rel: 0 },
      events: {
        onReady: () => { this.startButtonTarget.disabled = false; },
        onStateChange: (event) => this.stateChanged(event),
        onError: () => this.showError("YouTube could not load this video. Use the original-video link below to confirm it is available.")
      }
    });
  }

  start() {
    if (!this.player?.playVideo) return this.showError("The YouTube player is still loading. Please wait a moment and try again.");

    this.player.playVideo();
    this.readyTarget.classList.add("hidden");
    this.remoteTarget.classList.remove("hidden");
    this.timeTimer = window.setInterval(() => this.updateTime(), 500);
  }

  togglePlayback() {
    if (this.playing) this.player.pauseVideo();
    else this.player.playVideo();
  }

  async back() { this.seekBy(-5); }
  async forward() { this.seekBy(5); }

  seekBy(seconds) {
    const currentTime = Number(this.player?.getCurrentTime?.() || 0);
    this.player?.seekTo?.(Math.max(0, currentTime + seconds), true);
    this.updateTime();
  }

  stop() {
    this.player?.stopVideo?.();
    this.resetRemote();
  }

  showPlayer() {
    this.playerVisible = !this.playerVisible;
    this.readyTarget.classList.toggle("hidden", !this.playerVisible);
    this.remoteTarget.classList.toggle("hidden", this.playerVisible);
  }

  stateChanged(event) {
    this.playing = event.data === window.YT.PlayerState.PLAYING;
    this.playButtonTarget.textContent = this.playing ? "⏸ Pause" : "▶ Play";
    if (event.data === window.YT.PlayerState.ENDED) this.resetRemote();
  }

  updateTime() {
    const seconds = Math.max(0, Math.floor(Number(this.player?.getCurrentTime?.() || 0)));
    const minutes = Math.floor(seconds / 60);
    this.timeTarget.textContent = `${minutes}:${String(seconds % 60).padStart(2, "0")}`;
  }

  resetRemote() {
    window.clearInterval(this.timeTimer);
    this.readyTarget.classList.remove("hidden");
    this.remoteTarget.classList.add("hidden");
    this.playing = false;
    this.playButtonTarget.textContent = "▶ Play";
    this.updateTime();
  }

  showError(message) {
    this.errorMessageTarget.textContent = message;
    this.errorTarget.classList.remove("hidden");
  }
}
