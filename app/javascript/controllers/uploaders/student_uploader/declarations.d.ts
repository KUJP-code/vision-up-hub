export type status = "Error" | "Invalid" | "Pending" | "Uploaded";

export interface student {
	name: string;
	student_id: string;
	level: string;
	school_id: string;
	parent_id: string;
	start_date: string;
	quit_date: string;
	birthday: string;
}
