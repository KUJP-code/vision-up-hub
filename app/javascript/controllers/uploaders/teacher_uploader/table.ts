import {
	attributeCellHTML,
	invalidClasses,
	pendingClasses,
	statusIndicatorHTML,
	tableHeader,
} from "../table.ts";

import type { status } from "../declarations.d.ts";
import type { teacher } from "./teacher_uploader_controller.ts";

export function newTeacherUploadTable(headers: string[]) {
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
				<tbody id="teacher-table">
				</tbody>
			</table>
			`;
}
