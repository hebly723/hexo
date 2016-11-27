#!/bin/sh
hexo clean
hexo generate
git add -A .
git commit -m "日常修改"
git push origin master
exit
