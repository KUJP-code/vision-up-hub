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
        "color-neutral-light": "#f9f9f9",
        "color-neutral-dark": "#b1a9bc",
        "color-main": "#fab650",
        "color-secondary": "#7e7195",
      },
    },
  },
};
