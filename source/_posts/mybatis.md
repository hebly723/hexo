---
title: 一小时快速上手mybatis(Mapper代理开发,mysql数据库)
date: 2016-11-04 19:35:14
tags: 
 - Java
 - mysql
 - mybatis
categories:
 - 说明书
---

mybatis 东西确实多,但是如果只讲常用的,那就不多了

<!-- more -->

# MyBatis介绍

MyBatis 本是apache的一个开源项目iBatis, 2010年这个项目由apache software foundation 迁移到了google code，并且改名为MyBatis，实质上Mybatis对ibatis进行一些改进。 
MyBatis是一个优秀的持久层框架，它对jdbc的操作数据库的过程进行封装，使开发者只需要关注 SQL 本身，而不需要花费精力去处理例如注册驱动、创建connection、创建statement、手动设置参数、结果集检索等jdbc繁杂的过程代码。
Mybatis通过xml或注解的方式将要执行的各种statement（statement、preparedStatemnt、CallableStatement）配置起来，并通过java对象和statement中的sql进行映射生成最终执行的sql语句，最后由mybatis框架执行sql并将结果映射成java对象并返回。

# Mybatis架构

![mybatis架构](http://ww1.sinaimg.cn/mw690/005SWPzyjw1f9gephyn2cj30mw0d3q5v.jpg)

* mybatis配置
SqlMapConfig.xml，此文件作为mybatis的全局配置文件，配置了mybatis的运行环境等信息。
mapper.xml文件即sql映射文件，文件中配置了操作数据库的sql语句。此文件需要在SqlMapConfig.xml中加载。

* 通过mybatis环境等配置信息构造SqlSessionFactory即会话工厂
* 由会话工厂创建sqlSession即会话，操作数据库需要通过sqlSession进行。
* mybatis底层自定义了Executor执行器接口操作数据库，Executor接口有两个实现，一个是基本执行器、一个是缓存执行器。
* Mapped Statement也是mybatis一个底层封装对象，它包装了mybatis配置信息及sql映射信息等。mapper.xml文件中一个sql对应一个Mapped Statement对象，sql的id即是Mapped statement的id。
* Mapped Statement对sql执行输入参数进行定义，包括HashMap、基本类型、pojo，Executor通过Mapped Statement在执行sql前将输入的java对象映射至sql中，输入参数映射就是jdbc编程中对preparedStatement设置参数。
* Mapped Statement对sql执行输出结果进行定义，包括HashMap、基本类型、pojo，Executor通过Mapped Statement在执行sql后将输出结果映射至java对象中，输出结果映射过程相当于jdbc编程中对结果的解析处理过程。

# Mybatis下载

mybaits的代码由github.com管理，地址：https://github.com/mybatis/mybatis-3/releases
![mybatis包结构](http://ww4.sinaimg.cn/mw690/005SWPzyjw1f9gf47l6mjj304o05wt8p.jpg)
mybatis-3.2.7.jar----mybatis的核心包
lib----mybatis的依赖包
mybatis-3.2.7.pdf----mybatis使用手册

# Mybatis 项目搭建

## 导入包

使用eclipse/myeclipse创建java工程,使用最新的jdk
加入mybatis核心包,依赖包,数据驱动包
![mybatis依赖包](http://ww1.sinaimg.cn/mw690/005SWPzyjw1f9gfg636dnj3088074jsc.jpg)

## 目标的样子

![mybatis项目最终结构(参考)](http://ww4.sinaimg.cn/mw690/005SWPzyjw1f9gfmhmqw2j309108i3zo.jpg)

## 创建log4j.propertie,在里面加入下面的内容

```properties
# Global logging configuration
log4j.rootLogger=DEBUG, stdout
# Console output...
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%5p [%t] - %m%n
```
第二行的不同状态会导致控制台的不同输出结果
debug ：显示输出信息,报错信息,调试信息
info ：显示(输出信息)
所以如果设置为info的话,即便出错也不会知道,一般为开发完成的项目设置

## 创建SqlMapConfig.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
	<!-- 和spring整合后 environments配置将废除-->
	<environments default="development">
		<environment id="development">
		<!-- 使用jdbc事务管理-->
			<transactionManager type="JDBC" />
		<!-- 数据库连接池-->
			<dataSource type="POOLED">
				<property name="driver" value="com.mysql.jdbc.Driver" />
				<property name="url" value="jdbc:mysql://localhost:3306/world?characterEncoding=utf-8" />
				<property name="username" value="root" />
				<property name="password" value="123" />
			</dataSource>
		</environment>
	</environments>
	
</configuration>
```

但是将数据库信息写死在代码里不是个明智的选择,所以我们可以将它放在文件里,更易于修改

## 创建db.properties

```properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/mybatis
jdbc.username=root
jdbc.password=mysql
```

![db.properties](http://ww1.sinaimg.cn/mw690/005SWPzyjw1f9gh2ok2ccj30jf070wfo.jpg)

这样在SqlMapConfig.xml中就可以这样引用


```xml
<properties resource="db.properties"/>
	<environments default="development">
		<environment id="development">
			<transactionManager type="JDBC"/>
			<dataSource type="POOLED">
				<property name="driver" value="${jdbc.driver}"/>
				<property name="url" value="${jdbc.url}"/>
				<property name="username" value="${jdbc.username}"/>
				<property name="password" value="${jdbc.password}"/>
			</dataSource>
		</environment>
	</environments>
```

信息变化的时候改文件就行了

## po类

Po类作为mybatis进行sql映射使用，po类通常与数据库表对应，User.java如下：

```java
package cn.itcast.mybatis.po;

public class City {
	//属性名要和数据库表的字段对应
	private int ID;
	private String Name;
	private String CountryCode;
	private String District;
	private int Population;
	get...
	set...
}

```

## 编写核心程序

### mapper动态代理方式

Mapper接口开发方法只需要程序员编写Mapper接口（相当于Dao接口），由Mybatis框架根据接口定义创建接口的动态代理对象，代理对象的方法体同上边Dao接口实现类方法。
Mapper接口开发需要遵循以下规范：
1、 Mapper.xml文件中的namespace与mapper接口的类路径相同。
2、 Mapper接口方法名和Mapper.xml中定义的每个statement的id相同 
3、 Mapper接口方法的输入参数类型和mapper.xml中定义的每个sql 的parameterType的类型相同
4、 Mapper接口方法的输出参数类型和mapper.xml中定义的每个sql的resultType的类型相同 

### 映射文件

sqlmap目录下创建sql映射文件city.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC 
"-//mybatis.org//DTD Mapper 3.0//EN" 
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="test">
</mapper>
```
namespace ：命名空间，用于隔离sql语句,以及标识mapper。

### 建立mapper.xml

![mapper.xml的位置](http://ww1.sinaimg.cn/mw690/005SWPzyjw1f9h38tw21sj307y01u3yl.jpg)

#### 目标的样子

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC 
"-//mybatis.org//DTD Mapper 3.0//EN" 
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="cn.itcast.mybatis.mapper.CityMapper">
<sql id="query_user_where">
		<if test="value!=null">
					and Name like '%${value}%'
		</if>
	</sql>
<select id="findCityById" parameterType="int" 
	resultType="City" >
		select * from city where ID = #{id }
	</select>
<select id="findCityByName" parameterType="java.lang.String" 
	resultType="City"> 	
		select * from city 
		<where> 
			<include refid="query_user_where"></include>
		</where> 
	</select>
<select id="findCityByHashMap" parameterType="hashmap" resultType="City">
		select * from city where ID = #{ID} and Name like '%${Name}%'
	</select>
<insert id="insertCity" parameterType="City" >
<selectKey keyProperty="ID" order="AFTER" resultType="java.lang.Integer">
			SELECT LAST_INSERT_ID()
		</selectKey>
		insert into city(Name, CountryCode, District, Population) 
		value(#{Name}, #{CountryCode}, #{District}, #{Population})
	</insert>
<delete id="deleteCity" parameterType="java.lang.Integer">
		delete from city where ID = #{id}
	</delete>
<update id="updateCity" parameterType="City">
		update city set Name=#{Name}, CountryCode=#{CountryCode},
		 District=#{District}, Population=#{Population} where ID=#{ID}
	</update>
```

### 查询

```xml
<select id="findCityById" parameterType="int" 
	resultType="City" >
		select * from city where ID = #{id }
	</select>
```

* select: 表明当前是查询语句

* id : 语句的标识符,与之后mapper.java的方法名相对应

* parameterType : 指定可接受的参数类型可以是map,po,或者简单类型

* resultType : 返回的参数类型,可以是map,po,或者简单类型

#{}表示一个占位符号，通过#{}可以实现preparedStatement向占位符中设置值，自动进行java类型和jdbc类型转换，#{}可以有效防止sql注入。 #{}可以接收简单类型值或pojo属性值。 如果parameterType传输单个简单类型值，#{}括号中可以是value或其它名称。
${}表示拼接sql串，通过${}可以将parameterType 传入的内容拼接在sql中且不进行jdbc类型转换， ${}可以接收简单类型值或pojo属性值，如果parameterType传输单个简单类型值，${}括号中只能是value。

例

```xml
<select id="findCityByHashMap" parameterType="hashmap" resultType="City">
		select * from city where ID = #{ID} and Name like '%${Name}%'
	</select>
```

此时ID与Name代表的就是map中的不同元素

### sql片段

```xml
<sql id="query_user_where">
                <if test="value!=null">
                                        and Name like '%${value}%'
                </if>
        </sql>
<select id="findCityByName" parameterType="java.lang.String" 
	resultType="City"> 	
		select * from city 
		<where> 
			<include refid="query_user_where"></include>
		</where> 
	</select>
```
sql中能封装sql语句,其他的语句能够通过引用id来使用
定义sql片段
id：sql片段的唯一标识 
经验：是基于单表来定义sql片段，这样话这个sql片段可重用性才高
在sql片段中不要包含where
使用where之后第一个and自动去除
引用sql片段的Id，如果refid指定的id不在本mapper文件中，需要前边加namespace
if 中的 test 相当于判断语句,先执行判断

### 添加

```xml
<insert id="insertCity" parameterType="City" >
		insert into city(Name, CountryCode, District, Population) 
		value(#{Name}, #{CountryCode}, #{District}, #{Population})
</insert>
```

...感觉没什么好讲的,就是普通的sql语句,如果此时写上"resultType = Intege", 当插入成功的时候就返回1,失败的时候就返回0

但是如果数据库设计主键是自增的,那么如何得知插入后对应的主键是多少
```xml
<insert id="insertCity" parameterType="City" >
<selectKey keyProperty="ID" order="AFTER" resultType="java.lang.Integer">
			SELECT LAST_INSERT_ID()
		</selectKey>
insert into city(Name, CountryCode, District, Population) 
		value(#{Name}, #{CountryCode}, #{District}, #{Population})
</insert>
```
keyProperty:返回的主键存储在pojo中的哪个属性
order：selectKey的执行顺序，是相对与insert语句来说，由于mysql的自增原理执行完insert语句之后才将主键生成，所以这里selectKey的执行顺序为after
resultType:返回的主键是什么类型
LAST_INSERT_ID():是mysql的函数，返回auto_increment自增列新记录id值。

如果使用uuid实现主键
```xml
<insert id="insertCity" parameterType="City" >
<selectKey keyProperty="ID" order="BEFORE" resultType="java.lang.String">
                        SELECT uuid()
                </selectKey>
insert into city(Name, CountryCode, District, Population)
                value(#{Name}, #{CountryCode}, #{District}, #{Population})
</insert>
```
以上两种方法均建立在数据库是mysql的基础上

### 删除

```xml
<delete id="deleteCity" parameterType="java.lang.Integer">
		delete from city where ID = #{id}
	</delete>
```

...感觉还是相当简单,,,极易看懂

### 修改

```xml
<update id="updateCity" parameterType="City">
		update city set Name=#{Name}, CountryCode=#{CountryCode},
		 District=#{District}, Population=#{Population} where ID=#{ID}
	</update>
```

与mysql语法没什么区别

### 编写mapper.java

```java
//mapper接口,相当于dao接口， 用户管理
public interface CityMapper {
	//根据ID查询城市的信息
	public City findCityById(int ID) throws Exception;
	
	//根据姓名查询城市信息
	public List<City> findCityByName(String Name)throws Exception;
	
	//添加城市信息
	public void insertCity(City city)throws Exception;
	
	//删除城市信息
	public void deleteCity(int ID) throws Exception;

	//修改城市信息
	public void updateCity(City city);
}
```

函数名对应的就是xml文件中的id

返回值对应的是resultType

参数对应的是parammeterType

如果返回值或者参数不止一个,对应的就使用数组传递或者接收;如果只有一个,就使用本来类型进行传递或者接收

写到这里就能进行程序的测试了

### sqlMapConfig.xml中引入

```xml
		</dataSource>
		</environment>
	</environments>
<mappers>
<mapper resource="sqlmap/City.xml"/>
<package name="cn.itcast.mybatis.mapper"/>
	</mappers>
</configuration>
```
通过mapper接口加载映射文件
遵循一些规范：需要将mapper接口类名和mapper.xml映射文件名称保持一致，
且在一个目录中 

### 测试

在package exployer中选中mapper.java,右键new(新建) -> other(其他)
![新建测试代码](http://ww2.sinaimg.cn/mw690/005SWPzyjw1f9hbyv6vu4j30g009n0tf.jpg)

![设置测试代码位置以及开始方法](http://ww3.sinaimg.cn/mw690/005SWPzyjw1f9hc3e8v2gj30k10jwq6o.jpg)

![设置测试方法](http://ww3.sinaimg.cn/mw690/005SWPzyjw1f9hc3izq9uj30jh0jvgny.jpg)

![生成测试代码](http://ww4.sinaimg.cn/mw690/005SWPzyjw1f9hc3y6w7cj30dn0bzgn4.jpg)

重写setUp方法,定义全局变量sqlSessionFactory
```java
public class CityMapperTest {
	private SqlSessionFactory sqlSessionFactory;
	@Before
	public void setUp() throws Exception {
		//mybatis配置文件
				String resource = "SqlMapConfig.xml";
				//得到配置文件流
				InputStream inputStream=Resources.getResourceAsStream(resource);
				//创建会话工厂，传入mybatis的配置文件信息
				this.sqlSessionFactory = new SqlSessionFactoryBuilder().
								build(inputStream);
	}
```

sqlSessionFactory是一个工厂方法,能用于创建数据库会话,数据库会话中能够得到mapper对象

#### 查询

```Java
@Test
	public void testFindCityById() throws Exception {
		SqlSession sqlSession = sqlSessionFactory.openSession();
		
		//创建CityMapper对象，mybatis自动生成mapper代理对象
		CityMapper cityMapper = sqlSession.getMapper(CityMapper.class);
		
		//调用CityMapper方法
		City city = cityMapper.findCityById(1);
		
		sqlSession.close();
		
		System.out.println(city);
	}
```
最后要关闭sqlsession会话
此时返回的是一个po

```java
@Test
	public void testFindCityByName() throws Exception{
		
		SqlSession sqlSession = sqlSessionFactory.openSession();
		
		//创建CityMapper对象，mybatis自动生成mapper代理对象
		CityMapper cityMapper = sqlSession.getMapper(CityMapper.class);
		
		//调用CityMapper方法
		List<City> list = cityMapper.findCityByName("KIK");
		
		sqlSession.close();
		
		System.out.println(list);
	}
```

此时返回的是一个list

##### selectOne和selectList

动态代理对象调用sqlSession.selectOne()和sqlSession.selectList()是根据mapper接口方法的返回值决定，如果返回list则调用selectList方法，如果返回单个对象则调用selectOne方法
#### 添加

```java
@Test
	public void testInsertCity() throws Exception{
		SqlSession sqlSession = sqlSessionFactory.openSession();
		
		City city = new City();
		city.setCountryCode("HHH");
		city.setName("WHH");
		city.setDistrict("KQS");
		city.setPopulation(13);
		//创建CityMapper对象，mybatis自动生成mapper代理对象
		CityMapper cityMapper = sqlSession.getMapper(CityMapper.class);
		
		//调用CityMapper方法
		cityMapper.insertCity(city);
		
		sqlSession.close();
		
		System.out.println();
	}
```

#### 删除

```java
@Test
	public void testDeleteCity() throws Exception{
		SqlSession sqlSession = sqlSessionFactory.openSession();
		
		//创建CityMapper对象，mybatis自动生成mapper代理对象
		CityMapper cityMapper = sqlSession.getMapper(CityMapper.class);
		
		//调用CityMapper方法
		cityMapper.deleteCity(4084);;
		
		sqlSession.close();
		
		System.out.println();
	}
```

#### 修改

```java
@Test
	public void testUpdateCity(){
		SqlSession sqlSession = sqlSessionFactory.openSession();
		
		//创建CityMapper对象，mybatis自动生成mapper代理对象
		CityMapper cityMapper = sqlSession.getMapper(CityMapper.class);
		
		//调用CityMapper方法
		City city2 = new City();
		city2.setCountryCode("HHH");
		city2.setName("WHH");
		city2.setDistrict("KQS");
		city2.setPopulation(13);
		city2.setID(1);
		cityMapper.updateCity(city2);
		sqlSession.close();
		
	}
```

### 自动生成(mabatis逆向工程)

当你懒得写mapper的时候.....
mapper.xml与mapper.java都可以自动生成.....

![自动生成mapper的java工程结构](http://ww3.sinaimg.cn/mw690/005SWPzyjw1f9hcvjjfi7j308h0893zm.jpg)


修改generatorConfig.xml 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
  PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
  "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">

<generatorConfiguration>
	<context id="testTables" targetRuntime="MyBatis3">
		<commentGenerator>
			<!-- 是否去除自动生成的注释 true：是 ： false:否 -->
			<property name="suppressAllComments" value="true" />
		</commentGenerator>
		<!--数据库连接的信息：驱动类、连接地址、用户名、密码 -->
		<jdbcConnection driverClass="com.mysql.jdbc.Driver"
			connectionURL="jdbc:mysql://localhost:3306/world" userId="root"
			password="123">
		</jdbcConnection>
		<!-- <jdbcConnection driverClass="oracle.jdbc.OracleDriver"
			connectionURL="jdbc:oracle:thin:@127.0.0.1:1521:yycg" 
			userId="yycg"
			password="yycg">
		</jdbcConnection> -->

		<!-- 默认false，把JDBC DECIMAL 和 NUMERIC 类型解析为 Integer，为 true时把JDBC DECIMAL 和 
			NUMERIC 类型解析为java.math.BigDecimal -->
		<javaTypeResolver>
			<property name="forceBigDecimals" value="false" />
		</javaTypeResolver>

		<!-- targetProject:生成PO类的位置 -->
		<javaModelGenerator targetPackage="po"
			targetProject="./src">
			<!-- enableSubPackages:是否让schema作为包的后缀 -->
			<property name="enableSubPackages" value="false" />
			<!-- 从数据库返回的值被清理前后的空格 -->
			<property name="trimStrings" value="true" />
		</javaModelGenerator>
        <!-- targetProject:mapper映射文件生成的位置 -->
		<sqlMapGenerator targetPackage="mapper" 
			targetProject="./src">
			<!-- enableSubPackages:是否让schema作为包的后缀 -->
			<property name="enableSubPackages" value="false" />
		</sqlMapGenerator>
		<!-- targetPackage：mapper接口生成的位置 -->
		<javaClientGenerator type="XMLMAPPER"
			targetPackage="mapper" 
			targetProject="./src">
			<!-- enableSubPackages:是否让schema作为包的后缀 -->
			<property name="enableSubPackages" value="false" />
		</javaClientGenerator>
		<!-- 指定数据库表 -->
		<table tableName="city"></table>
		<!-- <table schema="" tableName="sys_user"></table>
		<table schema="" tableName="sys_role"></table>
		<table schema="" tableName="sys_permission"></table>
		<table schema="" tableName="sys_user_role"></table>
		<table schema="" tableName="sys_role_permission"></table> -->
		
		<!-- 有些表的字段需要指定java类型
		 <table schema="" tableName="">
			<columnOverride column="" javaType="" />
		</table> -->
	</context>
</generatorConfiguration>

```

生成之后记得点击刷新,生成的mapper.xml与mapper.java就会显示在项目目录下了
./src只针对linux系统,目录之间是/
windows是.\src,目录之间是\

![生成之后的mapper.xml与mapper.java](http://ww2.sinaimg.cn/mw690/005SWPzyjw1f9hdaxga61j309e0brdhn.jpg)

然后就可以复制黏贴了,注意,在哪里生成的必须贴在同样的相对目录下面,比如在./src下生成的,也必须拷贝到./src下,而不能在./src/map下

使用例子
查询
```Java
SignExample example = new SignExample();
SignExample.Criteria criteria = example.createCriteria();
criteria.andSigPerIdEqualTo(sigPerId);
return (Sign) mapper.selectByExample(example);
```
计算
```java
SignExample example = new SignExample();
SignExample.Criteria criteria = example.createCriteria();
criteria.andSigAcIdEqualTo(acId);
return mapper.countByExample(example);
```
更新
```java
return mapper.updateByPrimaryKeySelective(Sign);
```
删除
```java
mapper.deleteByPrimaryKey(sign.getSigId());
```
添加
```java
return mapper.insertSelective(Sign);
```
但是遇到联表查询的情况,仍然需要自己编写mapper

### resultMap

resultType可以指定pojo将查询结果映射为pojo，但需要pojo的属性名和sql查询的列名一致方可映射成功。
	如果sql查询字段名和pojo的属性名不一致，可以通过resultMap将字段名和属性名作一个对应关系 ，resultMap实质上还需要将查询结果映射到pojo对象中。
	resultMap可以实现将查询结果映射为复杂类型的pojo，比如在查询结果映射对象中包括pojo和list实现一对一查询和一对多查询。

mapper.xml中定义
```xml
 <resultMap id="BaseResultMap" type="po.City" >
    <id column="ID" property="id" jdbcType="INTEGER" />
    <result column="Name" property="name" jdbcType="CHAR" />
    <result column="CountryCode" property="countrycode" jdbcType="CHAR" />
    <result column="District" property="district" jdbcType="CHAR" />
    <result column="Population" property="population" jdbcType="INTEGER" />
  </resultMap>
```

column 对应的是数据库查询结果的属性, property对应的是po中的属性

参考文档:http://og7tyqvd1.bkt.clouddn.com/mybatis-mrt-2.2.docx

mybatis逆向工程下载地址:http://og7tyqvd1.bkt.clouddn.com/generatorSqlmapCustom.zip
