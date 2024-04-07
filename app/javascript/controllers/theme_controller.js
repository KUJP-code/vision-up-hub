import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="theme"
export default class extends Controller {
	static targets = ["html"];

	switch(e) {
		e.preventDefault();
		this.htmlTarget.classList.remove(...this.htmlTarget.classList);
		this.htmlTarget.classList.add(e.target.dataset.theme);
	}
}
