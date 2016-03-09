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


-(BOOL)insertRecordByTransactionWithColumns:(NSArray *)ary toTable:(NSString *)tableName
{
    [_lock lock];

    [_database beginTransaction];
    BOOL isRollBack = NO;
    @try {
        // 预加载执行
        for (NSDictionary* dict in ary)
        {
            NSString * columnNames = [dict.allKeys componentsJoinedByString:@", "];
            NSMutableArray * xArray = [NSMutableArray array];
            for (NSString * key in dict)
            {
                [xArray addObject:@"?"];
            }
            NSString * valueStr = [xArray componentsJoinedByString:@", "];
            NSString * sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@);", tableName, columnNames, valueStr];
            BOOL ret = [_database executeUpdate:sql withArgumentsInArray:dict.allValues];
            if (!ret) {
                NSLog(@"插入数据失败");
            }
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [_database rollback];
        NSLog(@"事务操作失败 原因：%@",exception.reason);
    }
    @finally {
        if (!isRollBack) {
            [_database commit];
        }
    }

    [_lock unlock];

    return !isRollBack;
}


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

-(BOOL)updataRecordByTransactionWithColumns:(NSArray *)ary Condition:(NSString *)condition toTable:(NSString *)tableName
{
    [_lock lock];
    
    [_database beginTransaction];
    BOOL isRollBack = NO;
    @try {
        // 预加载执行
        for (NSDictionary *dict in ary)
        {
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
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [_database rollback];
        NSLog(@"事务操作失败 原因：%@",exception.reason);
    }
    @finally {
        if (!isRollBack) {
            [_database commit];
        }
    }
    
    [_lock unlock];
    
    return !isRollBack;
}


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

-(void)open
{
    BOOL res=[_database open];
    if (!res) {
        perror("数据库打开失败");
    }
}


-(void)close
{
    BOOL res=[_database close];
    if (!res) {
        perror("数据库关闭失败");
    }

}


-(void)executeUpdate:(NSString *)sql
{
    [_database executeUpdate:sql];
}

-(BOOL)executeUpdateByTransaction:(NSArray *)sqlAry
{
    [_lock lock];
    
    [_database beginTransaction];
    BOOL isRollBack = NO;
    @try {
        // 预加载执行
        for (NSString *sql in sqlAry) {
            BOOL ret=[_database executeUpdate:sql];
            if (!ret) {
                perror("执行 sql 失败");
            }
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [_database rollback];
        NSLog(@"事务操作失败 原因：%@",exception.reason);
    }
    @finally {
        if (!isRollBack) {
            [_database commit];
        }
    }
    
    [_lock unlock];
    
    return !isRollBack;
}


-(FMResultSet *)executeQuery:(NSString *)sql
{
    return [_database executeQuery:sql];
}


@end
