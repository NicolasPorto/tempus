/** @type {import('tailwindcss').Config} */
// Tokens espelham lib/theme/app_theme.dart do tempus_app.
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Manrope', 'system-ui', 'sans-serif'],
      },
      colors: {
        bg: '#05040A',
        surface: '#0F0D16',
        'surface-hi': '#17141F',
        'surface-higher': '#201C2B',
        line: '#26222F',
        ink: '#F5F3FA',
        sub: '#9592A6',
        muted: '#5C596B',
        violet: '#A855F7',
        'violet-soft': '#C4A1FF',
        sky: '#60A5FA',
        mint: '#34D399',
        amber: '#F59E0B',
        rose: '#FB7185',
      },
      maxWidth: {
        page: '1160px',
      },
      borderRadius: {
        '4xl': '2rem',
      },
    },
  },
  plugins: [],
}
