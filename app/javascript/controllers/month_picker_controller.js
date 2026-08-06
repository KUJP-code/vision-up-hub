import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  open() {
    if (typeof this.element.showPicker !== "function") return;

    this.element.showPicker();
  }
}
