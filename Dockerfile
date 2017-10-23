FROM idiswy/node:latest
LABEL authors="WangYan <i@wangyan.org>"

# Setup Nginx
RUN set -xe && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl wget unzip git net-tools ca-certificates --no-install-recommends && \
    curl -O "http://nginx.org/keys/nginx_signing.key" && \
    apt-key add nginx_signing.key && \
    rm -f nginx_signing.key && \
    echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y ca-certificates nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak && \
    mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/hexo.conf /etc/nginx/conf.d/hexo.conf

# Nginx Runit
RUN mkdir -p /etc/service/nginx && \
    echo '#!/bin/sh' >> /etc/service/nginx/run && \
    echo 'exec 2>&1' >> /etc/service/nginx/run && \
    echo 'exec nginx -g "daemon off;"' >> /etc/service/nginx/run && \
    chmod +x /etc/service/nginx/run

# Hexo config
RUN mkdir -p /opt/hexo /var/lib/hexo
WORKDIR /opt/hexo

COPY ./deploy/index.js /var/lib/hexo/index.js
COPY ./deploy/deploy.sh /var/lib/hexo/deploy.sh
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /etc/service/nginx/run /var/lib/hexo/deploy.sh /entrypoint.sh

# Expose Ports
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/sbin/my_init"]