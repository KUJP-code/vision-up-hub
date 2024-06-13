import type { student } from "./student_uploader/student_uploader_controller";
import type { teacher } from "./teacher_uploader/teacher_uploader_controller";
import type { parent } from "./parent_uploader/parent_uploader_controller";

export const invalidClasses = [
	"border",
	"border-danger",
	"text-danger",
	"font-bold",
];

export const missingClasses = [
	"border-yellow-500",
	"text-yellow-500",
	"font-semibold",
];
export const pendingClasses = [
	"border",
	"border-slate-800",
	"bg-slate-100",
	"border-slate-500",
	"text-secondary",
];
export function tableHeader(title: string, index: number) {
	if (index === 0) {
		return `<th class="thead thead-s bg-secondary-50">${title}</th>`;
	}

	return `<th class="thead bg-secondary-50">${title}</th>`;
}

export function attributeCellHTML(
	record: student | parent | teacher,
	attribute: string,
	headers: string[],
) {
	if (headers.includes(attribute)) {
		return `<td>${record[attribute] || "なし"}</td>`;
	}

	return `
		<td class="p-2 ${record[attribute] ? "" : missingClasses.join(" ")}">
		  ${record[attribute] || "なし"}
		</td>
	`;
}
