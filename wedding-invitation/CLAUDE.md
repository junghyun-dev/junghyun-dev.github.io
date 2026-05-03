<!-- GSD:project-start source:PROJECT.md -->
## Project

**Wedding Invitation (모바일 청첩장)**

A mobile-first Korean wedding invitation page (모바일 청첩장) hosted on GitHub Pages. A single scrolling page that provides guests with all essential wedding information — who's getting married, when, where, and how to give 축의금. Design closely modeled after theirmood.com's invitation style.

**Core Value:** Guests receive a beautiful, mobile-optimized wedding invitation that clearly communicates the wedding details and makes it easy to send congratulatory money (축의금).

### Constraints

- **Platform**: GitHub Pages — static hosting only, no server-side logic
- **Secrets**: Phone numbers and bank account numbers must NOT appear in the git repository; injected via GitHub Actions secrets at build time
- **Tech stack**: Vanilla HTML/CSS/JS — no frameworks, no npm dependencies in production
- **Mobile-first**: Primary target is mobile browsers (iOS Safari, Android Chrome); desktop is secondary
- **Fonts**: Minimal font count — one Korean (Gowun Dodum), one English (Bona Nova SC); both changeable later
- **Map API**: Naver Maps API requires an API key (ncpKeyId) — this should also be managed as a secret or config
<!-- GSD:project-end -->

<!-- GSD:stack-start source:research/STACK.md -->
## Technology Stack

## Recommended Stack
### Core Platform
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Vanilla HTML5 | — | Page structure | No framework needed for a single-page static site. Maximum compatibility, zero build complexity, easiest for AI-assisted development. |
| Vanilla CSS3 | — | Styling | CSS custom properties for theming, native `@media` queries for responsive. No preprocessor needed — CSS nesting is now baseline across browsers. |
| Vanilla JavaScript (ES2020+) | — | Interactivity | IntersectionObserver, Clipboard API, and dynamic section logic. No transpilation needed — target audience (mobile browsers 2025+) supports modern JS natively. |
| GitHub Pages | — | Static hosting | Free, auto-deploys from repo, supports custom domains. Already the host for this project. |
### Fonts
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Gowun Dodum (고운 돋움) | v12 | Korean body text | Clean, modern Korean serif font. Matches theirmood.com reference. Available on Google Fonts with full Korean unicode-range subsetting (auto-splits into ~110 woff2 chunks, only downloads what's needed). Single weight (400) keeps payload small. |
| Bona Nova SC | v1 | English display text | Small-caps serif — elegant for wedding names and headings. Matches the sample invitation style. Weights 400 + 700 available. |
| Google Fonts CSS API v2 | — | Font delivery | CDN-served, auto unicode-range subsetting, `font-display: swap` for performance. Verified: both fonts serve correctly via `https://fonts.googleapis.com/css2?family=Gowun+Dodum&family=Bona+Nova+SC:wght@400;700&display=swap`. |
### CSS Approach
| Technology | Purpose | Why |
|------------|---------|-----|
| CSS Custom Properties | Theming / color scheme | Single place to change key color (`--color-accent`), font families, spacings. Configurable as promised in requirements. |
| Native CSS nesting | Component scoping | Baseline since Dec 2023. Reduces repetition without preprocessor. |
| `@media` queries | Responsive design | Mobile-first: base styles = mobile, `@media (min-width: 768px)` for desktop adjustments. |
| `scroll-snap-type` | Optional gallery snapping | Native CSS scroll snap for horizontal photo gallery on mobile. |
| `max-width: 480px` container | Mobile viewport constraint | Korean mobile invitations are designed for phone width. Center a constrained container, not full-width desktop. |
### Animation
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| AOS (Animate on Scroll) | 2.3.4 | Fade-on-scroll section animations | 28.1k GitHub stars, 286k dependents, 221k weekly npm downloads. CSS-driven (uses `data-aos` attributes + CSS transitions). 14KB JS + 8KB CSS unminified. Dead simple: add `data-aos="fade-up"` to elements. Used by ~300k projects — battle-tested. |
| CSS `@keyframes` | — | Opening animation, specific transitions | Full-screen photo overlay fade is a one-off animation — custom CSS is simpler than a library for this. |
### Map API
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Naver Maps JavaScript API v3 | v3 (NCP) | Venue map embed | Korean users use Naver Maps as primary navigation. The API uses `ncpKeyId` parameter (NCP = Naver Cloud Platform). Verified from official docs: the old `ncpClientId` is deprecated; new unified auth uses `ncpKeyId`. |
| Deep links (Naver/Kakao/Tmap) | — | Navigation app launch | Korean convention: provide buttons to open the venue in Naver Map app, Kakao Map app, and Tmap. These are URL schemes / universal links. |
### Copy-to-Clipboard (축의금 계좌번호)
| Technology | Purpose | Why |
|------------|---------|-----|
| `navigator.clipboard.writeText()` | Copy bank account numbers | Native Web API, no library needed. Baseline since March 2020 per MDN. Works in secure contexts (HTTPS — GitHub Pages serves HTTPS by default). |
### Image Optimization
| Technology | Purpose | Why |
|------------|---------|-----|
| WebP format | Primary image format | 25-35% smaller than JPEG at same quality. Supported by all target browsers (iOS Safari 14+, Android Chrome). |
| `<picture>` + `<source>` | Format fallback | Serve WebP with JPEG fallback. Verified as baseline HTML element on MDN (since March 2016). |
| `loading="lazy"` | Lazy loading | Native browser lazy loading. No JS needed. Supported across all modern browsers. |
| `srcset` + `sizes` | Responsive images | Serve different resolutions for different devices. Critical for mobile bandwidth. |
| Manual pre-optimization | Build-time optimization | Convert photos to WebP at 2-3 sizes (small: 480w, medium: 800w) before committing. Use `cwebp` CLI or any image tool. No runtime optimization needed for a static site. |
### Build Tooling (Secrets Injection)
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| GitHub Actions | — | CI/CD pipeline | Build step replaces placeholder tokens with secrets before deploying to GitHub Pages. Already chosen in PROJECT.md. |
| `sed` / shell substitution | — | Token replacement | Simple `sed -i 's/__PHONE_GROOM__/${PHONE_GROOM}/g' index.html` in a shell script. No Node.js or build tool needed. Keeps the build dead simple. |
| GitHub Secrets | — | Secret storage | Phone numbers, bank accounts, Naver Map API key stored as repository secrets. Never in git. |
#!/bin/bash
# Copy source to build directory
# Replace placeholder tokens with secrets
# ... more secrets as needed
## Alternatives Considered
| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Framework | Vanilla HTML/CSS/JS | React, Vue, Svelte | Single page, no routing, no state management needed. Framework adds bundle size and build complexity for zero benefit. |
| CSS | Vanilla CSS with custom properties | Tailwind, SCSS | Tailwind needs a build step. SCSS needs compilation. Both add complexity for a single-page site. Native CSS nesting + custom properties cover our needs. |
| Animation | AOS 2.3.4 via CDN | GSAP, Animate.css, custom IntersectionObserver | GSAP is overkill (100KB+) for fade-on-scroll. Animate.css doesn't handle scroll triggering. Custom IO works but AOS saves time with pre-built animations. |
| Map | Naver Maps v3 | Google Maps, Kakao Maps | Korean users primarily use Naver Maps. Google Maps has poor Korean venue/POI data. Kakao Maps is viable but Naver is the primary choice for wedding invitations. |
| Image format | WebP | AVIF, JPEG-only | AVIF has slightly worse iOS Safari support (requires 16+). WebP is universally supported and sufficient. JPEG-only misses 25-35% size savings. |
| Build tool | Shell `sed` | Node.js script, envsubst, Mustache templating | `sed` is zero-dependency, runs everywhere, trivially simple for token replacement. Node.js adds unnecessary complexity. |
| Clipboard | `navigator.clipboard.writeText()` | clipboard.js library | Native API is well-supported, no library needed. clipboard.js would add unnecessary dependency. |
| Font loading | Google Fonts CDN | Self-hosted fonts, Fontsource | Google Fonts CDN auto-subsets Korean (critical for CJK fonts — Gowun Dodum splits into ~110 subsets, only downloading needed glyphs). Self-hosting would require manual subsetting. |
## CDN Dependencies (Production)
## Dev Dependencies (Build Only)
# Image optimization (run locally before committing photos)
# Example: cwebp -q 80 photo.jpg -o photo.webp
# No npm, no node_modules, no package.json needed
## Sources
- Naver Maps v3 docs (official): https://navermaps.github.io/maps.js.ncp/docs/tutorial-2-Getting-Started.html — **HIGH confidence**
- AOS GitHub (28.1k stars): https://github.com/michalsnik/aos — **HIGH confidence**
- AOS npm (v2.3.4, 221k weekly downloads): https://www.npmjs.com/package/aos — **HIGH confidence**
- Google Fonts API (Gowun Dodum, Bona Nova SC): https://fonts.google.com — **HIGH confidence**
- IntersectionObserver API (MDN, baseline since March 2019): https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API — **HIGH confidence**
- Clipboard.writeText() (MDN, baseline since March 2020): https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/writeText — **HIGH confidence**
- `<picture>` element (MDN, baseline since March 2016): https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/picture — **HIGH confidence**
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
