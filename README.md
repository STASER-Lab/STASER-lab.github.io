````markdown
# STASER Lab Website

A multilingual single-page site built with **Hugo (extended)** and the **Adritian** theme, customized for STASER Lab.

---

## Repo structure

- `content/` — Markdown pages (e.g., `content/home/_index.md`); per-language under `content/es/`, `content/fr/`.
- `layouts/` — Templates & shortcodes (e.g., `about_with_carousel`, `research_pubs*`, `contact_formspree`).
- `assets/` — SCSS/JS processed by Hugo Pipes & PostCSS.
- `static/` — Copied as-is (images, favicon, robots.txt).
- `i18n/` — Translation files (`en.yaml`, `es.yaml`, `fr.yaml`).
- `archetypes/` — Content blueprints for `hugo new`.
- `public/` — Build output (ignored by Git in most setups).
- `hugo.toml` — Site config (modules, menus, i18n, plugins).
- `package.json` / `postcss.config.js` — Theme’s asset dependencies & PostCSS.

---

## Prereqs

- **Hugo Extended** ≥ 0.128 (for SCSS/Sass & Hugo Pipes)
- **Node.js** ≥ 18 (for npm + PostCSS)
- Git

Install locally:

```bash
# macOS (homebrew)
brew install hugo
# verify it's the extended build:
hugo version  # look for "extended"

# node
brew install node
````

---

## Install & run locally

```bash
npm install          # installs bootstrap, postcss, autoprefixer...
hugo server -D       # local dev server with drafts, http://localhost:1313
```

Build production:

```bash
hugo --gc --minify
# output in ./public
```

**Tip:** if you change SCSS or add npm deps, restart `hugo server`.

---

## Configuration highlights

* **Menus** (single-page anchors): configured in `hugo.toml` under `[languages.*.menus.header]`
  (we use `/#about`, `/#research`, etc.)
* **Logo**: `params.logo` (and we override size via CSS)
* **i18n**: `i18n/en.yaml`, `i18n/es.yaml`, `i18n/fr.yaml`
* **Shortcodes**:

  * `about_with_carousel` — about section + Bootstrap carousel
  * `research_pubs`, `research_pubs.es`, `research_pubs.fr` — per-language publications
  * `contact_formspree` — localized Formspree form + info block

---

## Deploy: Render (recommended for simplicity)

> We need **Hugo Extended** and **npm** during build so the theme can compile SCSS and bundle JS.

### 1) Make sure these files exist

* `package.json` (minimal working example):

```json
{
  "name": "staser-lab",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "bootstrap": "^5.3.7",
    "bootstrap-print-css": "^1.0.0",
    "postcss": "^8.5.4",
    "postcss-cli": "^11.0.0",
    "autoprefixer": "^10.4.17"
  }
}
```

* `postcss.config.js`:

```js
module.exports = { plugins: [ require('autoprefixer') ] };
```

### 2) Create a **Static Site** on Render

* **Publish directory**: `public`
* **Build Command**: ```./build.sh```

* **Environment variables** (Render → Settings → Environment):

  * `HUGO_ENV = production`
  * *(optional)* `HUGO_CACHEDIR = /tmp/hugo_cache`

### 3) Verify CSS/JS load

Open DevTools → Network. Check:

* `css/bundle.min.*.css` → **200**
* `assets/js/vendor/bootstrap.bundle.min.js` → **200**

---

## Deploy: GitHub Pages

You can publish either:

### A) At the **root** (e.g., `https://mydomain.tech/`)

Add a GitHub Actions workflow: `.github/workflows/gh-pages.yml`:

```yaml
name: Deploy Hugo site to Pages
on:
  push:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install npm deps
        run: npm ci

      - name: Setup Hugo (extended)
        uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: '0.128.2'
          extended: true

      - name: Build
        run: hugo --gc --minify --baseURL "https://mydomain.tech/"

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./public

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

Enable Pages: repo **Settings → Pages → Source = GitHub Actions**.

### B) At a **subpath** (e.g., `https://mydomain.tech/staser-lab/`)

Use:

```bash
hugo --gc --minify --baseURL "https://mydomain.tech/staser-lab/"
```

Or in `hugo.toml`:

```toml
baseURL = "/staser-lab/"
relativeURLs = true
canonifyURLs = false
```

---

## Contact form (Formspree)

* Shortcode: `contact_formspree` (localized via `i18n`).
* Update your endpoint: `action="https://formspree.io/f/xxxxxx"`.
* For same-page success messages: use the JS handler mode in the shortcode (instead of redirect).

---

## Common gotchas

* **Unstyled page** → not using Hugo Extended, npm not run, or missing `postcss.config.js`.
* **CSS/JS 404** → wrong `baseURL`. Rebuild with the correct one.
* **Anchor links don’t scroll** → ensure section `id` matches menu URL.
* **Favicon wrong** → place your `favicon.ico` / PNGs in `static/`.

---

## Maintenance tips

* Pin Hugo version in CI/Render (we use `0.128.2`).
* Run `npm outdated` / `npm update` regularly.
* Keep translations aligned across `i18n/` and in `home` folder, `content\reserach*.html` as well.
* Prefer consistent aspect ratios for carousel images, they are in `static` folder.

---

## Quick start (TL;DR)

```bash
# local
npm install
hugo server -D

# prod build
hugo --gc --minify

# render build
npm ci || npm install
curl -sSL -o /tmp/hugo.tar.gz "https://github.com/gohugoio/hugo/releases/download/v0.128.2/hugo_extended_0.128.2_Linux-64bit.tar.gz"
tar -xzf /tmp/hugo.tar.gz -C /tmp
/tmp/hugo --gc --minify --baseURL "${RENDER_EXTERNAL_URL}/"
```


