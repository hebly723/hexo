---
title: Integer中的parseInt
date: 2016-10-11 20:42:24
tags: 
 - Java
 - 类型转换
 - 整数
 - 字符串

categories: 
 - 笔记
 - 心得
---
Java自带了Integer工具类。

<!-- more -->

Integer类中，有一个方法parseInt，用于字符串和数字之间的转换

例子

```java
String words = "12";
int k = Integer.parseInt(words);
```
转换能成功完成
但是如果这样
```java
String words = " 12 ";
int k = Integer.parseInt(words);
```
失败，因为数字两边有空格
可以用Java String类的trim方法消掉两边的字符串
```java
String words = " 12 ";
int k = Integer.parseInt(words.trim());
```
转换能成功完成
即便现在不是String类型，比如Map中存储字符串，作为参数传递时失去了类型，String强转之后仍然能够使用同样的方法将其变成整数
```java
String ws =(String) words;
int k = Integer.parseInt(ws.trim());
```
