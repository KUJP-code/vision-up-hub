export default {
	content: [
		"./app/views/**/*.html.haml",
		"./app/helpers/**/*.rb",
		"./app/assets/stylesheets/**/*.css",
		"./app/javascript/**/*.js",
	],
	theme: {
		extend: {
			colors: {
				'ku-orange': '#f48000',
				'ku-blue': '#5bb6d5',
			}
		},
	}
};
