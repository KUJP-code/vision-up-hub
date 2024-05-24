import type { status } from "../declarations.d.ts";
import type { parent } from "./parent_uploader_controller.ts";

const requiredFields = ["name", "email", "password", "password_confirmation"];

// Css constants
const invalidClasses = [
	"border",
	"border-danger",
	"text-danger",
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
	"text-secondary",
];

export function newParentUploadTable() {
	return `
			<table class="w-full text-center">
				<thead>
					<tr>
						<th class="p-2 bg-main-50 rounded-s border-r border-r-white">Name</th>
						<th class="p-2 bg-main-50 border-r border-r-white">Email</th>
						<th class="p-2 bg-main-50 border-r border-r-white">Password</th>
						<th class="p-2 bg-main-50 border-r border-r-white">Password Confirmation</th>
						<th class="p-2 bg-main-50 rounded-e">Status</th>
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
	status = "Pending",
}: { csvParent: parent; index: number; status?: status }) {
	const table = document.querySelector("#parent-table");
	const row = document.createElement("tr");
	row.id = `parent-row-${index}`;
	if (validateParent(csvParent)) {
		row.classList.add(...pendingClasses);
	} else {
		row.classList.add(...invalidClasses);
		status = "Invalid";
	}

	if (status === "Error") {
		row.classList.add(...invalidClasses);
	}

	let rowContents = "";
	for (const attribute of Object.keys(csvParent)) {
		rowContents += attributeCellHTML(csvParent, attribute);
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

function validateParent(parent: parent) {
	return requiredFields.every((field) => parent[field]);
}

function attributeCellHTML(parent: parent, attribute: string) {
	if (requiredFields.includes(attribute)) {
		return `
			<td>${parent[attribute] || "なし"}</td>

	`;
	}

	return `
		<td class="p-2 ${parent[attribute] ? "" : missingClasses.join(" ")}">${parent[attribute] || "なし"
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
