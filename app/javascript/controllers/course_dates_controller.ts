import { Controller } from "@hotwired/stimulus";

interface planData {
	[courseId: string]: {
		[orgName: string]: {
			startDate: string;
		};
	};
}

// Connects to data-controller="course-dates"
export default class extends Controller {
	static values = {
		plans: Object,
	};

	static targets = ["course", "date", "day", "week"];

	declare readonly plansValue: planData;
	declare readonly courseTarget: HTMLSelectElement;
	declare readonly dateTarget: HTMLUListElement;
	declare readonly hasDayTarget: boolean;
	declare readonly dayTarget: HTMLSelectElement;
	declare readonly weekTarget: HTMLInputElement;

	connect() {
		this.calculateDate();
	}

	calculateDate() {
		this.dateTarget.innerHTML = "";
		const { id, week, days } = this.selectValues();
		for (const courseId in this.plansValue) {
			if (id !== courseId) continue;

			for (const orgName in this.plansValue[courseId]) {
				const plan = this.plansValue[courseId][orgName];
				const startDate = new Date(Date.parse(plan.startDate));
				const dates = days.map((day) => this.lessonDate(new Date(startDate), week, day));
				const label = dates.join(", ");

				this.dateTarget.insertAdjacentHTML("beforeend", `<li>${orgName}: ${label}</li>`);
			}
		}
	}

	selectValues() {
		const dayMap = {
			sunday: 0,
			monday: 1,
			tuesday: 2,
			wednesday: 3,
			thursday: 4,
			friday: 5,
			saturday: 6,
		};

		const shortcutMap = {
			all_weekdays: [1, 2, 3, 4, 5],
			all_week: [0, 1, 2, 3, 4, 5, 6],
		};

		const id = this.courseTarget.value;
		const week = Number.parseInt(this.weekTarget.value) - 1 || 0;
		const days = this.hasDayTarget
			? shortcutMap[this.dayTarget.value] ||
				[Number.parseInt(dayMap[this.dayTarget.value])]
			: [0];

		return { id, week, days };
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
