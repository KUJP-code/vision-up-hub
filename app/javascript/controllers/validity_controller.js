import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="validity"
export default class extends Controller {
	static targets = ["input"];

	validate() {
		console.log(this.inputTarget.reportValidity(), this.withinRange());
		if (this.inputTarget.reportValidity() && this.withinRange()) {
			this.inputTarget.classList.remove(
				"border-ku-gray-500",
				"border-red-500",
				"border-2",
			);
			this.inputTarget.classList.add("border-green-500");
		} else {
			this.inputTarget.classList.add("border-red-500", "border-2");
			this.inputTarget.classList.remove(
				"border-ku-gray-500",
				"border-green-500",
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
