import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="popover"
export default class extends Controller {
	static targets = ["popoverId"];

	connect() {}
}
