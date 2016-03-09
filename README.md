# AZFMDB

u can fast and convenient use sqllite to develop your app.

更加快速 更加便捷的 使用sqllite。

> 在fmdb基础上进行的封装，可以使用间断的sql语句 或者 单一的 model 实现对sqllite3的增删改查。
> —— © Andrew 

 
 
#### 关于

AZFMDB 下包含了FMDB，另外还含有 core 文件夹。内部有：

![](picture/1.png)

AZDao 数据模型处理:

```
/**
 *  获取模型的成员变量的类型在sqllite中的类型  并返回键值对（映射）
 * !!! 对像中的成员变量必须是 cocoa 下的类型 不能有基础类型
 *
 *  @param model model实例
 *
 *  @return NSDictionary
 */
+(NSDictionary *)propertySqlDictionaryFromModel:(id)model;


/**
 *  获取一个对象的 成员变量 键值对 （映射）
 * !!! 对像中的成员变量必须是 cocoa 下的类型 不能有基础类型
 *
 *  @param model model实例
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)propertyKeyValueFromModel:(id)model;

```

其中的 

```
+ (NSDictionary *)propertyKeyValueFromModel:(id)model;

```

可以在任何其他的地方，需要将model转为NSDictionary的地方使用（映射）。

###### !!! 注意：model中的成员变量必须是 cocoa 下的类型 ,不能使用基础类型,也不能使用自定义类型。例如：NSInteger CGFloat bool 等 都必须使用 NSNumber 包装一下。


//

//


AZDataManager 继承自 AZDataBaseManager，外部直接使用 AZDataManager 的单例即可。


 
### 1.加入AZFMDB到工程中
将AZFMDB加入你的工程，然后

```
#import "AZFMDB.h"

```

### 2.使用API

有两种方式操作，一类是直接使用单一model的方式去操作数据库(以下简称：model)，另一类是使用简短的sql语句去操作数据库（以下简称：brief_sql）。

##### 2.1 创建数据库

```
[AZDataManager shareManager];
```
指定项目数据库路径为：

```
// 默认db存在的路径
#define DB_PATH_ADDR [NSString stringWithFormat:@"%@/Library/testDB.db",NSHomeDirectory()]

```

使用时间，建议要去修改工程的制定db的路径。在 AZDataManager.h 中的 line 12 修改即可。


#####2.2 数据库打开 关闭

```
 [[AZDataManager shareManager] open];
 
 [[AZDataManager shareManager] close];
```

#####2.3 创建表

* model 
 
不指定主键

```
 // 创建表
 [[AZDataManager shareManager] createTableModel:user];
	
```

指定主键( 该主键必须在model的成员变量中 且类型应该为NSNumber 包装后的 NSInteger)


```
 // 创建带有主键的表
 [[AZDataManager shareManager] createTableModel:user primaryKey:@"uid"];
	
```


###### 说明：user 为 AZUser的实例对象，使用model的方式创建表,表名为：tb_ClassName，如果model中含有NSNumber类型的成员变量，则在init之后建议初始化模型。否则 创建出来的NSNumber类型对应的sqllite的字段类型则为text。

* brief_sql

不指定主键

```

 [[AZDataManager shareManager] createTableWithName:tableName Column:@{@"uid":@"integer",@"name":@"text",@"age":@"integer"}];
 
```

指定主键

```
//主键类型的值为：为“integer” 或则 “INTEGER” ，主键为自增

 [[AZDataManager shareManager] createTableWithName:@"user" primaryKey:@"uid" type:@"integer" otherColumn:@{@"name":@"text",@"age":@"integer"}];
    
```


#####2.4 增 

* model
	
单一增加

```
    [[AZDataManager shareManager] insertModel:user];

```

批量增加

```
	 [[AZDataManager shareManager] insertModelsByTransaction:@[zhangsan,lisi,lisi,zhangsan]];
	 
```


* brief_sql

单一增加

```
   [[AZDataManager shareManager] insertRecordWithColumns:@{
                                                          @"name":@"zja",
                                                           @"sex":[NSNumber numberWithBool:YES],
                                                           @"age":[NSNumber numberWithInt:29]
                                                          } toTable:@"tableName"];

```

批量增加

```
	    [[AZDataManager shareManager] insertRecordByTransactionWithColumns:@[
                                                                        @{
                                                                            @"name":@"zja",
                                                                            @"sex":[NSNumber numberWithBool:YES],
                                                                            @"age":[NSNumber numberWithInt:29]
                                                                            },..
                                                                        ] toTable:@"tableName"];

	 
```



#####2.4 删





















