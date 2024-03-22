import { Application } from "@hotwired/stimulus";
import Chart from "@stimulus-components/chartjs";

const application = Application.start();

application.register("chart", Chart);

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
