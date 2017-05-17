#!/bin/bash
set -x

if [ "$APT_MIRRORS" = "aliyun" ];then
    sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
    npm config set registry https://registry.npm.taobao.org
fi

# Hexo
npm install -g hexo-cli pm2
cd /opt/hexo
[ ! -f "/opt/hexo/_config.yml" ] && hexo init .
[ ! -f "/opt/hexo/deploy.sh" ] && cp /var/lib/hexo/deploy.sh /opt/hexo
npm install

# Github webhook
if [ ! -z $GITHUB ];then
  npm install github-webhook-handler
  [ -z $WEBHOOK_SECRET ] && WEBHOOK_SECRET=123456
  [ ! -f "/opt/hexo/github.js" ] && cp /var/lib/hexo/github.js /opt/hexo
  sed -i "s/WEBHOOK_SECRET/$WEBHOOK_SECRET/" /opt/hexo/github.js
  rm -rf /opt/hexo/source/_posts
  git clone $GITHUB /opt/hexo/source/_posts
  pm2 start github.js --name hexo
  pm2 save
  pm2 startup ubuntu
  chmod +x /etc/init.d/pm2-init.sh
  update-rc.d pm2-init.sh defaults
  /opt/hexo/deploy.sh
fi

# Gitlab webhook
if [ ! -z $GITLAB ];then
  npm install gitlab-webhook-handler
  [ ! -f "/opt/hexo/gitlab.js" ] && cp /var/lib/hexo/gitlab.js /opt/hexo
  rm -rf /opt/hexo/source/_posts
  git clone $GITLAB /opt/hexo/source/_posts
  pm2 start gitlab.js --name hexo
  pm2 save
  pm2 startup ubuntu
  chmod +x /etc/init.d/pm2-init.sh
  update-rc.d pm2-init.sh defaults
  /opt/hexo/deploy.sh
fi

# Nginx
[ -z $IP_OR_DOMAIN ] && IP_OR_DOMAIN=$(hostname -i)
sed -i "s/IP_OR_DOMAIN/$IP_OR_DOMAIN/" /etc/nginx/conf.d/hexo.conf

exec "$@"