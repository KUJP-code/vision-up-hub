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

export interface ss_student {
  name: string;
  en_name: string;
  student_id: string;
  level: string;
  quit_date: string;
  birthday: string;
  status: string;
  land_1_date: string;
  land_2_date: string;
  sky_1_date: string;
  sky_2_date: string;
  galaxy_1_date: string;
  galaxy_2_date: string;
}

export interface teacher {
  name: string;
  email: string;
  password: string;
}
