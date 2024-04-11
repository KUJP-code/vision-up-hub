import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="scroll-to"
export default class extends Controller {
	connect() {
		this.element.addEventListener("click", (e) => {
			e.preventDefault();
			const target = document.querySelector(this.element.hash);
			target.scrollIntoView({ behavior: "smooth", inline: "start" });
		});
	}
}
