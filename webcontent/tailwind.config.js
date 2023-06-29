/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,ts}",
  ],
  theme: {
    extend: {
      height: {
        '600': '600px',
        '500': '500px',
        '400': '400px',
      },
      colors: {
        'primary': '#fcc81d',
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
}
