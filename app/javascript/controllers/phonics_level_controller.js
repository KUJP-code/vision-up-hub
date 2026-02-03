import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["levelSelect", "galaxyField", "nonGalaxyField"];

	connect() {
		this.updateVisibility();
	}

	levelChanged() {
		this.updateVisibility();
	}

	updateVisibility() {
		if (!this.hasLevelSelectTarget) {
			return;
		}

		const isGalaxy = this.isGalaxyLevel();

		this.toggleFields(this.galaxyFieldTargets, isGalaxy);
		this.toggleFields(this.nonGalaxyFieldTargets, !isGalaxy);
	}

	isGalaxyLevel() {
		const level = this.levelSelectTarget.value;
		return ["galaxy_one", "galaxy_two", "galaxy_three"].includes(level);
	}

	toggleFields(targets, show) {
		targets.forEach((element) => {
			element.classList.toggle("hidden", !show);
			element
				.querySelectorAll("input, textarea, select")
				.forEach((field) => {
					field.disabled = !show;
				});
		});
	}
}
