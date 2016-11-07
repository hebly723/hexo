---
title: linux上的github免去输入账号密码
date: 2016-11-07 22:32:57
tags:
 - linux
 - git
categories:
 - 说明书
---

一直输入用户名密码很烦吧

<!-- more -->

 # 进入当前用户目录下

```bash
cd ~
```

 # 新建文件

```bash
vim .git-credentials
```
在其中写入下列信息
```
https://{username}:{password}@github.com
```
其中的{username}替换为github上用户名,{password}替换为密码

 # 保存退出
 
 # 执行命令

```bash
git config --global credential.helper store
```
执行完后

/home/用户名/.gitconfig 会新增一项
```
[credential]
        helper = store
```

然后git push 跟git pull就无需输入账号密码了

原网址:http://blog.sina.com.cn/s/blog_96e3da700102weuv.html
