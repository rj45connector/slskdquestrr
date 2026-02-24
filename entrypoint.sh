#!/bin/sh
set -e

# Replace the placeholder with the real slskd url
sed "s|__SLSKD_BASE_URL__|${SLSKD_BASE_URL}|g" \
    /etc/nginx/templates/default.conf.template \
    > /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'