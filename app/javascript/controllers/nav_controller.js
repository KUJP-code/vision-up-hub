import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="nav-reveal"
export default class extends Controller {
	static targets = ["links"];

	toggle() {
		this.linksTarget.classList.toggle("revealed");
	}
}
