# docker-hexo

基于 `Ubuntu 16.04`、NodeJs: `v6.x`、Nginx `1.10.x` 构建，一键自动安装最新版的 `Hexo`，使用Nginx作为web服务器，支持Git自动发布。

## 一、流程简介

1. 首先在Github或者GitLab上编辑文章（或者本地`git push`)
2. 然后会触发`webhook`，自动将git上的md文件拉取到 `/opt/hexo/source/_posts` 文件夹
3. 接着自动执行`hexo g`操作，生成静态文件。
4. 最后通过网址访问，结束。

## 二、安装 Docker

关于Docker 更多信息，请访问其官网。<https://docs.docker.com>

**debian**

```shell
apt-get update && \
apt-get -y install curl && \
curl -fsSL https://get.daocloud.io/docker | sh \
update-rc.d -f docker defaults && \
service docker start
```

 **CentOS**

```shel
yum update && \
curl -fsSL https://get.docker.com/ | sh && \
systemctl enable docker.service && \
systemctl start docker.service
```

## 三、安装 Hexo

- `IP_OR_DOMAIN` 服务器IP或者域名  
- `GITHUB` github自动发布地址（Gitlab 请使用 `-e GITLAB=http://xxx`） 
- 请注意：私有项目仓库地址格式是：`https://username:password@RepoURL`  
- `WEBHOOK_SECRET`  webhook 密钥
- `APT_MIRRORS` 使用国内软件源

> 国内主机可将 `idiswy/hexo:latest` 换成 `daocloud.io/wangyan/hexo:latest`  
> 国内主机可用 `-e APT_MIRRORS=aliyun` 选项，使用国内的镜像源。


```shell
docker run --name hexo \
-v /opt/hexo:/opt/hexo \
-p 80:80 \
-p 443:443 \
-e IP_OR_DOMAIN=wangyan.org \
-e GITHUB=https://github.com/wangyan/hexo \
-e WEBHOOK_SECRET=123456 \
-d idiswy/hexo:latest
```

```shell
docker run --name hexo \
-v /opt/hexo:/opt/hexo \
-p 80:80 \
-p 443:443 \
-e IP_OR_DOMAIN=wangyan.org \
-e GITLAB=https://wang_yan:123456@gitlab.com/wang_yan/hexo.git \
-e WEBHOOK_SECRET=123456 \
-d idiswy/hexo:latest
```

安装可能需要30秒左右，通过下面方法查看安装进度。

```shell
docker logs -f hexo //查看安装进度
```
## 四、配置 webhook

> 注意将`youdomain`替换成你的网站域名，secret密钥可以随便设置

![https://raw.githubusercontent.com/idiswy/docker-hexo/master/docs/images/webhook.jpg](https://raw.githubusercontent.com/idiswy/docker-hexo/master/docs/images/webhook.jpg)

## 五、Hexo 常用命令

### 5.1 安装Hexo

```shell
npm install hexo -g #全局安装hexo
npm update hexo -g #升级hexo
hexo init #初始化,新建一个网站
```
了解更多：<https://hexo.io/zh-cn/docs/index.html>

### 5.2 启动服务器

```shell
hexo server # 启动web服务器（默认端口4000，'ctrl + c'关闭）
hexo server -s #静态模式
hexo server -p 5000 #启动时，自定义端口
hexo server -i 192.168.1.1 #启动时，自定义 IP
```

了解更多：<https://hexo.io/zh-cn/docs/server.html>


### 5.3 写作

#### new命令

```shell
hexo new [layout] <title> #新建
# layout对应三种布局：post、page、draft，默认为post
```

```shell
hexo new "postName" #新建文章
hexo new page "pageName" #新建页面
hexo new draft "draftName" #新建草稿
```

#### 自定义文章信息

```shell
---
title: 文章标题
layout: post （可选）
date: 2016-01-01 00:00
comments: true（可选）
categories: 学习笔记（可选）
tag:  标签（可选）
- tag1
- tag2
keywords: 关键词（可选）
description:描述（可选）
---
```

####设置文章摘要

```shell
以上是文章摘要 <!--more--> 以下是余下全文
```

### 5.4 生成静态文件

```shell
hexo generate #生成静态页面至public目录
hexo generate --watch #生成静态页面，同时监视文件变动
```

了解更多：<https://hexo.io/zh-cn/docs/writing.html>


### 5.5 部署（选做）

```shell
hexo deploy #部署到远程服务器
hexo generate --deploy #生成静态页面后自动部署
```

了解更多：<https://hexo.io/zh-cn/docs/deployment.html>


### 5.6 常用简写

```shell
hexo n "hello world" == hexo new "hello" #新建文章hello world
hexo p == hexo publish #将草稿发布为这正式文章
hexo g == hexo generate #生成静态文件
hexo s == hexo server #启动服务器
hexo d == hexo deploy #部署
```

了解更多Hexo命令：<https://hexo.io/zh-cn/docs/commands.html>

## 六、了解更多

关于`Hexo`更多信息，请访问其官网。<https://hexo.io>

更多使用帮助请阅读`wiki`，其他问题欢迎在`issues`中反馈。