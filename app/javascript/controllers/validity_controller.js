import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="validity"
export default class extends Controller {
  static targets = ["input"];

  validate() {
    if (this.inputTarget.reportValidity() && this.withinRange()) {
      this.inputTarget.classList.remove(
        "border-neutral-dark",
        "border-danger",
        "border-2"
      );
      this.inputTarget.classList.add("border-success");
    } else {
      this.inputTarget.classList.add("border-danger", "border-2");
      this.inputTarget.classList.remove(
        "border-neutral-dark",
        "border-success"
      );
    }
  }

  withinRange() {
    if (this.inputTarget.type !== "number") {
      return true;
    }

    const value = Number.parseInt(this.inputTarget.value);
    return value >= this.inputTarget.min && value <= this.inputTarget.max;
  }
}
