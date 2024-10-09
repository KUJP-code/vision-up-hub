export type status = "Error" | "Invalid" | "Pending" | "Uploaded";

export interface parent {
  name: string;
  email: string;
  password: string;
}

export interface student {
  name: string;
  en_name: string;
  student_id: string;
  level: string;
  school_id: string;
  parent_id: string;
  start_date: string;
  quit_date: string;
  birthday: string;
  organisation_id: string;
}

export interface teacher {
  name: string;
  email: string;
  password: string;
}
