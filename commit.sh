#!/bin/sh
hexo clean
hexo generate
git add -A .
git commit -m $update
echo $update
exit
