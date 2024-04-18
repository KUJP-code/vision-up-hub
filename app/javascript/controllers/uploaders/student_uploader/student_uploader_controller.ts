import { Controller } from "@hotwired/stimulus";
import Papa from "papaparse";
import type { student } from "./declarations.d.ts";
import { addStudentRow, newStudentUploadTable } from "./table.ts";

// Connects to data-controller="student-uploader"
export default class extends Controller<HTMLFormElement> {
	static targets = ["fileInput"];
	static values = {
		requiredFields: Array,
	};

	declare readonly fileInputTarget: HTMLInputElement;

	async displayStudents(e: SubmitEvent) {
		e.preventDefault();
		let csv: string | undefined;
		if (this.fileInputTarget?.files) {
			csv = await this.fileInputTarget.files[0].text();
		}
		if (csv === undefined) {
			alert("Please select a CSV file");
			return;
		}
		const students: student[] = await this.parseCSV(csv);

		const main = document.querySelector("main");
		if (main) {
			main.innerHTML = newStudentUploadTable();
		} else {
			alert("Could not find main element");
			return;
		}
		for (const s of students) {
			addStudentRow(s);
		}
	}

	parseCSV(csv: string): Promise<student[]> {
		return new Promise((resolve, reject) => {
			Papa.parse<student>(csv, {
				header: true,
				skipEmptyLines: true,
				fastMode: true,
				complete(results) {
					resolve(results.data);
				},
				error(err: Error) {
					reject(err);
				},
			});
		});
	}
}
