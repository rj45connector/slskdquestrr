FROM nginx:1.27-alpine

RUN rm -f /etc/nginx/conf.d/default.conf

COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
COPY public/index.html           /usr/share/nginx/html/index.html
COPY entrypoint.sh               /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENV SLSKD_BASE_URL=http://slskd:5030

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]