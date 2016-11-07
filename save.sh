#!/bin/sh
git add .
git commit -m '修改'
git push origin master
hexo generate
hexo deploy
exit
