import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="test-result"
export default class extends Controller {
	static targets = [
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
		thresholds: Object,
		questions: Object,
	};

	connect() {
		this.thresholds = this.thresholdsValue;
		this.questions = this.questionsValue;
		this.setSkillMaxes();
	}

	setSkillMaxes() {
		this.listeningMax = this.questions.listening.reduce(
			(total, maxScore) => total + maxScore,
			0,
		);
		this.readingMax = this.questions.reading.reduce(
			(total, maxScore) => total + maxScore,
			0,
		);
		this.speakingMax = this.questions.speaking.reduce(
			(total, maxScore) => total + maxScore,
			0,
		);
		this.writingMax = this.questions.writing.reduce(
			(total, maxScore) => total + maxScore,
			0,
		);
		this.maxScore =
			this.listeningMax + this.readingMax + this.speakingMax + this.writingMax;
	}

	calculate() {
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
			listeningScore + readingScore + speakingScore + writingScore;
		const totalPercent = Math.ceil((totalScore / this.maxScore) * 100);

		this.setTotalPercent(totalPercent);
		this.setNewLevel(totalPercent);
	}

	calcSkillPercent(targets, maxScore, outputs) {
		const total = targets.reduce(
			(total, target) => total + (Number.parseInt(target.value) || 0),
			0,
		);
		const percentage = Math.ceil((total / maxScore) * 100);
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
		const prevLevel = this.prevLevelTarget.value;
		const newLevel = Object.entries(this.thresholds).reduce(
			(level, threshold) => {
				if (totalPercent < threshold[1]) {
					return level;
				}
				return threshold[0];
			},
			prevLevel,
		);
		this.newLevel = newLevel;
		this.newLevelTarget.value = newLevel.toLowerCase().replace(" ", "_");
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
}
