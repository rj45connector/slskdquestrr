#!/bin/sh
set -e

SLSKD_BASE_URL="${SLSKD_BASE_URL:-http://localhost:5030}"
SLSKD_BASE_URL="${SLSKD_BASE_URL%/}"

sed \
  -e "s|__SLSKD_BASE_URL__|${SLSKD_BASE_URL}|g" \
  /etc/nginx/templates/default.conf.template \
  > /etc/nginx/conf.d/default.conf

cat > /usr/share/nginx/html/config.js <<EOF
window.SLSKD_CONFIG = {
    API_BASE : "/api/v0"
};
EOF

echo "[slskdquestrr] nginx ready (proxy -> ${SLSKD_BASE_URL})"
exec nginx -g "daemon off;"