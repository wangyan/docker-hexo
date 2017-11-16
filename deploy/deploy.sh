#!/bin/bash
set -xe

POSTS_PATH='/opt/hexo/source/_posts'

echo "Start generation and deployment"
cd $POSTS_PATH
echo "pulling source code..."
git pull origin master
echo "generate and deploy..."
cd /opt/hexo
hexo clean
hexo g
echo "Finished."