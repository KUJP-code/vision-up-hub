import { Controller } from "@hotwired/stimulus";
import Papa from "papaparse";
import { newCourseLessonUploadTable } from "./table.ts";
import { addRow } from "../table.ts";
import { createCourseLesson } from "./api.ts";
import { newUploadSummary } from "../summary.ts";

import type { course_lesson } from "../declarations.d.ts";

// Connects to data-controller="course-lesson-uploader"
export default class extends Controller<HTMLFormElement> {
  static targets = ["fileInput"];
  static values = {
    course: Number,
    headers: Array,
  };

  declare readonly fileInputTarget: HTMLInputElement;
  declare readonly courseValue: number;
  declare readonly headersValue: string[];

  async displayCourseLessons(e: SubmitEvent) {
    e.preventDefault();
    let csv: string | undefined;
    if (this.fileInputTarget?.files) {
      csv = await this.fileInputTarget.files[0].text();
    }
    if (csv === undefined) {
      alert("Please select a CSV file");
      return;
    }
    const courseLessons: course_lesson[] = await this.parseCSV(csv);

    const main = document.querySelector("main");
    if (main) {
      main.innerHTML = newCourseLessonUploadTable(this.headersValue);
      main.prepend(newUploadSummary(courseLessons.length));
    } else {
      alert("Could not find main element");
      return;
    }
    for (const [i, courseLesson] of courseLessons.entries()) {
      addRow({
        csvRecord: courseLesson,
        index: i,
        headers: this.headersValue,
        uploadType: "course-lesson",
      });
    }

    this.uploadCourseLessons(courseLessons);
  }

  parseCSV(csv: string): Promise<course_lesson[]> {
    return new Promise((resolve, reject) => {
      Papa.parse<course_lesson>(csv, {
        header: true,
        skipEmptyLines: true,
        fastMode: true,
        complete(results) {
          resolve(results.data);
        },
        error(err: Error) {
          reject(err);
        },
      });
    });
  }

  async uploadCourseLessons(courseLessons: course_lesson[]) {
    while (courseLessons.length > 0) {
      const index = courseLessons.length - 1;
      const delay = new Promise((resolve) => setTimeout(resolve, 10));
      const courseLesson = courseLessons.pop();
      if (courseLesson === undefined) continue;
      await createCourseLesson(courseLesson, this.courseValue, index);
      await delay;
    }
  }
}
