import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["currentPath", "folderName"];

	create(e) {
		e.preventDefault();
		const origin = window.location.origin;
		const pathname = window.location.pathname;
		const currentPath = this.currentPathTarget.value;
		const folderName = this.folderNameTarget.value;
		window.location.href = `${origin}/${pathname}?path=${currentPath}/${folderName}`;
	}
}
