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
							"keep-up": "#e88d8d",
							"main-50": "#aadaeb",
							"neutral-dark": "#e1e0e3",
							"neutral-light": "#f1f1f1",
							"secondary-50": "#b2aabf",
							danger: "#f76c82",
							galaxy: "#bc8ebe",
							kindy: "#f9a373",
							land: "#b0d07a",
							main: "#69c0dd",
							medium: "#fdcd56",
							secondary: "#645880",
							sky: "#8eccda",
							specialist: "#8e9cf2",
							success: "#9ed26a",
							warn: "#fdcd56",
						},
						fontFamily: {
							sans: ["'M PLUS 1p'", "sans-serif"],
						},
						borderRadius: {
							DEFAULT: "0.625rem",
						},
					},
				},
				{
					name: "org_6969",
					selectors: [".org_6969"],
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
