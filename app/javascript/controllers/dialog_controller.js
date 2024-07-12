import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="dialog"
export default class extends Controller {
	static values = { dialog: String, frame: String, src: String };

	connect() {
		this.dialog = document.getElementById(this.dialogValue);
		this.frame = document.getElementById(this.frameValue);
	}

	open() {
		this.frame.src = this.srcValue;
		this.dialog.showModal();
	}
}
