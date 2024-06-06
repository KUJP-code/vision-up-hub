import type { status } from "../declarations.d.ts";
import type { student } from "./student_uploader_controller.ts";

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

export function newStudentUploadTable() {
	return `
			<table class="w-full text-center">
				<thead>
					<tr>
						<th class="thead thead-s bg-secondary-50">Name</th>
						<th class="thead bg-secondary-50">Student ID</th>
						<th class="thead bg-secondary-50">Level</th>
						<th class="thead bg-secondary-50">School ID</th>
						<th class="thead bg-secondary-50">Parent ID</th>
						<th class="thead bg-secondary-50">Start Date</th>
						<th class="thead bg-secondary-50">Quit Date</th>
						<th class="thead bg-secondary-50">Birthday</th>
						<th class="thead thead-e bg-secondary-50">Status</th>
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
	headers,
	status = "Pending",
}: { csvStudent: student; index: number; headers: string[]; status?: status }) {
	const table = document.querySelector("#student-table");
	const row = document.createElement("tr");
	row.id = `student-row-${index}`;
	row.classList.add(...pendingClasses);

	if (status === "Error") {
		row.classList.add(...invalidClasses);
	}

	let rowContents = "";
	for (const attribute of headers) {
		rowContents += attributeCellHTML(csvStudent, attribute, headers);
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

function attributeCellHTML(
	student: student,
	attribute: string,
	headers: string[],
) {
	if (headers.includes(attribute)) {
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
