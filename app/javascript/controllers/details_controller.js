import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	focus(e) {
		const openDetails = document.querySelectorAll("details[open]");
		for (const element of openDetails) {
			if (element === e.target.parentNode) continue;

			element.open = false;
		}
	}
}
