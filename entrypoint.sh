#!/bin/bash
set -xe

# Aliyun
if [ "$APT_MIRRORS" = "aliyun" ];then
    sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
    npm  config set registry https://registry.npm.taobao.org
    yarn config set registry https://registry.npm.taobao.org
fi

# Hexo && PM2
if [ ! -f "/opt/hexo/_config.yml" ];then
    yarn global add yarn
    yarn global add hexo-cli pm2
    hexo init .
    yarn install
fi
[ ! -f "/opt/hexo/deploy.sh" ] && cp /var/lib/hexo/deploy.sh /opt/hexo
hexo clean
hexo g

[ -z $WEBHOOK_SECRET ] && WEBHOOK_SECRET=123456
[ ! -f "/opt/hexo/index.js" ] && cp /var/lib/hexo/index.js /opt/hexo
sed -i "s/WEBHOOK_SECRET/$WEBHOOK_SECRET/" /opt/hexo/index.js

# Github webhook
if [ ! -z $GITHUB ];then
  yarn add github-webhook-handler
  sed -i "s/WEBHOOK-HANDLER/github-webhook-handler/" /opt/hexo/index.js
  rm -rf /opt/hexo/source/_posts
  git clone $GITHUB /opt/hexo/source/_posts
  pm2 start index.js --name hexo
  /opt/hexo/deploy.sh
fi

# Gitlab webhook
if [ ! -z $GITLAB ];then
  yarn add node-gitlab-webhook
  sed -i "s/WEBHOOK-HANDLER/node-gitlab-webhook/" /opt/hexo/index.js
  rm -rf /opt/hexo/source/_posts
  git clone $GITLAB /opt/hexo/source/_posts
  pm2 start index.js --name hexo
  /opt/hexo/deploy.sh
fi

# Nginx
[ -z $IP_OR_DOMAIN ] && IP_OR_DOMAIN=$(hostname -i)
sed -i "s/IP_OR_DOMAIN/$IP_OR_DOMAIN/" /etc/nginx/conf.d/hexo.conf

exec "$@"