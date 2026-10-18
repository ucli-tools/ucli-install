# ucli-kit

Shared style kit of the ucli sites: plain CSS and JS, no build step. Version in `VERSION`, checksums
in `SHA256SUMS` (`scripts/check-kit.sh` verifies them). The canonical copy is this folder in
ucli-website; the other ucli repos hold verbatim copies. Change it here first, then copy it.

| File | Layer |
|---|---|
| `tokens.css` | shared: fonts, colour, type, spacing, light and dark |
| `base.css` | shared: the `u-*` components (selectors are `.u-*` only) |
| `prose.css` | Astro sites only: reset and element defaults |
| `copy.js`, `theme.js` | Copy buttons; light/dark toggle for the Astro sites |
| `mark.svg` | favicon and logo |
| `specimen.html` | every component on one page (not indexed) |

## Fonts

Self-hosted WOFF2, SIL Open Font License 1.1. The licence texts ship next to the files:
`fonts/OFL-Source-Serif.txt`, `fonts/OFL-IBM-Plex.txt`. Both licences reserve a font name ("Source",
"Plex"), so a subset or any edited file may not carry that name. **Every font file here is an
unmodified, byte-identical copy of an official upstream WOFF2 file** (copied, not subset, not
renamed), which is why the families keep their original names. The Plex files are the official Latin
split (`Latin1`) with the upstream `unicode-range` (in `tokens.css`).

| File | Family / cut | Upstream source | Version | Status | sha256 |
|---|---|---|---|---|---|
| `source-serif-4-400.woff2` | Source Serif 4 Regular | `TTF/SourceSerif4-Regular.ttf.woff2` in `source-serif-4.005_WOFF2.zip`, https://github.com/adobe-fonts/source-serif/releases/download/4.005R/source-serif-4.005_WOFF2.zip | 4.005R | unmodified | `6b053e98f0838afe81f3e784727be4583a7c13bb42f198dc5202ecffee0aaee0` |
| `source-serif-4-400-italic.woff2` | Source Serif 4 Italic | `TTF/SourceSerif4-It.ttf.woff2`, same zip | 4.005R | unmodified | `ca3b17ed1e3e668ffd9e03385cfd46e1b095df783de53710d25d41241496026b` |
| `source-serif-4-600.woff2` | Source Serif 4 Semibold | `TTF/SourceSerif4-Semibold.ttf.woff2`, same zip | 4.005R | unmodified | `457a13ac92e977d82e376038a2daac7fdb5433610910bf5787bdf6c1c3781865` |
| `ibm-plex-sans-400-latin.woff2` | IBM Plex Sans Regular, Latin1 | `fonts/split/woff2/IBMPlexSans-Regular-Latin1.woff2` in https://registry.npmjs.org/@ibm/plex-sans/-/plex-sans-1.1.0.tgz | @ibm/plex-sans 1.1.0 | unmodified | `b5ad7bd39f996144915f0ad9849a90183b27d8c28ad97ed98af5b1bebc51f6b1` |
| `ibm-plex-sans-600-latin.woff2` | IBM Plex Sans SemiBold, Latin1 | `fonts/split/woff2/IBMPlexSans-SemiBold-Latin1.woff2`, same package | @ibm/plex-sans 1.1.0 | unmodified | `fff0ab3a88b0b4aa0b693e4f0201359a15183b08e3fa5696d1918d8f0ade8ad5` |
| `ibm-plex-mono-400-latin.woff2` | IBM Plex Mono Regular, Latin1 | `fonts/split/woff2/IBMPlexMono-Regular-Latin1.woff2` in https://registry.npmjs.org/@ibm/plex-mono/-/plex-mono-2.5.0.tgz | @ibm/plex-mono 2.5.0 | unmodified | `e8993d946649b9d01abb1ed06d574b19d8ea3e66b5c3948602db335c44c18e56` |
| `ibm-plex-mono-500-latin.woff2` | IBM Plex Mono Medium, Latin1 | `fonts/split/woff2/IBMPlexMono-Medium-Latin1.woff2`, same package | @ibm/plex-mono 2.5.0 | unmodified | `41201b658a328b9d00368215c2f1102770f80b15952ab82631e4006255e6365d` |

Source Serif is the full upstream file (all scripts); characters the Plex Latin1 file lacks fall back
to the next font in the stack. The OFL texts come from the same releases
(https://github.com/adobe-fonts/source-serif/blob/4.005R/LICENSE.md and `LICENSE.txt` in the Plex packages).

## Fallback metrics

Measured from the files in `fonts/` (unchanged by the switch to the upstream files: same glyph metrics) with fontTools (average advance of a-z, hhea ascent and descent
over unitsPerEm) against the Liberation faces that stand in for Times New Roman, Arial and Courier New.

| Face | Average a-z (font / fallback) | size-adjust | ascent / descent override |
|---|---|---|---|
| Source Serif Fallback | 0.5103 / 0.4593 | 111.1% | 93.2% / 30.2% |
| Plex Sans Fallback | 0.5050 / 0.4895 | 103.2% | 99.4% / 26.7% |
| Plex Mono Fallback | 0.6000 / 0.6001 | 100% | 102.5% / 27.5% |

The design's draft numbers for Source Serif (119.9%, 86.4%, 27.9%) came from a different cut and
differ by more than 0.5 point, so the measured values are used.
