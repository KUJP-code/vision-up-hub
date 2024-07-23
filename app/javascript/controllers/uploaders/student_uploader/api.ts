import { patch, post } from "@rails/request.js";
import type { student } from "../declarations.d.ts";

export async function createStudent(
	student: student,
	orgId: number,
	index: number,
) {
	return await post(`/organisations/${orgId}/student_uploads`, {
		body: {
			index: index,
			student_upload: {
				name: student.name,
				en_name: student.en_name,
				student_id: student.student_id,
				level: student.level,
				school_id: student.school_id,
				parent_id: student.parent_id,
				start_date: student.start_date,
				quit_date: student.quit_date,
				birthday: student.birthday,
			},
		},
		responseKind: "turbo-stream",
	});
}

export async function updateStudent(
	student: student,
	orgId: number,
	index: number,
) {
	return await patch(`/organisations/${orgId}/student_uploads`, {
		body: {
			index: index,
			student_upload: {
				name: student.name,
				en_name: student.en_name,
				student_id: student.student_id,
				level: student.level,
				school_id: student.school_id,
				parent_id: student.parent_id,
				start_date: student.start_date,
				quit_date: student.quit_date,
				birthday: student.birthday,
			},
		},
		responseKind: "turbo-stream",
	});
}
