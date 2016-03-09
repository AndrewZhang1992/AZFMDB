//
//  AZDataBaseManager.m
//
//  Created by AndrewZhang on 14-12-29.
//  Copyright (c) 2014年 AndrewZhang. All rights reserved.
//

#import "AZDataBaseManager.h"

@implementation AZDataBaseManager
{
    //数据库
    FMDatabase * _database;
    //线程锁
    NSLock * _lock;
}

- (instancetype)initWithPath:(NSString *)path
{
    if (self = [super init]) {
        _database = [[FMDatabase alloc] initWithPath:path];
        //打开数据库，如果数据库不存在，创建数据库
        BOOL ret = [_database open];
        if (!ret) {
            perror("1：缓存数据库打开失败  2：或者创建数据库失败");
        }else
        {
            [_database close];
        }
        _lock = [[NSLock alloc] init];
        
    }
    return self;
}

/**
 *  创建表
 *
 *  @param name 表名
 *  @param dict  NSDictionary
 */
- (void)createTableWithName:(NSString *)name Column:(NSDictionary *)dict
{
    [_lock lock];
    //字典中，key是列的名字，值是列的类型，如果有附加参数，直接写到值中
    NSString * sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(", name];
    for (NSString * columnName in dict) {
       sql = [sql stringByAppendingFormat:@"%@ %@, ", columnName, dict[columnName]];
    }
    sql=[sql substringToIndex:sql.length-2];
    sql = [sql stringByAppendingString:@");"];
    BOOL ret = [_database executeUpdate:sql];
    if (ret == NO) {
        perror("建表错误");
    }
    [_lock unlock];
}

/**建表*/
- (void)createTableWithName:(NSString *)name primaryKey:(NSString *)key type:(NSString *)type otherColumn:(NSDictionary *)dict
{
    [_lock lock];
    //字典中，key是列的名字，值是列的类型，如果有附加参数，直接写到值中
    NSString * sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@ %@ PRIMARY KEY", name, key, type];
    if ([type isEqualToString:@"integer"] || [type isEqualToString:@"INTEGER"])
    {
        sql=[sql stringByAppendingString:@" autoincrement"];
    }
    for (NSString * columnName in dict) {
        if (![columnName isEqualToString:key]) {
            sql = [sql stringByAppendingFormat:@", %@ %@", columnName, dict[columnName]];
        }
    }
    sql = [sql stringByAppendingString:@");"];
    
    BOOL ret = [_database executeUpdate:sql];
    if (ret == NO) {
        perror("建表错误");
    }
   
    [_lock unlock];
}

/**插入记录*/
- (BOOL)insertRecordWithColumns:(NSDictionary *)dict toTable:(NSString *)tableName
{
    [_lock lock];
    
    NSString * columnNames = [dict.allKeys componentsJoinedByString:@", "];
    
    NSMutableArray * xArray = [NSMutableArray array];
    for (NSString * key in dict)
    {
        [xArray addObject:@"?"];
    }
    
    NSString * valueStr = [xArray componentsJoinedByString:@", "];
    
    NSString * sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@);", tableName, columnNames, valueStr];
    //INSERT INTO 女演员(ID, 姓名) VALUES(?, ?)
    
    BOOL ret = [_database executeUpdate:sql withArgumentsInArray:dict.allValues];
    if (ret == NO) {
        perror("插入错误");
    }
    [_lock unlock];
    return ret;
}


/**删除记录*/
- (BOOL)removeRecordWithCondition:(NSString *)condition fromTable:(NSString *)tableName
{
    [_lock lock];
   
    NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    
    if (condition!=nil) {
        sql=[sql stringByAppendingFormat:@" %@",condition];
    }

    sql = [sql stringByAppendingString:@";"];
    
    BOOL ret = [_database executeUpdate:sql];
    if (!ret) {
        perror("删除错误");
    }
   
    [_lock unlock];
    return ret;
}

/** 更新记录，第一个参数：字典，键表示需要更新的类名，值为相应列的值；第二个参数：条件，必须指明条件才能更新；第三个参数：表名*/
-(BOOL)updataRecordWithColumns:(NSDictionary *)dict Condition:(NSString *)condition toTable:(NSString *)tableName
{
    [_lock lock];
    
    NSString * sql = [NSString stringWithFormat:@"UPDATE %@ SET  ", tableName];
    NSMutableArray * xArray = [NSMutableArray array];
    for (NSString *key in dict) {
        [xArray addObject:[NSString stringWithFormat:@"%@=?",key]];
    }
    NSString *str=[xArray componentsJoinedByString:@","];
    
    sql=[sql stringByAppendingFormat:@"%@ %@",str,condition];
    sql = [sql stringByAppendingString:@";"];
    
    BOOL ret = [_database executeUpdate:sql withArgumentsInArray:dict.allValues];
    if (!ret) {
        perror("更新错误");
    }
    [_lock unlock];

    return ret;
}
/**查找记录*/
- (FMResultSet *)findColumnNames:(NSArray *)names recordsWithCondition:(NSString *)condition fromTable:(NSString *)tableName
{
    [_lock lock];
   
    NSString * colNames = nil;
    if (names == nil) {
        colNames = @"*";
    } else {
        colNames = [names componentsJoinedByString:@", "];
    }
    NSString * sql = [NSString stringWithFormat:@"SELECT %@ FROM %@", colNames, tableName];

    if (condition!=nil) {
        sql=[sql stringByAppendingFormat:@" %@",condition];
    }
    
    sql = [sql stringByAppendingString:@";"];
    
    FMResultSet * set = [_database executeQuery:sql];
    [_lock unlock];
    
    return set;
}
/**打开数据库*/
-(void)open
{
    BOOL res=[_database open];
    if (!res) {
        NSLog(@"数据库打开失败");
    }
}

-(void)close
{
    BOOL res=[_database close];
    if (!res) {
        NSLog(@"数据库关闭失败");
    }

}


/**执行  SQL 语句 不带返回结果的*/
-(void)executeUpdate:(NSString *)sql
{
    [_database executeUpdate:sql];
}


/** 执行 SQL 语句 带返回结果的 */
-(FMResultSet *)executeQuery:(NSString *)sql
{
    return [_database executeQuery:sql];
}
@end
