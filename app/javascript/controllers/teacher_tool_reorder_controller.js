import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["item", "list", "submit"];

  connect() {
    this.draggedItem = null;
    this.disableSubmit();
  }

  dragStart(event) {
    this.draggedItem = event.currentTarget;
    this.draggedItem.classList.add("opacity-60");
    event.dataTransfer.effectAllowed = "move";
  }

  dragOver(event) {
    event.preventDefault();
    if (!this.draggedItem) return;

    const target = event.currentTarget;
    if (target === this.draggedItem) return;

    const rect = target.getBoundingClientRect();
    const insertAfter = event.clientY > rect.top + rect.height / 2 ||
      (Math.abs(event.clientY - (rect.top + rect.height / 2)) < rect.height / 2 &&
        event.clientX > rect.left + rect.width / 2);

    if (insertAfter) {
      target.after(this.draggedItem);
    } else {
      target.before(this.draggedItem);
    }
  }

  drop(event) {
    event.preventDefault();
    this.enableSubmit();
  }

  dragEnd() {
    this.draggedItem?.classList.remove("opacity-60");
    this.draggedItem = null;
    this.enableSubmit();
  }

  moveLeft(event) {
    const item = event.currentTarget.closest("[data-teacher-tool-reorder-target='item']");
    const previous = item?.previousElementSibling;
    if (!item || !previous) return;

    previous.before(item);
    this.enableSubmit();
  }

  moveRight(event) {
    const item = event.currentTarget.closest("[data-teacher-tool-reorder-target='item']");
    const next = item?.nextElementSibling;
    if (!item || !next) return;

    next.after(item);
    this.enableSubmit();
  }

  enableSubmit() {
    this.submitTarget.disabled = false;
  }

  disableSubmit() {
    this.submitTarget.disabled = true;
  }
}
