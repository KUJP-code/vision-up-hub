import type { status, student } from "./declarations.d.ts";

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
const pendingClasses = ["border-slate-500"];
const rowClasses = ["border"];
const validClasses = ["border-green-500"];

export function newStudentUploadTable() {
	return `
			<table class="w-full text-center">
				<thead>
					<tr>
						<th>Name</th>
						<th>Student ID</th>
						<th>Level</th>
						<th>School ID</th>
						<th>Parent ID</th>
						<th>Start Date</th>
						<th>Quit Date</th>
						<th>Birthday</th>
						<th>Status</th>
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
	status = "pending",
}: { csvStudent: student; index: number; status?: status }) {
	const table = document.querySelector("#student-table");
	const row = document.createElement("tr");
	row.id = `student-row-${index}`;
	if (validateStudent(csvStudent)) {
		row.classList.add(...pendingClasses);
	} else {
		row.classList.add(...invalidClasses);
		status = "invalid";
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
	return student.name && student.level && student.school_id;
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
	switch (status) {
		case "uploaded":
			iconText = "download_done";
			break;
		case "invalid":
			iconText = "warning";
			break;
		case "pending":
			iconText = "hourglass_empty";
			break;
		case "error":
			iconText = "error";
			break;
	}
	return `
		<td>
			${status}
			<span class="material-symbols-outlined">${iconText}</span>
		</td>
	`;
}
