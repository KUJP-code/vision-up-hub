const themeSwapper = require("tailwindcss-theme-swapper");

export default {
	content: [
		"./app/views/**/*.{html.haml,turbo_stream.haml}",
		"./app/helpers/**/*.rb",
		"./app/assets/stylesheets/**/*.css",
		"./app/javascript/**/*.{ts,js}",
	],
	plugins: [
		themeSwapper({
			themes: [
				{
					name: "base",
					selectors: [":root"],
					theme: {
						colors: {
							"color-neutral-light": "#f9f9f9",
							"color-neutral-dark": "#b1a9bc",
							"color-main": "#fab650",
							"color-secondary": "#7e7195",
						},
						borderRadius: {
							DEFAULT: "0.5rem",
						},
					},
				},
				{
					name: "org_2",
					selectors: [".org_2"],
					theme: {
						colors: {
							"color-neutral-light": "#f9f9f9",
							"color-neutral-dark": "#b1a9bc",
							"color-main": "#fab650",
							"color-secondary": "#7e7195",
						},
						borderRadius: {
							DEFAULT: "0.5rem",
						},
					},
				},
				{
					name: "org_3",
					selectors: [".org_3"],
					theme: {
						colors: {
							"color-neutral-light": "#000000",
							"color-neutral-dark": "#ffffff",
							"color-main": "#32cd32",
							"color-secondary": "#f372b6",
						},
						borderRadius: {
							DEFAULT: "8rem",
						},
					},
				},
			],
		}),
	],
};
