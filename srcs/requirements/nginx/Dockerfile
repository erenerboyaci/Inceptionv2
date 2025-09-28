FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx openssl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY ./conf/nginx.conf /etc/nginx/conf.d/nginx.conf
COPY ./tools/nginx_init.sh /usr/local/bin/nginx_init.sh
RUN chmod +x /usr/local/bin/nginx_init.sh \
 && mkdir -p /etc/nginx/ssl /var/log/nginx

EXPOSE 443
ENTRYPOINT ["/usr/local/bin/nginx_init.sh"]
CMD ["nginx", "-g", "daemon off;"]
