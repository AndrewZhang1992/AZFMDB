//
//  AZDataBaseManager.h
//
//  Created by AndrewZhang on 14-12-29.
//  Copyright (c) 2014年 AndrewZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@class FMResultSet;

NS_ASSUME_NONNULL_BEGIN

@interface AZBaseDataManager : NSObject


/**
 *  初始化
 *
 *  @param path 指定db路径,如果不存在 则会创建该db。
 *
 *  @return 实例
 */
- (instancetype)initWithPath:(NSString *)path;

/**
 *  创建表
 *
 *  @param name 表名
 *  @param dict  NSDictionary
 */
- (void)createTableWithName:(NSString *)name Column:(NSDictionary *)dict;

/**
 *  建表
 *
 *  @param name 表名
 *  @param key  主键名
 *  @param type 主键类型
 *  @param dict NSDictionary
 */
- (void)createTableWithName:(NSString *)name primaryKey:(NSString *)key type:(NSString *)type otherColumn:(NSDictionary *)dict;

/**
 *  插入记录
 *
 *  @param dict      字典的键是列的名称,值是对应列的值
 *  @param tableName 表名
 */
- (BOOL)insertRecordWithColumns:(NSDictionary *)dict toTable:(NSString *)tableName;



/**
 *  事务操作批量插入记录
 *
 *  @param ary      NSArray< NSDictionary > 内部存放的一条记录的键值对
 *  @param tableName 表名
 *
 *  @return bool
 */
-(BOOL)insertRecordByTransactionWithColumns:(NSArray *)ary toTable:(NSString *)tableName;


/**
 *  删除记录
 *
 *  @param condition 删除条件，没有则输入nil
 *  @param tableName 表名
 */
- (BOOL)removeRecordWithCondition:(nullable NSString *)condition fromTable:(NSString *)tableName;


/**
 *  更新记录
 *
 *  @param dict      字典，键表示需要更新的类名，值为相应列的值
 *  @param condition 条件，必须指明条件才能更新
 *  @param tableName 表名
 */
-(BOOL)updataRecordWithColumns:(NSDictionary *)dict Condition:(NSString *)condition toTable:(NSString *)tableName;


/**
 *  事务操作 更新记录
 *
 *  @param ary      NSArray< NSDictionary >    字典，键表示需要更新的类名，值为相应列的值
 *  @param condition 条件，必须指明条件才能更新
 *  @param tableName 表名
 *
 *  @return bool
 */
-(BOOL)updataRecordByTransactionWithColumns:(NSArray *)ary Condition:(NSString *)condition toTable:(NSString *)tableName;


/**
 *  查找记录
 *
 *  @param names     表示列名， names为nil时，搜索所有的列
 *  @param condition 表示条件，不使用条件查询输入nil
 *  @param tableName 表名
 *
 *  @return 结果集
 */
- (FMResultSet *)findColumnNames:(nullable NSArray *)names recordsWithCondition:(nullable NSString *)condition fromTable:(NSString *)tableName;



/**
 *  执行  SQL 语句 不带返回结果的
 *
 *  @param sql sql
 */
-(void)executeUpdate:(NSString *)sql;


/**
 *   事务操作 SQL 语句
 *
 *  @param sqlAry NSArray< sql >
 */
-(BOOL)executeUpdateByTransaction:(NSArray *)sqlAry;


/**
 *  执行 SQL 语句 带返回结果的
 *
 *  @param sql sql
 *
 *  @return FMResultSet 结果集
 */
-(FMResultSet *)executeQuery:(NSString *)sql;


/**
 *  打开数据库
 */
-(void)open;


/**
 *  关闭数据库
 */
-(void)close;


@end

NS_ASSUME_NONNULL_END
