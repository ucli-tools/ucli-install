#!/usr/bin/env bash
# Chrome check, run AFTER the build (dist/ or site/ must exist). Compares the built top bar and footer with
# ucli-kit/sites.txt: the top bar links (nav.u-nav, or Material's equivalent) must equal the nav_label column
# in order, the footer links the footer_label column in order with GitHub last, exactly one link carries
# aria-current in the top bar, and the brand suffix names the current site (none on Home).
# Every problem is a ::warning::, never a failure: the workflow step is continue-on-error and this exits 0.
set -uo pipefail
cd "$(dirname "$0")/.."
OUT=""
for d in dist site; do [ -d "$d" ] && OUT="$d" && break; done
KIT=""
for d in public/ucli-kit docs/ucli-kit; do [ -f "$d/sites.txt" ] && KIT="$d" && break; done
if [ -z "$OUT" ] || [ -z "$KIT" ]; then
  echo "::warning::check-chrome: no built output folder or no sites.txt; skipped"
  exit 0
fi
python3 -I - "$OUT" "$KIT/sites.txt" <<'PY'
import sys, os
from html.parser import HTMLParser

out, sites_file = sys.argv[1], sys.argv[2]
sites = [l.rstrip("\n").split("\t") for l in open(sites_file, encoding="utf-8") if l.strip()]
nav_expect = [(s[0], s[2]) for s in sites]
foot_expect = [(s[1], s[2]) for s in sites] + [("GitHub", "https://github.com/ucli-tools/ucli")]

class P(HTMLParser):
    def __init__(self):
        super().__init__()
        self.stack = []        # open tags we care about: 'nav', 'footernav', 'brand'
        self.nav, self.foot, self.brand, self.current = [], [], [], []
        self.cur = None
        self.has_header = False
    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        cls = (a.get("class") or "").split()
        if tag == "header" and "u-header" in cls: self.has_header = True
        if tag == "nav" and "u-nav" in cls: self.stack.append(("nav", tag))
        elif tag == "nav" and "u-footer__nav" in cls: self.stack.append(("foot", tag))
        elif tag == "span" and "u-header__site" in cls: self.stack.append(("brand", tag))
        elif tag == "a" and self.stack and self.stack[-1][0] in ("nav", "foot"):
            self.cur = [self.stack[-1][0], a.get("href", ""), ""]
            if self.stack[-1][0] == "nav" and "aria-current" in a: self.current.append(a.get("href", ""))
    def handle_endtag(self, tag):
        if tag == "a" and self.cur:
            (self.nav if self.cur[0] == "nav" else self.foot).append((self.cur[2].strip(), self.cur[1]))
            self.cur = None
        elif self.stack and self.stack[-1][1] == tag and tag in ("nav", "span"):
            self.stack.pop()
    def handle_data(self, d):
        if self.cur: self.cur[2] += d
        elif self.stack and self.stack[-1][0] == "brand": self.brand.append(d)

problems, pages = [], 0
for root, _, files in os.walk(out):
    for f in files:
        if not f.endswith(".html"): continue
        path = os.path.join(root, f)
        if "ucli-kit" in path.split(os.sep): continue   # the kit's own specimen page
        txt = open(path, encoding="utf-8", errors="replace").read()
        if 'class="u-header' not in txt and "u-header" not in txt:
            continue   # a page without the kit chrome (a redirect, a 404 stub): not checked
        p = P(); p.feed(txt); pages += 1
        if p.nav != nav_expect: problems.append(f"{path}: top bar {p.nav} != sites.txt {nav_expect}")
        if p.foot != foot_expect: problems.append(f"{path}: footer {p.foot} != sites.txt + GitHub last {foot_expect}")
        if len(p.current) != 1: problems.append(f"{path}: {len(p.current)} aria-current links in the top bar, expected 1")
        else:
            label = next((l for l, h in nav_expect if h == p.current[0]), None)
            suffix = "".join(p.brand).replace("/", "").strip()
            want = "" if label == "Home" else (label or "").lower()
            if suffix != want: problems.append(f"{path}: brand suffix {suffix!r}, expected {want!r}")
for pr in problems: print("::warning::check-chrome: " + pr)
print(f"check-chrome: {pages} page(s) with kit chrome checked, {len(problems)} problem(s)")
PY
exit 0
