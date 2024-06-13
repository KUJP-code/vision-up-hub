import {
	attributeCellHTML,
	invalidClasses,
	pendingClasses,
	statusIndicatorHTML,
	tableHeader,
} from "../table.ts";

import type { status } from "../declarations.d.ts";
import type { parent } from "./parent_uploader_controller.ts";

export function newParentUploadTable(headers: string[]) {
	headers.splice(headers.indexOf("password"), 0, "password_confirmation");
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
				<tbody id="parent-table">
				</tbody>
			</table>
			`;
}

export function addParentRow({
	csvParent,
	index,
	headers,
	status = "Pending",
}: { csvParent: parent; index: number; headers: string[]; status?: status }) {
	const table = document.querySelector("#parent-table");
	const row = document.createElement("tr");
	row.id = `parent-row-${index}`;
	row.classList.add(...pendingClasses);

	if (status === "Error") {
		row.classList.add(...invalidClasses);
	}

	let rowContents = "";
	for (const attribute of headers) {
		rowContents += attributeCellHTML(csvParent, attribute, headers);
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
