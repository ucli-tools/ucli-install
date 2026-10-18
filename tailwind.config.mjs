/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  // Preflight is the kit's job (public/ucli-kit/prose.css). The --tw-* defaults still come from
  // `@tailwind base` in src/styles/tw.css.
  corePlugins: { preflight: false },
  theme: {
    // Min-width breakpoints that line up with the kit's max-width ones (720, 760, 900, 1100).
    screens: { sm: '721px', md: '761px', lg: '901px', xl: '1101px' },
    extend: {
      colors: {
        paper: 'var(--u-paper)',
        paper2: 'var(--u-paper-2)',
        rule: 'var(--u-rule)',
        ruleStrong: 'var(--u-rule-strong)',
        ink: 'var(--u-ink)',
        ink2: 'var(--u-ink-2)',
        ok: 'var(--u-ok)',
        slab: 'var(--u-slab-bg)',
        slabFg: 'var(--u-slab-fg)',
        btn: 'var(--u-btn-bg)',
        btnFg: 'var(--u-btn-fg)',
      },
      fontFamily: {
        sans: ['"Schibsted Grotesk"', '"Schibsted Fallback"', 'system-ui', '"Segoe UI"', '"Helvetica Neue"', 'Arial', 'sans-serif'],
        mono: ['"JetBrains Mono"', '"JetBrains Fallback"', 'ui-monospace', '"SFMono-Regular"', 'Menlo', 'Consolas', 'monospace'],
      },
      maxWidth: { prose: '70ch' },
    },
  },
  plugins: [],
}
