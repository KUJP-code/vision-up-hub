import { Controller } from "@hotwired/stimulus";
import Papa from "papaparse";
import { addParentRow, newParentUploadTable } from "./table.ts";
import { createParent, updateParent } from "./api.ts";
import { newUploadSummary } from "../summary.ts";

export interface parent {
	name: string;
	email: string;
	password: string;
}

// Connects to data-controller="parent-uploader"
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

	async displayParents(e: SubmitEvent) {
		e.preventDefault();
		let csv: string | undefined;
		if (this.fileInputTarget?.files) {
			csv = await this.fileInputTarget.files[0].text();
		}
		if (csv === undefined) {
			alert("Please select a CSV file");
			return;
		}
		const parents: parent[] = await this.parseCSV(csv);

		const main = document.querySelector("main");
		if (main) {
			main.innerHTML = newParentUploadTable();
			main.prepend(newUploadSummary(parents.length));
		} else {
			alert("Could not find main element");
			return;
		}
		for (const [i, s] of parents.entries()) {
			addParentRow({
				csvParent: s,
				headers: this.headersValue.concat("Password Confirmation"),
				index: i,
			});
		}

		this.uploadParents(parents);
	}

	parseCSV(csv: string): Promise<parent[]> {
		return new Promise((resolve, reject) => {
			Papa.parse<parent>(csv, {
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

	async uploadParents(parents: parent[]) {
		while (parents.length > 0) {
			const index = parents.length - 1;
			const parent = parents.pop();
			if (parent === undefined) continue;
			this.actionValue === "create"
				? await createParent(parent, this.orgValue, index)
				: await updateParent(parent, this.orgValue, index);
		}
	}
}
