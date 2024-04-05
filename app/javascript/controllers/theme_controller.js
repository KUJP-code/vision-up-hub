import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="theme"
export default class extends Controller {
	static targets = ["html", "themeSwitcher"];

	connect() {
		this.htmlTarget.classList.add("blue");
		this.htmlTarget.dataset.theme = "blue";
	}
}
