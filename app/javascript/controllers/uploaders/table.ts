import type { parent, student, teacher } from "./declarations.d.ts";
import type { status } from "./declarations.d.ts";

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

export function addRow({
  csvRecord,
  index,
  headers,
  uploadType,
  status = "Pending",
}: {
  csvRecord: student | parent | teacher;
  index: number;
  headers: string[];
  uploadType: "student" | "parent" | "teacher";
  status?: status;
}) {
  const table = document.querySelector(`#${uploadType}-table`);
  const row = document.createElement("tr");
  row.id = `${uploadType}-row-${index}`;
  row.classList.add(...pendingClasses);

  if (status === "Error") {
    row.classList.add(...invalidClasses);
  }

  let rowContents = "";
  for (const attribute of headers) {
    rowContents += attributeCellHTML(csvRecord, attribute, headers);
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

export function attributeCellHTML(
  record: student | parent | teacher,
  attribute: string,
  headers: string[]
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

export function statusIndicatorHTML(status: status) {
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

export function tableHeader(title: string, index: number) {
  if (index === 0) {
    return `<th class="thead thead-s bg-secondary-50">${title}</th>`;
  }

  return `<th class="thead bg-secondary-50">${title}</th>`;
}
