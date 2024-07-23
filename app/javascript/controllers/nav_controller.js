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
			<svg id="hamburger_x" data-name="hamburger x" xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="35 30 65 70" class="w-8 h-14">
			<defs>
			<style>
			.cls-1 {
				fill: #aadaeb;
				stroke-width: 0px;
			}
			</style>
			</defs>
			<path class="cls-1" d="M54.568,83.182c-.704,0-1.408-.269-1.944-.806-1.074-1.074-1.074-2.815,0-3.889l25.863-25.863c1.073-1.074,2.815-1.074,3.889,0,1.074,1.074,1.074,2.815,0,3.889l-25.863,25.863c-.537.537-1.241.806-1.944.806Z"/>
			<path class="cls-1" d="M80.432,83.182c-.704,0-1.408-.269-1.944-.806l-25.863-25.863c-1.074-1.074-1.074-2.815,0-3.889,1.073-1.074,2.815-1.074,3.889,0l25.863,25.863c1.074,1.074,1.074,2.815,0,3.889-.537.537-1.241.806-1.944.806Z"/>
			</svg>
			`;
	}
}
