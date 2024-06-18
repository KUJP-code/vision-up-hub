import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	connect() {
		this.detailElements = document.querySelectorAll("details");
		console.log(this.detailElements);
	}

	focus() {
		console.log(this.detailElements);
	}
}
