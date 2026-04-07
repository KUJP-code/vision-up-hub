import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = [
		"target",
		"template",
		"englishHomework",
		"levelSelect",
		"subtypeSelect",
	];
	static values = {
		wrapperSelector: {
			type: String,
			default: ".fields-wrapper",
		},
	};

	connect() {
		this.toggleEnglishHomework();
		this.toggleSubtypeOptions();
	}

	add(e) {
		e.preventDefault();

		const content = this.templateTarget.innerHTML.replace(
			/CHILD/g,
			new Date().getTime().toString(),
		);
		this.targetTarget.insertAdjacentHTML("beforebegin", content);
	}

	remove(e) {
		e.preventDefault();

		const wrapper = e.target.closest(this.wrapperSelectorValue);

		if (wrapper.dataset.newRecord === "true") {
			wrapper.remove();
		} else {
			wrapper.style.display = "none";

			const input = wrapper.querySelector("input[name*='_destroy']");
			input.value = "1";
		}
	}

	toggleEnglishHomework() {
		if (!this.hasEnglishHomeworkTarget || !this.hasLevelSelectTarget) return;

		this.englishHomeworkTarget.style.display =
			this.levelSelectTarget.value === "kindy" ? "none" : "";
	}

	toggleSubtypeOptions() {
		if (!this.hasSubtypeSelectTarget || !this.hasLevelSelectTarget) return;

		const level = this.levelSelectTarget.value;
		let selectedVisible = false;

		Array.from(this.subtypeSelectTarget.options).forEach((option) => {
			if (option.value === "") {
				option.disabled = false;
				option.hidden = false;
				return;
			}

			const levels = option.dataset.levels?.split(",") || [];
			const visible = levels.includes(level);

			option.disabled = !visible;
			option.hidden = !visible;

			if (visible && option.selected) selectedVisible = true;
			if (!visible && option.selected) option.selected = false;
		});

		if (!selectedVisible) this.subtypeSelectTarget.value = "";
	}
}
