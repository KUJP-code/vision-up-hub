import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["items", "linkTemplate", "videoTemplate", "faqTemplate"];

  connect() {
    this.index = Date.now();
  }

  add(event) {
    const kind = event.params.kind;
    const template = this[`${kind}TemplateTarget`];
    const content = template.innerHTML.replaceAll("CHILD", `${this.index++}`);
    this.itemsTarget.insertAdjacentHTML("beforeend", content);
  }

  remove(event) {
    event.currentTarget.closest("[data-resource-item]")?.remove();
  }
}
