import { Controller } from "@hotwired/stimulus";
import Papa from "papaparse";
import { newStudentUploadTable } from "./table.ts";
import { addRow } from "../table.ts";
import { createStudent, updateStudent } from "./api.ts";
import { newUploadSummary } from "../summary.ts";

import type { student } from "../declarations.d.ts";

// Connects to data-controller="student-uploader"
export default class extends Controller<HTMLFormElement> {
  static targets = ["fileInput"];
  static values = {
    org: Number,
    action: String,
    headers: Array,
  };

  declare readonly fileInputTarget: HTMLInputElement;
  declare readonly orgValue: number;
  declare readonly actionValue: "create" | "update";
  declare readonly headersValue: string[];

  async displayStudents(e: SubmitEvent) {
    e.preventDefault();
    let csv: string | undefined;
    if (this.fileInputTarget?.files) {
      csv = await this.fileInputTarget.files[0].text();
    }
    if (csv === undefined) {
      alert("Please select a CSV file");
      return;
    }
    const students: student[] = await this.parseCSV(csv);

    const main = document.querySelector("main");
    if (main) {
      main.innerHTML = newStudentUploadTable(this.headersValue);
      main.prepend(newUploadSummary(students.length));
    } else {
      alert("Could not find main element");
      return;
    }
    for (const [i, student] of students.entries()) {
      addRow({
        csvRecord: student,
        headers: this.headersValue,
        index: i,
        uploadType: "student",
      });
    }

    this.uploadStudents(students);
  }

  parseCSV(csv: string): Promise<student[]> {
    return new Promise((resolve, reject) => {
      Papa.parse<student>(csv, {
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

  async uploadStudents(students: student[]) {
    while (students.length > 0) {
      const index = students.length - 1;
      const delay = new Promise((resolve) => setTimeout(resolve, 10));
      const student = students.pop();
      if (student === undefined) continue;
      this.actionValue === "create"
        ? await createStudent(student, this.orgValue, index)
        : await updateStudent(student, this.orgValue, index);
      await delay;
    }
  }
}
