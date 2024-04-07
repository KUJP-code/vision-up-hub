import { Application } from "@hotwired/stimulus";
import Chart from "@stimulus-components/chartjs";
import { Dropdown } from "tailwindcss-stimulus-components";

const application = Application.start();

application.register("chart", Chart);
application.register("dropdown", Dropdown);

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
