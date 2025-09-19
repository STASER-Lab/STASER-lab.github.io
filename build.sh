# 1) Install theme deps (Bootstrap, PostCSS, etc.)
npm ci || npm install

# 2) Download Hugo Extended (needed for SCSS compilation)
export HUGO_VERSION=0.128.2
curl -sSL -o /tmp/hugo.tar.gz \
  "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz"
tar -xzf /tmp/hugo.tar.gz -C /tmp

# 3) Build with the correct baseURL from Render
/tmp/hugo --gc --minify --baseURL "${RENDER_EXTERNAL_URL}/"
