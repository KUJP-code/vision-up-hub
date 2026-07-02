import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { dialog: String, frame: String, src: String };

  connect() {
    this.dialogEl = document.getElementById(this.dialogValue);
    this.frameEl = document.getElementById(this.frameValue);

    if (!this.dialogEl) return;

    this._onClose = () => {
      if (!this.frameEl) return;

      this.stopEmbeddedMedia();
      this.frameEl.removeAttribute("src");
      this.frameEl.innerHTML = "";

      this.removeBackdropClick();
    };
    this._onBeforeCache = () => this.closeBeforeCache();

    this.dialogEl.addEventListener("close", this._onClose);
    this.dialogEl.addEventListener("cancel", this._onClose);
    document.addEventListener("turbo:before-cache", this._onBeforeCache);
  }

  disconnect() {
    if (!this.dialogEl) return;
    this.dialogEl.removeEventListener("close", this._onClose);
    this.dialogEl.removeEventListener("cancel", this._onClose);
    document.removeEventListener("turbo:before-cache", this._onBeforeCache);
    this.removeBackdropClick();
  }

  open(e) {
    e.preventDefault();

    if (!this.dialogEl || !this.frameEl) return;

    // Load frame content.
    this.frameEl.src = this.srcValue;

    // Open modal.
    if (typeof this.dialogEl.showModal === "function") {
      this.dialogEl.showModal();
    } else {
      this.dialogEl.setAttribute("open", "open");
    }

    this.addBackdropClick();
  }

  addBackdropClick() {
    this.removeBackdropClick();

    // Click backdrop to close: the event target is the <dialog> itself
    this._onBackdropClick = (evt) => {
      if (evt.target === this.dialogEl) this.dialogEl.close();
    };
    this.dialogEl.addEventListener("click", this._onBackdropClick);
  }

  removeBackdropClick() {
    if (!this._onBackdropClick) return;

    this.dialogEl.removeEventListener("click", this._onBackdropClick);
    this._onBackdropClick = null;
  }

  stopEmbeddedMedia() {
    this.frameEl.querySelectorAll("iframe").forEach((iframe) => {
      iframe.src = "";
    });

    this.frameEl.querySelectorAll("video, audio").forEach((mediaEl) => {
      mediaEl.pause();
      mediaEl.currentTime = 0;
      mediaEl.removeAttribute("src");
      mediaEl.load();
    });
  }

  closeBeforeCache() {
    if (!this.dialogEl.open) return;

    this.dialogEl.close();
  }
}
