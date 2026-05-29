import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  hide() {
    document.getElementById("teacher-tools-panel")?.remove();
  }
}
