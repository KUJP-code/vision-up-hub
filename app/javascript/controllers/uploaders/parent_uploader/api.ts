import { patch, post } from "@rails/request.js";
import type { parent } from "./parent_uploader_controller";

export async function createParent(
	parent: parent,
	orgId: number,
	index: number,
) {
	return await post(`/organisations/${orgId}/parent_uploads`, {
		body: {
			index: index,
			parent_upload: {
				name: parent.name,
				email: parent.email,
				password: parent.password,
			},
		},
		responseKind: "turbo-stream",
	});
}

export async function updateParent(
	parent: parent,
	orgId: number,
	index: number,
) {
	return await patch(`/organisations/${orgId}/parent_uploads`, {
		body: {
			index: index,
			parent_upload: {
				name: parent.name,
				email: parent.email,
				password: parent.password,
			},
		},
		responseKind: "turbo-stream",
	});
}
