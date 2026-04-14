import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["lessonCategory", "resourceCategory"];
  static values = {
    optionsByLessonCategory: Object,
    labels: Object,
    prompt: String,
  };

  connect() {
    this.updateResourceCategories();
  }

  updateResourceCategories() {
    const lessonCategory = this.lessonCategoryTarget.value;
    const selectedValue = this.resourceCategoryTarget.value;
    const validOptions = lessonCategory
      ? (this.optionsByLessonCategoryValue[lessonCategory] || [])
      : Object.keys(this.labelsValue);

    this.resourceCategoryTarget.innerHTML = "";
    this.resourceCategoryTarget.append(this.buildOption(this.promptValue, ""));

    validOptions.forEach((value) => {
      this.resourceCategoryTarget.append(
        this.buildOption(this.labelsValue[value] || value, value),
      );
    });

    if (validOptions.includes(selectedValue)) {
      this.resourceCategoryTarget.value = selectedValue;
    }
  }

  buildOption(label, value) {
    const option = document.createElement("option");
    option.textContent = label;
    option.value = value;
    return option;
  }
}
