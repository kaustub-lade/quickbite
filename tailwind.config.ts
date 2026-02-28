import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
        mint: {
          50: '#F4FFFA',    // Ice White - Background
          100: '#CFF8E5',   // Very Soft Mint - Primary Light
          200: '#99EDC3',   // Mint Green - Primary
          300: '#6EE7B7',   // Gradient middle
          400: '#4CCB96',   // Deep Mint - Primary Dark
          500: '#34D399',   // Gradient end
          600: '#1F8A70',   // Teal Green - Dark Accent
          700: '#1E6F5C',
          800: '#155E4D',
          900: '#0F4C3E',
        },
        navy: '#1E293B',      // Dark Navy (Text)
        lightgray: '#F8FAFC', // Light Gray BG
      },
    },
  },
  plugins: [],
};
export default config;
