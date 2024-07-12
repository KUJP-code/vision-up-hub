import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="dialog"
export default class extends Controller {
	static values = { id: String };

	connect() {
		this.dialog = document.getElementById(this.idValue);
	}

	open() {
		this.dialog.showModal();
	}
}
