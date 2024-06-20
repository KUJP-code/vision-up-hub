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
							danger: "#ef7877",
							main: "#69c0dd",
							"main-50": "#aadaeb",
							"neutral-dark": "#b2aabf",
							"neutral-light": "#f1f1f1",
							secondary: "#645880",
							"secondary-50": "#b2aabf",
							success: "#8ac273",
						},
						fontFamily: {
							sans: ["'M PLUS 1p'", "sans-serif"],
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
							main: "#fab650",
							"main-50": "#fcd6a0",
							"neutral-dark": "#b1a9bc",
							"neutral-light": "#f9f9f9",
							secondary: "#7e7195",
							"secondary-50": "#b2aabf",
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
							main: "#32cd32",
							"main-50": "#009c87",
							"neutral-dark": "#ffffff",
							"neutral-light": "#000000",
							secondary: "#f372b6",
							"secondary-50": "#ff9682",
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
