import { patch, post } from "@rails/request.js";
import type { ss_student } from "../declarations.d.ts";

export async function createStudent(
  student: ss_student,
  orgId: number,
  index: number
) {
  return await post(`/organisations${orgId}/ss_student_uploads`, {
    body: {
      index: index,
      ss_student_upload: {
        name: student.name,
        en_name: student.en_name,
        student_id: student.student_id,
        level: student.level,
        quit_date: student.quit_date,
        birthday: student.birthday,
        status: student.status,
        land_1_date: student.land_1_date,
        land_2_date: student.land_2_date,
        sky_1_date: student.sky_1_date,
        sky_2_date: student.sky_2_date,
        galaxy_1_date: student.galaxy_1_date,
        galaxy_2_date: student.galaxy_2_date,
      },
    },
  });
}
