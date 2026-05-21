/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      fontFamily: {
        arimo: ['Arimo', 'sans-serif'],
      },
      colors: {
        'bg-primary': '#06040A',
        card: '#171717',
        'accent-purple': '#AC46FF',
        'accent-blue': '#2B7FFF',
      },
    },
  },
  plugins: [],
}
