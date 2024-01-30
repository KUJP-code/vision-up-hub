import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="flash"
export default class extends Controller {
  static targets = ["container"];

  connect() {
    const hideTimer = setTimeout(() => {
      this.fadeOut();
    }, 2000);
    this.containerTarget.addEventListener("mouseenter", () => {
      clearTimeout(hideTimer);
    });
    this.containerTarget.addEventListener("mouseleave", () => {
      this.fadeOut();
    });
  }

  dismiss() {
    this.fadeOut();
  }

  fadeOut() {
    this.containerTarget.classList.add("opacity-0");
    setTimeout(() => {
      this.containerTarget.classList.add("hidden");
    }, 300);
  }
}
