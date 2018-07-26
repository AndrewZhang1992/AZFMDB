//
//  AZDataBaseManager.m
//
//  Created by AndrewZhang on 14-12-29.
//  Copyright (c) 2014年 AndrewZhang. All rights reserved.
//

#import "AZBaseDataManager.h"

@implementation AZBaseDataManager
{
    //数据库
    FMDatabase * _database;
    //数据队列
    FMDatabaseQueue *_databaseQueue;
    //线程锁
    NSLock * _lock;
    
    NSString *_dbPath;
}

- (instancetype)initWithPath:(NSString *)path
{
    if (self = [super init]) {
        _database = [[FMDatabase alloc] initWithPath:path];
        _dbPath = path;
        //打开数据库，如果数据库不存在，创建数据库
        BOOL ret = [_database open];
        if (!ret) {
            perror("1：缓存数据库打开失败  2：或者创建数据库失败");
        }
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (FMDatabaseQueue *)dataBaseQuene {
    if (!_databaseQueue) {
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
    }
    return _databaseQueue;
}

#pragma mark - 单线程 FMDatabase
- (void)createTableWithName:(NSString *)name Column:(NSDictionary *)dict
{
    [_lock lock];
    [_database open];
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
    [_database open];
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
    [_database open];
    NSString * columnNames = [dict.allKeys componentsJoinedByString:@", "];
    
    NSMutableArray * xArray = [NSMutableArray array];
    _Pragma("clang diagnostic push")
    _Pragma("clang diagnostic ignored \"-Wunused-variable\"") // -Wunused-variable  -Warc-performSelector-leaks
    for (NSString * key in dict) {
        [xArray addObject:@"?"];
    }
    _Pragma("clang diagnostic pop")
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
    [_database open];
    [_database beginTransaction];
    BOOL isRollBack = NO;
    @try {
        // 预加载执行
        for (NSDictionary* dict in ary)
        {
            NSString * columnNames = [dict.allKeys componentsJoinedByString:@", "];
            NSMutableArray * xArray = [NSMutableArray array];
            _Pragma("clang diagnostic push")
            _Pragma("clang diagnostic ignored \"-Wunused-variable\"") // -Wunused-variable  -Warc-performSelector-leaks
            for (NSString * key in dict) {
                [xArray addObject:@"?"];
            }
            _Pragma("clang diagnostic pop")
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


- (BOOL)removeRecordWithCondition:(nullable NSString *)condition fromTable:(NSString *)tableName
{
    [_lock lock];
    [_database open];
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
    [_database open];
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
    [_database open];
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


- (FMResultSet *)findColumnNames:(nullable NSArray *)names recordsWithCondition:(nullable NSString *)condition fromTable:(NSString *)tableName
{
    [_lock lock];
    [_database open];
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

- (BOOL)isOpen
{
    return [_database isOpen];
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
    [_database open];
    [_database beginTransaction];

    BOOL isRollBack = NO;
    @try {
        for (NSString *sql in sqlAry) {
            if (sql != nil && ![sql isEqualToString:@""]){
                BOOL ret=[_database executeUpdate:sql];
                if (!ret) {
                    isRollBack = YES;
                    perror("执行 sql 失败");
                }
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
    [_database close];
    return !isRollBack;
}

-(FMResultSet *)executeQuery:(NSString *)sql
{
    [_database open];
    return [_database executeQuery:sql];
}


#pragma mark -  支持多线程 InQueue FMDatabaseQueue

/**
 *  创建表, 支持多线程
 *
 *  @param name 表名
 *  @param dict  NSDictionary
 */
- (void)createTableInQueueWithName:(NSString *)name Column:(NSDictionary *)dict {
    [[self dataBaseQuene] inDatabase:^(FMDatabase * _Nonnull db) {
        //字典中，key是列的名字，值是列的类型，如果有附加参数，直接写到值中
        NSString * sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(", name];
        for (NSString * columnName in dict) {
            sql = [sql stringByAppendingFormat:@"%@ %@, ", columnName, dict[columnName]];
        }
        sql=[sql substringToIndex:sql.length-2];
        sql = [sql stringByAppendingString:@");"];
        BOOL ret = [db executeUpdate:sql];
        if (ret == NO) {
            perror("建表错误");
        }
    }];
}

- (void)createTableInQueueWithName:(NSString *)name primaryKey:(NSString *)key type:(NSString *)type otherColumn:(NSDictionary *)dict {
    [[self dataBaseQuene] inDatabase:^(FMDatabase * _Nonnull db) {
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
        BOOL ret = [db executeUpdate:sql];
        if (ret == NO) {
            perror("建表错误");
        }
    }];
}

- (void)insertRecordInQueueWithColumns:(NSDictionary *)dict toTable:(NSString *)tableName {
    [[self dataBaseQuene] inDatabase:^(FMDatabase * _Nonnull db) {
        NSString * columnNames = [dict.allKeys componentsJoinedByString:@", "];
        NSMutableArray * xArray = [NSMutableArray array];
        _Pragma("clang diagnostic push")
        _Pragma("clang diagnostic ignored \"-Wunused-variable\"") // -Wunused-variable  -Warc-performSelector-leaks
        for (NSString * key in dict) {
            [xArray addObject:@"?"];
        }
        _Pragma("clang diagnostic pop")
        NSString * valueStr = [xArray componentsJoinedByString:@", "];
        
        NSString * sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@);", tableName, columnNames, valueStr];
        //INSERT INTO 女演员(ID, 姓名) VALUES(?, ?)
        BOOL ret = [db executeUpdate:sql withArgumentsInArray:dict.allValues];
        if (ret == NO) {
            perror("插入错误");
        }
    }];
}

- (void)insertRecordInQueueByTransactionWithColumns:(NSArray *)ary toTable:(NSString *)tableName {
    [[self dataBaseQuene] inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        @try {
            // 预加载执行
            for (NSDictionary* dict in ary)
            {
                NSString * columnNames = [dict.allKeys componentsJoinedByString:@", "];
                NSMutableArray * xArray = [NSMutableArray array];
                _Pragma("clang diagnostic push")
                _Pragma("clang diagnostic ignored \"-Wunused-variable\"") // -Wunused-variable  -Warc-performSelector-leaks
                for (NSString * key in dict) {
                    [xArray addObject:@"?"];
                }
                _Pragma("clang diagnostic pop")
                NSString * valueStr = [xArray componentsJoinedByString:@", "];
                NSString * sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@);", tableName, columnNames, valueStr];
                BOOL ret = [db executeUpdate:sql withArgumentsInArray:dict.allValues];
                if (!ret) {
                    NSLog(@"插入数据失败");
                }
            }
        }
        @catch (NSException *exception) {
            *rollback = YES;
            NSLog(@"事务操作失败 原因：%@",exception.reason);
            return ;
        }
        @finally {
            //
        }
    }];
}

- (void)removeRecordInQueueWithCondition:(nullable NSString *)condition fromTable:(NSString *)tableName {
    [[self dataBaseQuene] inDatabase:^(FMDatabase * _Nonnull db) {
        NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
        if (condition!=nil) {
            sql=[sql stringByAppendingFormat:@" %@",condition];
        }
        sql = [sql stringByAppendingString:@";"];
        BOOL ret = [db executeUpdate:sql];
        if (!ret) {
            perror("删除错误");
        }
    }];
}

- (void)updataRecordInQueueWithColumns:(NSDictionary *)dict Condition:(NSString *)condition toTable:(NSString *)tableName {
    [[self dataBaseQuene] inDatabase:^(FMDatabase * _Nonnull db) {
        NSString * sql = [NSString stringWithFormat:@"UPDATE %@ SET  ", tableName];
        NSMutableArray * xArray = [NSMutableArray array];
        for (NSString *key in dict) {
            [xArray addObject:[NSString stringWithFormat:@"%@=?",key]];
        }
        NSString *str=[xArray componentsJoinedByString:@","];
        
        sql=[sql stringByAppendingFormat:@"%@ %@",str,condition];
        sql = [sql stringByAppendingString:@";"];
        
        BOOL ret = [db executeUpdate:sql withArgumentsInArray:dict.allValues];
        if (!ret) {
            perror("更新错误");
        }
    }];
}

- (void)updataRecordInQueueByTransactionWithColumns:(NSArray *)ary Condition:(NSString *)condition toTable:(NSString *)tableName {
    [[self dataBaseQuene] inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
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
                
                BOOL ret = [db executeUpdate:sql withArgumentsInArray:dict.allValues];
                if (!ret) {
                    perror("更新错误");
                }
            }
        }
        @catch (NSException *exception) {
            *rollback = YES;
            NSLog(@"事务操作失败 原因：%@",exception.reason);
            return;
        }
        @finally {
            //
        }
    }];
}

- (void)findInQueueColumnNames:(nullable NSArray *)names recordsWithCondition:(nullable NSString *)condition fromTable:(NSString *)tableName Block:(void (^)(FMResultSet *resultSet))block {
    [[self dataBaseQuene] inDatabase:^(FMDatabase * _Nonnull db) {
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
        FMResultSet * set = [db executeQuery:sql];
        if (block) {
            block(set);
        }
    }];
}

- (void)executeUpdateInQueue:(NSString *)sql {
    [[self dataBaseQuene] inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:sql];
    }];
}

- (void)executeUpdateInQueueByTransaction:(NSArray *)sqlAry FinishBlock:(void (^)(void))finishBlcok {
    [[self dataBaseQuene] inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        @try {
            for (NSString *sql in sqlAry) {
                if (sql != nil && ![sql isEqualToString:@""]){
                    BOOL ret=[db executeUpdate:sql];
                    if (!ret) {
                        *rollback = YES;
                        perror("执行 sql 失败");
                    }
                }
            }
        }
        @catch (NSException *exception) {
            *rollback = YES;
            NSLog(@"事务操作失败 原因：%@",exception.reason);
            return;
        }
        @finally {
            //
            if (finishBlcok && *rollback == NO) {
                finishBlcok();
            }
        }
    }];
}

- (void)executeQueryInQueue:(NSString *)sql Block:(void (^)(FMResultSet *resultSet))block {
    [[self dataBaseQuene] inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if (block) {
            block(resultSet);
        }
    }];
}


@end
