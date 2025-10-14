import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { dialog: String, frame: String, src: String };

  connect() {
    this.dialogEl = document.getElementById(this.dialogValue);
    this.frameEl = document.getElementById(this.frameValue);

    if (!this.dialogEl) return;

    this._onClose = () => {
      if (this.frameEl) this.frameEl.src = "";
    };
    this.dialogEl.addEventListener("close", this._onClose);
    this.dialogEl.addEventListener("cancel", this._onClose);
  }

  disconnect() {
    if (!this.dialogEl) return;
    this.dialogEl.removeEventListener("close", this._onClose);
    this.dialogEl.removeEventListener("cancel", this._onClose);
  }

  open(e) {
    e.preventDefault();

    if (!this.dialogEl || !this.frameEl) return;

    // Load video
    this.frameEl.src = this.srcValue;

    // Open
    if (typeof this.dialogEl.showModal === "function") {
      this.dialogEl.showModal();
    } else {
      this.dialogEl.setAttribute("open", "open");
    }

    // Click backdrop to close: the event target is the <dialog> itself
    this._onBackdropClick = (evt) => {
      if (evt.target === this.dialogEl) this.dialogEl.close();
    };
    this.dialogEl.addEventListener("click", this._onBackdropClick);
  }
}
