FROM idiswy/node:latest
MAINTAINER WangYan <i@wangyan.org>

# Setup Nginx
RUN curl -O "http://nginx.org/keys/nginx_signing.key" && \
    apt-key add nginx_signing.key && \
    echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y apt-utils nginx && \
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak && \
    rm -Rf /etc/nginx/conf.d/*

# APT Clean
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ./nginx_signing.key

# Nginx config
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf
COPY ./nginx/hexo.conf /etc/nginx/conf.d/hexo.conf

# Runit Config
RUN mkdir -p /etc/service/nginx/log/
COPY ./runit/nginx.sh /etc/service/nginx/run
COPY ./runit/nginx_log.sh /etc/service/nginx/log/run

# Hexo config
RUN mkdir -p /opt/hexo /var/lib/hexo
WORKDIR /opt/hexo

COPY ./deploy/github.js /var/lib/hexo/github.js
COPY ./deploy/gitlab.js /var/lib/hexo/gitlab.js
COPY ./deploy/deploy.sh /var/lib/hexo/deploy.sh
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /etc/service/nginx/run /etc/service/nginx/log/run \
             /var/lib/hexo/deploy.sh /entrypoint.sh

# Expose Ports
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/sbin/my_init"]