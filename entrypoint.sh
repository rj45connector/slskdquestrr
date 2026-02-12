#!/bin/sh
set -e

SAFE_KEY=$(printf '%s' "${SLSKD_API_KEY}" | sed 's/["\]/\\&/g')

cat > /usr/share/nginx/html/config.js <<EOF
window.SLSKD_CONFIG = {
    API_KEY  : "${SAFE_KEY}",
    API_BASE : "/api/v0"
};
EOF

echo "[slskdquestrr] config.js written  (proxy -> ${SLSKD_BASE_URL})"

envsubst '${SLSKD_BASE_URL}' \
    < /etc/nginx/templates/default.conf.template \
    > /etc/nginx/conf.d/default.conf

echo "[slskdquestrr] nginx ready — starting"
exec nginx -g 'daemon off;'
SCRIPT

chmod +x entrypoint.sh