import type { status } from "../declarations.d.ts";
import type { teacher } from "./teacher_uploader_controller.ts";

const requiredFields = ["name", "email", "password", "password_confirmation"];

// Css constants
const invalidClasses = ["border", "border-danger", "text-danger", "font-bold"];
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
	"text-secondary",
];

export function newTeacherUploadTable() {
	return `
			<table class="w-full text-center">
				<thead>
					<tr>
						<th class="thead thead-s bg-secondary-50">Name</th>
						<th class="thead bg-secondary-50">Email</th>
						<th class="thead bg-secondary-50">Password</th>
						<th class="thead bg-secondary-50">Password Confirmation</th>
						<th class="thead thead-e bg-secondary-50">Status</th>
					</tr>
				</thead>
				<tbody id="teacher-table">
				</tbody>
			</table>
			`;
}

export function addTeacherRow({
	csvTeacher,
	index,
	status = "Pending",
}: { csvTeacher: teacher; index: number; status?: status }) {
	const table = document.querySelector("#teacher-table");
	const row = document.createElement("tr");
	row.id = `teacher-row-${index}`;
	if (validateTeacher(csvTeacher)) {
		row.classList.add(...pendingClasses);
	} else {
		row.classList.add(...invalidClasses);
		status = "Invalid";
	}

	if (status === "Error") {
		row.classList.add(...invalidClasses);
	}

	let rowContents = "";
	for (const attribute of Object.keys(csvTeacher)) {
		rowContents += attributeCellHTML(csvTeacher, attribute);
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

function validateTeacher(teacher: teacher) {
	return requiredFields.every((field) => teacher[field]);
}

function attributeCellHTML(teacher: teacher, attribute: string) {
	if (requiredFields.includes(attribute)) {
		return `
			<td>${teacher[attribute] || "なし"}</td>

	`;
	}

	return `
		<td class="p-2 ${teacher[attribute] ? "" : missingClasses.join(" ")}">${teacher[attribute] || "なし"
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
