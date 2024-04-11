import { Application } from "@hotwired/stimulus";

// Stimulus components
import Chart from "@stimulus-components/chartjs";
import Clipboard from "@stimulus-components/clipboard";
import TextareaAutogrow from "stimulus-textarea-autogrow";

// Misc NPM packages
import { Dropdown } from "tailwindcss-stimulus-components";

const application = Application.start();

// Register Stimulus Components
application.register("chart", Chart);
application.register("clipboard", Clipboard);
application.register("textarea-autogrow", TextareaAutogrow);

// Register misc NPM packages
application.register("dropdown", Dropdown);

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
