import type { status } from "../declarations.d.ts";
import type { student } from "./student_uploader_controller.ts";

const requiredFields = ["name", "level", "school_id"];

// Css constants
const invalidClasses = [
	"border",
	"border-red-500",
	"text-red-500",
	"font-bold",
];
const missingClasses = [
	"border-yellow-500",
	"text-yellow-500",
	"font-semibold",
];
const pendingClasses = [
	"border",
	"border-slate-800",
	"bg-slate-100",
	"border-slate-500",
	"text-color-secondary",
];

export function newStudentUploadTable() {
	return `
			<table class="w-full text-center">
				<thead>
					<tr>
						<th class="p-2 bg-color-main/50 rounded-s-lg border-r border-r-white">Name</th>
						<th class="p-2 bg-color-main/50 border-r border-r-white">Student ID</th>
						<th class="p-2 bg-color-main/50 border-r border-r-white">Level</th>
						<th class="p-2 bg-color-main/50 border-r border-r-white">School ID</th>
						<th class="p-2 bg-color-main/50 border-r border-r-white">Parent ID</th>
						<th class="p-2 bg-color-main/50 border-r border-r-white">Start Date</th>
						<th class="p-2 bg-color-main/50 border-r border-r-white">Quit Date</th>
						<th class="p-2 bg-color-main/50 border-r border-r-white">Birthday</th>
						<th class="p-2 bg-color-main/50 rounded-e-lg">Status</th>
					</tr>
				</thead>
				<tbody id="student-table">
				</tbody>
			</table>
			`;
}

export function addStudentRow({
	csvStudent,
	index,
	status = "Pending",
}: { csvStudent: student; index: number; status?: status }) {
	const table = document.querySelector("#student-table");
	const row = document.createElement("tr");
	row.id = `student-row-${index}`;
	if (validateStudent(csvStudent)) {
		row.classList.add(...pendingClasses);
	} else {
		row.classList.add(...invalidClasses);
		status = "Invalid";
	}

	if (status === "Error") {
		row.classList.add(...invalidClasses);
	}

	let rowContents = "";
	for (const attribute of Object.keys(csvStudent)) {
		rowContents += attributeCellHTML(csvStudent, attribute);
	}
	rowContents += statusIndicatorHTML(status);
	row.innerHTML = rowContents;

	if (table) {
		table.appendChild(row);
	} else {
		alert("Could not find table element");
		return;
	}
}

function validateStudent(student: student) {
	return requiredFields.every((field) => student[field]);
}

function attributeCellHTML(student: student, attribute: string) {
	if (requiredFields.includes(attribute)) {
		return `
			<td>${student[attribute] || "なし"}</td>

	`;
	}

	return `
		<td class="p-2 ${student[attribute] ? "" : missingClasses.join(" ")}">${
			student[attribute] || "なし"
		}</td>
	`;
}

function statusIndicatorHTML(status: status) {
	let iconText = "";
	let animation = "";
	switch (status) {
		case "Uploaded":
			iconText = "download_done";
			break;
		case "Invalid":
			iconText = "warning";
			animation = "animate-pulse";
			break;
		case "Pending":
			iconText = "hourglass_empty";
			animation = "animate-spin";
			break;
		case "Error":
			iconText = "error";
			animation = "animate-pulse";
			break;
	}
	return `
		<td class="flex items-center justify-center gap-2 p-2">
			<p>${status}</p>
			<span class="material-symbols-outlined ${animation}">${iconText}</span>
		</td>
	`;
}
