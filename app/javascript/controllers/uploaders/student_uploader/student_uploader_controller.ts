import { Controller } from "@hotwired/stimulus";
import Papa from "papaparse";
import { addStudentRow, newStudentUploadTable } from "./table.ts";
import { createStudent, updateStudent } from "./api.ts";
import { newUploadSummary } from "../summary.ts";

export interface student {
	name: string;
	en_name: string;
	student_id: string;
	level: string;
	school_id: string;
	parent_id: string;
	start_date: string;
	quit_date: string;
	birthday: string;
}

// Connects to data-controller="student-uploader"
export default class extends Controller<HTMLFormElement> {
	static targets = ["fileInput"];
	static values = {
		org: Number,
		action: String,
		headers: Array,
	};

	declare readonly fileInputTarget: HTMLInputElement;
	declare readonly orgValue: number;
	declare readonly actionValue: "create" | "update";
	declare readonly headersValue: string[];

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
			main.innerHTML = newStudentUploadTable(this.headersValue);
			main.prepend(newUploadSummary(students.length));
		} else {
			alert("Could not find main element");
			return;
		}
		for (const [i, s] of students.entries()) {
			addStudentRow({ csvStudent: s, headers: this.headersValue, index: i });
		}

		this.uploadStudents(students);
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

	async uploadStudents(students: student[]) {
		while (students.length > 0) {
			const index = students.length - 1;
			const delay = new Promise((resolve) => setTimeout(resolve, 100));
			const student = students.pop();
			if (student === undefined) continue;
			this.actionValue === "create"
				? await createStudent(student, this.orgValue, index)
				: await updateStudent(student, this.orgValue, index);
			await delay;
		}
	}
}
