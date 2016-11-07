#!/bin/sh
hexo generate
hexo deploy
git add .
git commit -m '修改'
git push origin master
exit
