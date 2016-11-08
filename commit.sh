#!/bin/sh
hexo clean
hexo generate
git add .
git commit -m '修改'
exit
