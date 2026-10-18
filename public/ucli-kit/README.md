# ucli-kit

Shared style kit of the ucli sites, version 4 ("Plain"): plain CSS and JS, no build step. Version in
`VERSION`, checksums in `SHA256SUMS` (`scripts/check-kit.sh` verifies them). The canonical copy is this
folder in ucli-website; the other ucli repos hold verbatim copies. Change it here first, then copy it.

| File | Layer |
|---|---|
| `tokens.css` | shared: fonts, colour, type, shape, light and dark |
| `base.css` | shared: the `u-*` components (selectors are `.u-*` only) |
| `prose.css` | Astro sites only: reset, element defaults, home and install page layout |
| `copy.js`, `theme.js` | Copy buttons; light/dark button for the Astro sites |
| `sites.txt` | the four sites: `nav_label`, `footer_label`, `url`, tab separated (the chrome check reads it) |
| `mark.svg` | favicon and logo |
| `specimen.html` | every component on one page (not indexed) |

## Fonts

Two families, self-hosted as WOFF2 under the SIL Open Font License 1.1. The licence texts ship next to
the files: `fonts/OFL-Schibsted-Grotesk.txt` and `fonts/OFL-JetBrains-Mono.txt`. **Every font file is a
byte-identical copy of the official upstream file** (not subset, not converted, only renamed on disk).
The fonts are not covered by the repository's Apache-2.0 licence; they stay under OFL-1.1 (OFL condition 5).

Neither project declares a Reserved Font Name. Line 1 of the Schibsted Grotesk `OFL.txt` is
`Copyright 2023 The Schibsted-Grotesk Project Authors (https://github.com/schibsted/schibsted-grotesk)`
and line 1 of the JetBrains Mono `OFL.txt` is
`Copyright 2020 The JetBrains Mono Project Authors (https://github.com/JetBrains/JetBrainsMono)`;
neither carries a "with Reserved Font Name" clause.

| Kit file | Family / cut | Upstream source | Tag | Bytes | sha256 of the upstream file |
|---|---|---|---|---|---|
| `fonts/schibsted-grotesk-variable.woff2` | Schibsted Grotesk, variable, weight 400 to 900, roman | https://raw.githubusercontent.com/schibsted/schibsted-grotesk/1.100/fonts/variable/SchibstedGrotesk%5Bwght%5D.woff2 | `1.100` (`d485f61f105e1b3935f4d21dfb4d371359798603`) | 70,444 | `8b77a34cdd59455aa3434e949597e99346204d40357905fd918df20ed1139ac1` |
| `fonts/jetbrains-mono-400.woff2` | JetBrains Mono Regular | https://raw.githubusercontent.com/JetBrains/JetBrainsMono/v2.304/fonts/webfonts/JetBrainsMono-Regular.woff2 | `v2.304` (`cd5227bd1f61dff3bbd6c814ceaf7ffd95e947d9`) | 92,164 | `a9cb1cd82332b23a47e3a1239d25d13c86d16c4220695e34b243effa999f45f2` |
| `fonts/jetbrains-mono-500.woff2` | JetBrains Mono Medium | https://raw.githubusercontent.com/JetBrains/JetBrainsMono/v2.304/fonts/webfonts/JetBrainsMono-Medium.woff2 | `v2.304` | 93,824 | `086c48dfbea9ddaff1320f7e09399b8e2924e88ce67453721255db3bdbb5a353` |
| `fonts/OFL-Schibsted-Grotesk.txt` | licence text | https://raw.githubusercontent.com/schibsted/schibsted-grotesk/1.100/OFL.txt | `1.100` | 4,406 | `3b4f3063b6ac7c1e403e2c4a5e8ef3a58190ff83ed7b15af66511858699139ce` |
| `fonts/OFL-JetBrains-Mono.txt` | licence text | https://raw.githubusercontent.com/JetBrains/JetBrainsMono/v2.304/OFL.txt | `v2.304` | 4,399 | `30f0c136e3c88e422d0791acd97238870f9054a9729bc34cf2ff0d4ed8cac4ad` |

JetBrains Mono has no variable WOFF2 upstream (only TTF), so the two static WOFF2 files are used. The
weights in use are 400 and 500. Ligatures are switched off for code (`font-variant-ligatures: none`).

## Fallback metrics

Measured from the committed files with fontTools (average advance of a-z, hhea ascent and descent over
unitsPerEm) against the Liberation faces that stand in for Arial and Courier New.

| Face | Average a-z (font / fallback) | size-adjust | ascent / descent override |
|---|---|---|---|
| Schibsted Fallback | 0.5264 / 0.4895 | 107.5% | 90.8% / 24.0% |
| JetBrains Fallback | 0.6000 / 0.6001 | 100% | 102.0% / 30.0% |

Schibsted Grotesk: ascent 0.9766, descent 0.2578 (divided by 1.075 gives 90.8% and 24.0%). JetBrains
Mono: ascent 1.020, descent 0.300.

## Using it

Order in a page: `tokens.css`, `base.css`, `prose.css`, preloads for `schibsted-grotesk-variable.woff2`
and `jetbrains-mono-400.woff2`, the inline pre-paint theme snippet (in `theme.js`), then `copy.js` and
`theme.js` with `defer`. The docs load `tokens.css` and `base.css` only. No request goes to a third-party
font host.
