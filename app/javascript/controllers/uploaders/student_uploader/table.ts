import {
	attributeCellHTML,
	invalidClasses,
	pendingClasses,
	statusIndicatorHTML,
	tableHeader,
} from "../table.ts";

import type { status } from "../declarations.d.ts";
import type { student } from "./student_uploader_controller.ts";

export function newStudentUploadTable(headers: string[]) {
	let headerString = headers
		.map((header) => tableHeader(header, headers.indexOf(header)))
		.join("");
	headerString += `<th class="thead thead-e bg-secondary-50">status</th>`;

	return `
			<table class="w-full text-center">
				<thead>
					<tr>
						${headerString}
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
