import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["kindSelect", "videoField", "externalField"];

  connect() {
    this.toggle();
  }

  toggle() {
    const isVideo = this.kindSelectTarget.value === "video";
    this.videoFieldTarget.style.display = isVideo ? "" : "none";
    this.externalFieldTarget.style.display = isVideo ? "none" : "";
  }
}
