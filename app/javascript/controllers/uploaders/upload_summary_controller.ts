import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="upload-summary"
export default class extends Controller {
	static values = {
		status: String,
	};

	declare readonly statusValue: string;

	connect() {
		this.statusValue === "Uploaded"
			? this.incrementStatus("success_count")
			: this.incrementStatus("error_count");
		this.decrementPending();
	}

	incrementStatus(id: string) {
		const count = document.getElementById(id);
		if (count) {
			count.innerHTML = String(Number.parseInt(count.innerHTML) + 1);
		}
	}

	decrementPending() {
		const count = document.getElementById("pending_count");
		if (count && Number.parseInt(count.innerHTML) > 0) {
			count.innerHTML = String(Number.parseInt(count.innerHTML) - 1);
		}
	}
}
