#!/bin/sh
hexo clean
hexo generate
git add .
git commit -m \"$write\"
echo $write
exit
