#!/bin/sh
hexo clean
hexo generate
hexo deploy
git add -A .
git commit -m $update
git push origin master
exit
