import { tableHeader } from "../table.ts";

export function newCourseLessonUploadTable(headers: string[]) {
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
				<tbody id="course-lesson-table">
				</tbody>
			</table>
			`;
}
