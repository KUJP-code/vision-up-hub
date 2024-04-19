import { Controller } from "@hotwired/stimulus";
import Papa from "papaparse";
import type { student } from "./declarations.d.ts";
import { addStudentRow, newStudentUploadTable } from "./table.ts";
import { createStudent, updateStudent } from "./api.ts";

// Connects to data-controller="student-uploader"
export default class extends Controller<HTMLFormElement> {
	static targets = ["fileInput"];
	static values = {
		org: Number,
		action: String,
	};

	declare readonly fileInputTarget: HTMLInputElement;
	declare readonly orgValue: number;
	declare readonly actionValue: "create" | "update";

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
		for (const [i, s] of students.entries()) {
			addStudentRow({ csvStudent: s, index: i });
		}
		while (students.length > 0) {
			const index = students.length - 1;
			const student = students.pop();
			if (student === undefined) break;
			const response =
				this.actionValue === "create"
					? await createStudent(student, this.orgValue)
					: await updateStudent(student, this.orgValue);
			if (response.statusCode === 200) {
				document.querySelector(`#student-row-${index}`)?.remove();
				addStudentRow({ csvStudent: student, index, status: "Uploaded" });
			} else {
				document.querySelector(`#student-row-${index}`)?.remove();
				addStudentRow({ csvStudent: student, index, status: "Error" });
			}
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
