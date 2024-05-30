import { patch, post } from "@rails/request.js";
import type { teacher } from "./teacher_uploader_controller";

export async function createTeacher(
	teacher: teacher,
	orgId: number,
	index: number,
) {
	return await post(`/organisations/${orgId}/teacher_uploads`, {
		body: {
			index: index,
			teacher_upload: {
				name: teacher.name,
				email: teacher.email,
				password: teacher.password,
			},
		},
		responseKind: "turbo-stream",
	});
}

export async function updateTeacher(
	teacher: teacher,
	orgId: number,
	index: number,
) {
	return await patch(`/organisations/${orgId}/teacher_uploads`, {
		body: {
			index: index,
			teacher_upload: {
				name: teacher.name,
				email: teacher.email,
				password: teacher.password,
			},
		},
		responseKind: "turbo-stream",
	});
}
