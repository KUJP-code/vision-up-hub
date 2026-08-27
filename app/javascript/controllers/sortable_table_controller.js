import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["body", "indicator"];

  sort(event) {
    const column = Number(event.params.column);
    const type = event.params.type;
    const sameColumn = this.column === column;
    this.direction = sameColumn && this.direction === "asc" ? "desc" : "asc";
    this.column = column;

    const rows = Array.from(this.bodyTarget.rows);
    rows.sort((left, right) => {
      const leftValue = left.cells[column].dataset.sortValue || "";
      const rightValue = right.cells[column].dataset.sortValue || "";
      const comparison = this.compare(leftValue, rightValue, type);
      return this.direction === "asc" ? comparison : -comparison;
    });
    rows.forEach((row) => this.bodyTarget.appendChild(row));

    this.indicatorTargets.forEach((indicator, index) => {
      indicator.textContent = index === column ? (this.direction === "asc" ? "▲" : "▼") : "";
    });
  }

  compare(left, right, type) {
    if (type === "number") return this.number(left) - this.number(right);
    if (type === "date") return Date.parse(left) - Date.parse(right);
    return left.localeCompare(right, undefined, { numeric: true, sensitivity: "base" });
  }

  number(value) {
    const parsed = Number.parseFloat(value);
    return Number.isNaN(parsed) ? Number.NEGATIVE_INFINITY : parsed;
  }
}
