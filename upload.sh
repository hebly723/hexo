#!/bin/sh
hexo clean
hexo generate
hexo deploy
git add .
git commit -m $update
git push origin master
exit
