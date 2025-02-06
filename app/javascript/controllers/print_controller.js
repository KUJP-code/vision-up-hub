import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="print"
export default class extends Controller {
	print() {
		window.print();
	}
	window.onbeforeprint = function() {
		// Assuming 'chart' is your Chart.js instance:
		chart.options.plugins.legend.display = false;    // Hide legend for printing
		chart.options.plugins.tooltip.enabled = false;    // Disable tooltips for printing
		// Any additional changes specific to print can be made here...
		chart.update();
	  };
	  
	  window.onafterprint = function() {
		// Restore the original configuration after printing:
		chart.options.plugins.legend.display = true;     // Or your original setting
		chart.options.plugins.tooltip.enabled = true;
		chart.update();
	  };
	  
}
