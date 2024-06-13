import { Controller } from "@hotwired/stimulus";
import Papa from "papaparse";
import { addTeacherRow, newTeacherUploadTable } from "./table.ts";
import { createTeacher, updateTeacher } from "./api.ts";
import { newUploadSummary } from "../summary.ts";

export interface teacher {
	name: string;
	email: string;
	password: string;
}

// Connects to data-controller="teacher-uploader"
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

	async displayTeachers(e: SubmitEvent) {
		e.preventDefault();
		let csv: string | undefined;
		if (this.fileInputTarget?.files) {
			csv = await this.fileInputTarget.files[0].text();
		}
		if (csv === undefined) {
			alert("Please select a CSV file");
			return;
		}
		const teachers: teacher[] = await this.parseCSV(csv);

		const main = document.querySelector("main");
		if (main) {
			main.innerHTML = newTeacherUploadTable();
			main.prepend(newUploadSummary(teachers.length));
		} else {
			alert("Could not find main element");
			return;
		}
		for (const [i, s] of teachers.entries()) {
			addTeacherRow({
				csvTeacher: s,
				index: i,
				headers: this.headersValue.concat("Password Confirmation"),
			});
		}

		this.uploadTeachers(teachers);
	}

	parseCSV(csv: string): Promise<teacher[]> {
		return new Promise((resolve, reject) => {
			Papa.parse<teacher>(csv, {
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

	async uploadTeachers(teachers: teacher[]) {
		while (teachers.length > 0) {
			const index = teachers.length - 1;
			const delay = new Promise((resolve) => setTimeout(resolve, 500));
			const teacher = teachers.pop();
			if (teacher === undefined) continue;
			this.actionValue === "create"
				? await createTeacher(teacher, this.orgValue, index)
				: await updateTeacher(teacher, this.orgValue, index);
			await delay;
		}
	}
}
