/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  // Preflight is the kit's job (public/ucli-kit/prose.css). The --tw-* defaults still come from
  // `@tailwind base` in src/styles/tw.css.
  corePlugins: { preflight: false },
  theme: {
    screens: { sm: '480px', md: '768px', lg: '1024px', xl: '1280px' },
    extend: {
      colors: {
        paper: 'var(--u-paper)',
        paper2: 'var(--u-paper-2)',
        rule: 'var(--u-rule)',
        ink: 'var(--u-ink)',
        ink2: 'var(--u-ink-2)',
        ink3: 'var(--u-ink-3)',
        accent: 'var(--u-accent)',
        ok: 'var(--u-ok)',
        warn: 'var(--u-warn)',
      },
      fontFamily: {
        serif: ['"Source Serif 4"', '"Source Serif Fallback"', '"Iowan Old Style"', '"Palatino Linotype"', 'Georgia', 'serif'],
        sans: ['"IBM Plex Sans"', '"Plex Sans Fallback"', '"Segoe UI"', '"Helvetica Neue"', 'Arial', 'sans-serif'],
        mono: ['"IBM Plex Mono"', '"Plex Mono Fallback"', 'ui-monospace', '"SFMono-Regular"', 'Menlo', 'Consolas', 'monospace'],
      },
      maxWidth: { prose: '68ch' },
    },
  },
  plugins: [],
}
