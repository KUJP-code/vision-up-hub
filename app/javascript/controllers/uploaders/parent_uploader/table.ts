import {
	attributeCellHTML,
	invalidClasses,
	pendingClasses,
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
