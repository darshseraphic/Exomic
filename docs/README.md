# Exomic website

A static marketing site shaped around the supplied DoingNow reference: compact nav, large editorial headings, thin rules, rounded utility cards, a straight phone mockup, sparse data tables, FAQ rows, a dark closing panel, and simple legal/contact pages.

## Screens used
The product showcase intentionally contains four screens and omits Settings:

1. Expense — `https://github.com/user-attachments/assets/7d5aa42d-eff4-4f23-bf24-493559c799ee`
2. Subscription — `https://github.com/user-attachments/assets/d4f68979-6448-4b29-ae0b-43c3cf203be5`
3. Saving — `https://github.com/user-attachments/assets/d3d5c581-af4c-45ad-b41a-3dde5b3b11ca`
4. Budget — `https://github.com/user-attachments/assets/fe288ea2-f9cd-46ff-8bdd-e37f3bba10f4`

The hero uses the theme-aware Expense image. All phone frames are intentionally unrotated/straight.

## Distribution
The homepage now exposes the Android ARM64 release as the primary download action:
`https://github.com/darshseraphic/Exomic/releases/download/v0.1.5/app-arm64-v8a-release.apk`

## Contact behavior
`contact.html` mirrors the reference page's two-card layout. Submitting the form opens Gmail compose addressed to `darsh.seraphic@gmail.com` with the name, email and message prefilled.

## Pages
- `index.html`
- `contact.html`
- `privacy.html`
- `terms.html`
- `security.html`
- `styles.css`
- `script.js`
- `cobe-minimal-test.html`

The site is static and can be deployed to GitHub Pages, Netlify, Vercel, Cloudflare Pages, or any static host.

## Asset notes
The homepage uses the supplied Exomic screenshots from `assets/`, with light/dark image swapping tied to the site theme. The screenshots include transparent outer pixels; the page intentionally does not add a black wrapper behind them.


## Globe dependency
The Privacy section uses the COBE WebGL globe by Shu Ding, loaded from jsDelivr at runtime (`cobe@2.0.1`). COBE is MIT licensed.
Repository: https://github.com/shuding/cobe
