import { Controller } from "@hotwired/stimulus";
import Papa from "papaparse";

// Connects to data-controller="student-uploader"
export default class extends Controller {
	static targets = ["fileInput"];

	async upload(e) {
		e.preventDefault();
		const file = this.fileInputTarget.files[0];
		const result = await this.parseCSV(file);
		document.querySelector("main").innerText = JSON.stringify(result);
	}

	parseCSV(file) {
		return new Promise((resolve, reject) => {
			Papa.parse(file, {
				header: true,
				complete(results) {
					resolve(results.data);
				},
				error(err) {
					reject(err);
				},
			});
		});
	}
}
