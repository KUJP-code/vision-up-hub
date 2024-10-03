import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="nav-reveal"
export default class extends Controller {
	static targets = ["toggleIcon"];

	connect() {
		this.hamburger = this.toggleIconTarget.innerHTML;
	}

	toggle() {
		if (this.element.classList.contains("open")) {
			this.toggleIconTarget.innerHTML = this.hamburger;
			this.element.classList.remove("open");
		} else {
			this.toggleIconTarget.innerHTML = this.closeSvg();
			this.element.classList.add("open");
		}
	}

	closeSvg() {
		return `
			<path d="M54.568,83.182c-.704,0-1.408-.269-1.944-.806-1.074-1.074-1.074-2.815,0-3.889l25.863-25.863c1.073-1.074,2.815-1.074,3.889,0,1.074,1.074,1.074,2.815,0,3.889l-25.863,25.863c-.537.537-1.241.806-1.944.806Z"/>
			<path d="M80.432,83.182c-.704,0-1.408-.269-1.944-.806l-25.863-25.863c-1.074-1.074-1.074-2.815,0-3.889,1.073-1.074,2.815-1.074,3.889,0l25.863,25.863c1.074,1.074,1.074,2.815,0,3.889-.537.537-1.241.806-1.944.806Z"/>
			`;
	}
}
