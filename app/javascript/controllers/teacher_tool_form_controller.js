import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["kindSelect", "videoField", "externalField", "externalInput", "videoLinks", "videoLinkTemplate", "videoLinkInput"];

  connect() {
    this.toggle();
  }

  toggle() {
    const isVideo = this.kindSelectTarget.value === "video";
    this.videoFieldTarget.style.display = isVideo ? "" : "none";
    this.externalFieldTarget.style.display = isVideo ? "none" : "";
    this.externalInputTarget.required = !isVideo;
    this.syncVideoLinkRequirements(isVideo);
  }

  addVideoLink(event) {
    event.preventDefault();

    const content = this.videoLinkTemplateTarget.innerHTML.replace(
      /CHILD/g,
      new Date().getTime().toString(),
    );
    this.videoLinksTarget.insertAdjacentHTML("beforeend", content);
    this.syncVideoLinkRequirements();
  }

  removeVideoLink(event) {
    event.preventDefault();
    event.target.closest(".teacher-tool-video-link")?.remove();
    this.syncVideoLinkRequirements();
  }

  syncVideoLinkRequirements(isVideo = this.kindSelectTarget.value === "video") {
    this.videoLinkInputTargets.forEach((input, index) => {
      input.required = isVideo && index === 0;
    });
  }
}
