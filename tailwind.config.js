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
				'ku-blue': '#5bb6d5',
				'ku-gray-100': '#f9f9f9',
				'ku-gray-500': '#b1a9bc',
				'ku-gray-900': '#b3abc0',
				'ku-orange': '#fab650',
				'ku-purple': '#7e7195',
			}
		},
	}
};
