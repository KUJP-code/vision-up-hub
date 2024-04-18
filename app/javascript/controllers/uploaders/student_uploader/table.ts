import type { student } from "./declarations.d.ts";

export function newStudentUploadTable() {
	return `
			<table class="w-full">
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
}: { csvStudent: student; index: number; status?: string }) {
	const table = document.querySelector("#student-table");
	const row = document.createElement("tr");
	row.id = `student-row-${index}`;
	row.innerHTML = `
			<td>${csvStudent.name}</td>
			<td>${csvStudent.student_id}</td>
			<td>${csvStudent.level}</td>
			<td>${csvStudent.school_id}</td>
			<td>${csvStudent.parent_id}</td>
			<td>${csvStudent.start_date}</td>
			<td>${csvStudent.quit_date}</td>
			<td>${csvStudent.birthday}</td>
			<td>${status}</td>
			`;
	if (table) {
		table.appendChild(row);
	} else {
		alert("Could not find table element");
		return;
	}
}
