#!/bin/sh
set -e

SLSKD_BASE_URL="${SLSKD_BASE_URL:-http://localhost:5030}"
SLSKD_API_KEY="${SLSKD_API_KEY:-}"

# ── strip trailing slash from base URL ──
SLSKD_BASE_URL="${SLSKD_BASE_URL%/}"

# ── render nginx config (path must match Dockerfile COPY) ──
sed \
  -e "s|__SLSKD_BASE_URL__|${SLSKD_BASE_URL}|g" \
  -e "s|__SLSKD_API_KEY__|${SLSKD_API_KEY}|g" \
  /etc/nginx/templates/default.conf.template \
  > /etc/nginx/conf.d/default.conf

# ── render frontend config.js ──
cat > /usr/share/nginx/html/config.js <<EOF
window.SLSKD_CONFIG = {
    API_KEY  : "${SLSKD_API_KEY}",
    API_BASE : "/api/v0"
};
EOF

echo "[slskdquestrr] config.js written  (proxy -> ${SLSKD_BASE_URL})"
echo "[slskdquestrr] nginx ready — starting"

# ── hand off to nginx ──
exec nginx -g "daemon off;"