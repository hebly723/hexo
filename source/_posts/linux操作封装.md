---
title: linux操作封装
date: 2016-11-08 23:29:43
tags:
 - linux
categories:
 - 笔记
 - 心得
---

 ubuntu上一次次输入命令有时候会感到很烦,而且一些命令是绑在一起的,linux上提供了将它们封装在文件里进行一次调用的方法

<!-- more -->

 - 建立一个.sh文件,文件名任意

```bash
vim try.sh
```

 - 在其中添加信息头

```bash
#!/bin/bash
```

 - 在其后可添加要进行的操作,比如提交git并且推送

```bash
git commit -m '修改'
git push origin master
```

 - 填写完这些操作之后,在最后加上终结符

```bash
exit
```

 - 退出

 - 然后给这个文件加上执行权限

```bash
sudo chmod 777 try.sh
```

 - 执行文件

```bash
./try.sh
```

可以看到,写在文件中操作按序完成了
