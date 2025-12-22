import { post } from "@rails/request.js";
import type { course_lesson } from "../declarations.d.ts";

export async function createCourseLesson(
  courseLesson: course_lesson,
  courseId: number,
  index: number,
) {
  return await post(`/courses/${courseId}/course_lesson_uploads`, {
    body: {
      index: index,
      course_lesson_upload: {
        lesson_id: courseLesson.lesson_id,
        week: courseLesson.week,
        day: courseLesson.day,
      },
    },
    responseKind: "turbo-stream",
  });
}
