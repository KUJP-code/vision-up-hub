import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["item"];
  static values = { url: String, param: String };

  connect() {
    this.draggedItem = null;
  }

  dragStart(event) {
    this.draggedItem = event.currentTarget;
    this.draggedItem.classList.add("opacity-60");
    event.dataTransfer.effectAllowed = "move";
  }

  dragOver(event) {
    event.preventDefault();
    if (!this.draggedItem || event.currentTarget === this.draggedItem) return;

    const target = event.currentTarget;
    const rect = target.getBoundingClientRect();
    const after = event.clientY > rect.top + rect.height / 2 ||
      event.clientX > rect.left + rect.width / 2;
    target[after ? "after" : "before"](this.draggedItem);
  }

  drop(event) {
    event.preventDefault();
    this.persist();
  }

  dragEnd() {
    this.draggedItem?.classList.remove("opacity-60");
    this.draggedItem = null;
  }

  async persist() {
    const ids = this.itemTargets.map((item) => item.dataset.reorderId);
    const token = document.querySelector("meta[name='csrf-token']")?.content;

    await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept": "application/json",
      },
      body: JSON.stringify({ [this.paramValue]: ids }),
    });
  }
}
