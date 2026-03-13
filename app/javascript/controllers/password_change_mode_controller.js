import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["panel", "label", "input", "menu"];

  connect() {
    this.update();
  }

  update() {
    const selectedMode = this.inputTarget.value;

    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.mode !== selectedMode);
    });
  }

  setMode(event) {
    const { mode, label } = event.currentTarget.dataset;

    this.inputTarget.value = mode;
    this.labelTarget.textContent = label;
    this.update();

    if (this.hasMenuTarget) {
      this.menuTarget.open = false;
    }
  }
}
