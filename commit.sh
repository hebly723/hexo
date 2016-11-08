#!/bin/sh
hexo clean
hexo generate
git add .
git commit -m $update
echo $update
exit
