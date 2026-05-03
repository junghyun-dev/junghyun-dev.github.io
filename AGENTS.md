# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project Overview

A mobile-first Korean wedding invitation (모바일 청첩장) hosted on GitHub Pages.
Single-page static site — vanilla HTML/CSS/JS, no frameworks, no npm dependencies.
All source code lives in `wedding-invitation/index.html` (CSS and JS are inline).

## Repository Structure

```
.github/workflows/deploy.yml    # CI/CD: build + deploy to GitHub Pages
.nojekyll                        # Disables Jekyll processing
index.html                       # Root redirect to /wedding-invitation/
wedding-invitation/
  index.html                     # THE site — all HTML, CSS, JS inline (~1160 lines)
  build.sh                       # Secrets injection build script
  photos/                        # Wedding photos (WebP format)
  CLAUDE.md                      # Project context for AI agents (GSD-managed)
  .planning/                     # Planning artifacts (not deployed)
```

## Build Commands

There is no package.json, no test runner, no linter, and no type checker.

```bash
# Build (from wedding-invitation/ directory, requires env vars for secrets)
bash build.sh

# Build without secrets (tokens become empty strings, but validation will fail)
# Useful for checking HTML structure locally:
PHONE_GROOM=test NAVER_MAP_KEY=test bash build.sh  # will fail validation

# Local preview (after build, or directly on source)
open index.html              # macOS
python3 -m http.server 8000  # serve locally for Naver Maps API (needs HTTPS/localhost)
```

**No test or lint commands exist.** Validation is limited to the build script checking
that no `__PLACEHOLDER__` tokens remain unreplaced in the output.

## Deployment

- **Automatic:** Push to `main` triggers `.github/workflows/deploy.yml`
- **Manual:** `workflow_dispatch` in GitHub Actions
- Pipeline: checkout -> `build.sh` (injects secrets via `sed`) -> assemble `_site/` -> deploy to GitHub Pages
- All work happens on the `main` branch (no feature branches)

## Secrets & Sensitive Data

**Never commit phone numbers, bank account numbers, or API keys.**

Source code uses `__UPPER_SNAKE_CASE__` placeholder tokens (25 total).
These are replaced at build time by `build.sh` using GitHub Actions secrets.

| Category         | Token pattern examples                                |
|------------------|-------------------------------------------------------|
| Phone numbers    | `__PHONE_GROOM__`, `__PHONE_BRIDE__`, etc.            |
| Bank accounts    | `__ACCOUNT_GROOM_BANK__`, `__ACCOUNT_GROOM_NUMBER__`  |
| API keys         | `__NAVER_MAP_KEY__`                                   |

When adding new secrets: add the token in `index.html`, the `sed` line in `build.sh`,
and the env/secret mapping in `.github/workflows/deploy.yml`.

## Code Style — HTML

- Language attribute: `lang="ko"`
- All CSS in a single `<style>` block in `<head>`; all JS in a single `<script>` at end of `<body>`
- Section pattern: `<section id="sectionname" class="section" data-aos="fade-up">`
- Section IDs are lowercase single words: `hero`, `greeting`, `calendar`, `venue`, `gallery`, `accounts`, `contact`
- Major sections delimited by: `<!-- ===== Section Name ===== -->`
- Use `class="english"` on elements that should render in the English font
- Images: use `loading="lazy"`, explicit `width`/`height`, `<picture>` with WebP + JPEG fallback
- Inline `onclick` handlers for UI buttons (not addEventListener)

## Code Style — CSS

- **Indentation:** 2 spaces
- **Naming:** BEM-like — `.block__element`, `.block--modifier`
  - Blocks: `.hero`, `.greeting`, `.calendar`, `.venue`, `.gallery-grid`, `.accordion`, `.toast`
  - Elements: `.hero__names`, `.calendar__grid`, `.account-entry__bank`
  - Modifiers: `.opening-overlay--hidden`, `.greeting__parent--deceased`
- **Custom properties** defined in `:root`:
  - Colors: `--color-bg`, `--color-text`, `--color-text-light`, `--color-accent`, `--color-accent-light`, `--color-white`, `--color-border`
  - Fonts: `--font-korean`, `--font-english`
  - Layout: `--max-width` (480px), `--section-padding`, `--line-height`
- **Section comments:** `/* ===== Section Name ===== */`
- **Organization:** follows HTML section order (reset -> base -> wrapper -> section base -> per-section -> desktop media query)
- **Responsive:** mobile-first; single breakpoint `@media (min-width: 768px)` at the end
- **Units:** `rem` for font sizes, `px` for spacing/borders
- **No vendor prefixes** except `-webkit-font-smoothing`
- **No CSS nesting** — flat selectors only

## Code Style — JavaScript

- **Indentation:** 2 spaces
- **Variables:** `var` exclusively (no `let`/`const`)
- **Functions:** `function name() {}` declarations (no arrow functions)
- **Strings:** single quotes `'...'`
- **Semicolons:** always
- **Scoping:** IIFE pattern for section-scoped code:
  ```javascript
  /* ===== Section Name ===== */
  (function() {
    // section code here
  })();
  ```
- **Global functions:** used for inline `onclick` handlers (e.g., `copyToClipboard`, `showToast`, `openNaverMap`)
- **Config objects:** top-level `var` with object literal:
  ```javascript
  var WEDDING = { year: 2026, month: 6, day: 20, hour: 12, minute: 0 };
  var VENUE = { name: '...', lat: 37.5665, lng: 126.9780, zoom: 16 };
  ```
- **Section comments:** `/* ===== Section Name ===== */`
- **No ES6+ features used:** no arrow functions, template literals, destructuring, `let`/`const`, `async`/`await`, classes, or ES modules

## Error Handling Patterns

- **Clipboard:** `navigator.clipboard.writeText().then(...).catch(...)` with `document.execCommand('copy')` fallback
- **External APIs:** guard with existence checks before use (e.g., `if (typeof naver === 'undefined' || !naver.maps) return;`)
- **DOM elements:** null-check before access (`if (!el) return;`)
- **Deep links (mobile apps):** attempt deep link, fallback to web URL after timeout
- **Build validation:** `grep -oE '__[A-Z_]+__'` to catch unreplaced tokens

## APIs & External Dependencies

| Dependency       | Loaded via        | Purpose                          |
|------------------|-------------------|----------------------------------|
| AOS 2.3.4        | CDN (unpkg)       | Scroll-triggered fade animations |
| Naver Maps v3    | CDN (naver)       | Venue map embed                  |
| Google Fonts     | CDN (googleapis)  | Gowun Dodum + Bona Nova SC      |

- `navigator.clipboard.writeText()` — copy bank account numbers
- `IntersectionObserver` — pause/resume hero particle animation
- `requestAnimationFrame` — canvas particle animation
- `sessionStorage` — track whether opening animation has been shown

## Commit Message Convention

Conventional commits with phase/plan references:
```
feat(05-01): add opening animation with particle canvas
fix(03-02): correct map marker position
docs(phase-03): add verification report
chore(04-02): update planning artifacts
```

## Key Constraints

1. **No server-side logic** — GitHub Pages static hosting only
2. **No build tools beyond shell** — no Node.js, no bundlers, no npm
3. **Single HTML file** — all CSS and JS remain inline in `index.html`
4. **Mobile-first** — primary targets are iOS Safari and Android Chrome; max-width 480px container
5. **Korean locale** — content is in Korean; `lang="ko"`
6. **Minimal fonts** — one Korean (Gowun Dodum), one English (Bona Nova SC)
7. **Photos as WebP** — with JPEG fallback via `<picture>` element
