#!/bin/bash
set -x

# Aliyun
if [ "$APT_MIRRORS" = "aliyun" ];then
    sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
    npm  config set registry https://registry.npm.taobao.org
fi

# Yarn
npm install -g yarn
if [ "$APT_MIRRORS" = "aliyun" ];then
    yarn config set registry https://registry.npm.taobao.org
    npm upgrade --global yarn
fi

# Hexo && PM2
yarn global add hexo-cli pm2
cd /opt/hexo
[ ! -f "/opt/hexo/_config.yml" ] && hexo init .
[ ! -f "/opt/hexo/deploy.sh" ] && cp /var/lib/hexo/deploy.sh /opt/hexo
yarn install
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