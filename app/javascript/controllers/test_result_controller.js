import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="test-result"
export default class extends Controller {
	static targets = [
		"basics",
		"listenPercent",
		"listening",
		"newLevel",
		"prevLevel",
		"readPercent",
		"reading",
		"reason",
		"speakPercent",
		"speaking",
		"totalPercent",
		"writePercent",
		"writing",
	];

	static values = {
		basics: Number,
		thresholds: Object,
		questions: Object,
	};

	connect() {
		this.thresholds = this.thresholdsValue;
		this.questions = this.questionsValue;
		this.setSkillMaxes();
		this.calculate();
	}

	setSkillMaxes() {
		const skillMaxes = [];
		if (this.hasListeningTarget) {
			this.listeningMax = this.questions.listening.reduce(
				(total, maxScore) => total + maxScore,
				0,
			);
			skillMaxes.push(this.listeningMax);
		}
		if (this.hasReadingTarget) {
			this.readingMax = this.questions.reading.reduce(
				(total, maxScore) => total + maxScore,
				0,
			);
			skillMaxes.push(this.readingMax);
		}
		if (this.hasSpeakingTarget) {
			this.speakingMax = this.questions.speaking.reduce(
				(total, maxScore) => total + maxScore,
				0,
			);
			skillMaxes.push(this.speakingMax);
		}
		if (this.hasWritingTarget) {
			this.writingMax = this.questions.writing.reduce(
				(total, maxScore) => total + maxScore,
				0,
			);
			skillMaxes.push(this.writingMax);
		}
		this.maxScore =
			skillMaxes.reduce((total, max) => total + max, 0) + this.basicsValue;
	}

	calculate() {
		const basicsScore = Number.parseInt(this.basicsTarget.value);
		const listeningScore = this.calcSkillPercent(
			this.listeningTargets,
			this.listeningMax,
			this.listenPercentTargets,
		);
		const readingScore = this.calcSkillPercent(
			this.readingTargets,
			this.readingMax,
			this.readPercentTargets,
		);
		const speakingScore = this.calcSkillPercent(
			this.speakingTargets,
			this.speakingMax,
			this.speakPercentTargets,
		);
		const writingScore = this.calcSkillPercent(
			this.writingTargets,
			this.writingMax,
			this.writePercentTargets,
		);
		const totalScore =
			listeningScore +
			readingScore +
			speakingScore +
			writingScore +
			basicsScore;
		const totalPercent = Math.round((totalScore / this.maxScore) * 100);

		this.setTotalPercent(totalPercent);
		this.setNewLevel(totalPercent);
	}

	calcSkillPercent(targets, maxScore, outputs) {
		const total = targets.reduce(
			(total, target) => total + (Number.parseInt(target.value) || 0),
			0,
		);
		const percentage = Math.round((total / maxScore) * 100);
		for (const target of outputs) {
			if (target.nodeName === "INPUT") {
				target.value = percentage;
			} else {
				target.textContent = `${percentage}%`;
			}
		}
		return total;
	}

	setTotalPercent(totalPercent) {
		for (const target of this.totalPercentTargets) {
			if (target.nodeName === "INPUT") {
				target.value = totalPercent;
			} else {
				target.textContent = `${totalPercent}%`;
			}
		}
	}

	setNewLevel(totalPercent) {
		const eveningCourses = ["Specialist", "Specialist Advanced"];
		const prevLevel = { lvl: this.prevLevelTarget.value, percent: 0 };
		const rec = Object.entries(this.thresholds).reduce((rec, threshold) => {
			const [lvl, percent] = threshold;
			if (percent > totalPercent || rec.percent > percent) {
				return rec;
			}
			return { lvl, percent };
		}, prevLevel);

		if (eveningCourses.includes(rec.lvl)) {
			this.flagEvening();
			rec.lvl = "Galaxy Two";
		} else {
			this.unflagEvening();
		}

		this.newLevel = rec.lvl.toLowerCase().replace(" ", "_");
		this.newLevelTarget.value = this.newLevel;
	}

	flagEvening() {
		if (this.element.querySelector(".evening")) return;

		this.element.classList.add("bg-green-300");
		this.newLevelTarget.insertAdjacentHTML(
			"afterend",
			`<p class="text-secondary rounded bg-white font-bold evening">
				Specialist Check Required
			</p>`,
		);
	}

	unflagEvening() {
		this.element.classList.remove("bg-green-300");
		this.element.querySelector(".evening")?.remove();
	}

	checkRecommendedLevel() {
		if (this.newLevelTarget.value !== this.newLevel) {
			this.reasonTarget.classList.remove("hidden");
			this.newLevelTarget.classList.add("border-yellow-300", "text-yellow-600");
		} else {
			this.reasonTarget.classList.add("hidden");
			this.newLevelTarget.classList.remove(
				"border-yellow-300",
				"text-yellow-600",
			);
		}
	}

	markDone(event) {
	if (event.detail.success) {
		this.element.classList.add("form-done");
	}
	}
}