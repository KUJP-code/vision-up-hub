import { Controller } from "@hotwired/stimulus";

interface planData {
	[courseId: string]: {
		[orgName: string]: {
			startDate: string;
		};
	};
}

// Connects to data-controller="course-lessons"
export default class extends Controller {
	static values = {
		plans: Object,
	};

	static targets = ["date", "day", "week"];

	declare readonly plansValue: planData;
	declare readonly dateTarget: HTMLUListElement;
	declare readonly dayTarget: HTMLSelectElement;
	declare readonly weekTarget: HTMLInputElement;

	connect() {
		this.calculateDate();
	}

	calculateDate() {
		this.dateTarget.innerHTML = "";
		const { week, day } = this.dateValues();
		for (const courseId in this.plansValue) {
			for (const orgName in this.plansValue[courseId]) {
				const plan = this.plansValue[courseId][orgName];
				const startDate = new Date(Date.parse(plan.startDate));

				this.dateTarget.insertAdjacentHTML(
					"beforeend",
					`<li>${orgName}: ${this.lessonDate(startDate, week, day)}</li>`,
				);
			}
		}
	}

	dateValues() {
		const dayMap = {
			sunday: 0,
			monday: 1,
			tuesday: 2,
			wednesday: 3,
			thursday: 4,
			friday: 5,
			saturday: 6,
		};

		const week = Number.parseInt(this.weekTarget.value) || 0;
		const day = Number.parseInt(dayMap[this.dayTarget.value]);

		return { week, day };
	}

	lessonDate(startDate: Date, week: number, day: number) {
		const date = new Date(
			startDate.setDate(
				startDate.getDate() + week * 7 + (day - startDate.getDay()),
			),
		);

		return date.toLocaleDateString();
	}
}
