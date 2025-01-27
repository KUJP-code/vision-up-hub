import { Controller } from "@hotwired/stimulus";
import Papa from "papaparse";
import { newSsStudentUploadTable } from "./table.ts";
import { addRow } from "../table.ts";
import { createSsStudent, updateSsStudent } from "./api.ts";
import { newUploadSummary } from "../summary.ts";

import type { ss_student } from "../declarations.d.ts";

// Connects to data-controller="ss_student-uploader"
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

  async displaySsStudents(e: SubmitEvent) {
    e.preventDefault();
    let csv: string | undefined;
    if (this.fileInputTarget?.files) {
      csv = await this.fileInputTarget.files[0].text();
    }
    if (csv === undefined) {
      alert("Please select a CSV file");
      return;
    }
    const ss_students: ss_student[] = await this.parseCSV(csv);

    const main = document.querySelector("main");
    if (main) {
      main.innerHTML = newSsStudentUploadTable(this.headersValue);
      main.prepend(newUploadSummary(ss_students.length));
    } else {
      alert("Could not find main element");
      return;
    }
    for (const [i, ss_student] of ss_students.entries()) {
      addRow({
        csvRecord: ss_student,
        headers: this.headersValue,
        index: i,
        uploadType: "ss_student",
      });
    }

    this.uploadSsStudents(ss_students);
  }

  parseCSV(csv: string): Promise<ss_student[]> {
    return new Promise((resolve, reject) => {
      Papa.parse<ss_student>(csv, {
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

  async uploadSsStudents(ss_students: ss_student[]) {
    while (ss_students.length > 0) {
      const index = ss_students.length - 1;
      const delay = new Promise((resolve) => setTimeout(resolve, 100));
      const ss_student = ss_students.pop();
      if (ss_student === undefined) continue;
      this.actionValue === "create"
        ? await createSsStudent(ss_student, this.orgValue, index)
        : await updateSsStudent(ss_student, this.orgValue, index);
      await delay;
    }
  }
}
