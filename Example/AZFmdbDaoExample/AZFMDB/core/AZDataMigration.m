//
//  AZDataMigration.m
//  AZFmdbDaoExample
//
//  Created by Andrew on 16/8/15.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZDataMigration.h"
#import "AZDao.h"
#import "AZDataManager.h"

@implementation AZDataMigration

+(void)startSQL
{
    // 创建版本号 默认为当前版本
    if (![AZDataMigration CheckVersion]) {
        
        // 搜寻 sql
        NSArray *sqlArray = [AZDataMigration SearchBundleSQL];
        if (sqlArray.count>0) {
            [[AZDataManager shareManager] open];
           BOOL flag = [[AZDataManager shareManager] executeUpdateByTransaction:sqlArray];
            [[AZDataManager shareManager] close];
            if (!flag) {
                NSLog(@"执行sql数据迁移失败");
            }else{
                NSLog(@"执行sql数据迁移成功");
            }
        }
        
        [AZDataMigration WirteCurrentVersionToDB];
    }
}

+(NSArray *)SearchBundleSQL
{
    NSMutableArray* sqlArray = [NSMutableArray array];
    NSMutableArray *fileArray = [NSMutableArray array];
    NSArray *sqlPaths=[[NSBundle mainBundle] pathsForResourcesOfType:@"sql" inDirectory:@""];
    
    for (NSString *sqlPath in sqlPaths)
    {
        NSInteger sqlVersion=[AZDataMigration getIntegerFromString:[[sqlPath componentsSeparatedByString:@"/"] lastObject]];
        NSInteger benginVersionInteger=[AZDataMigration getIntegerFromString:[AZDataMigration getMaxVersionFromDB]];
        NSString *current_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        if (benginVersionInteger<sqlVersion && sqlVersion<=[AZDataMigration getIntegerFromString:current_version])
        {
            //  执行大于旧版本号 小于等于新版本号之间的 sql
            [fileArray addObject:sqlPath];
        }
    }
    
    [fileArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSLog(@"版本升级，需要执行的sql 语句：%@",fileArray);
    
    for(NSInteger i = 0; i < [fileArray count]; i++)
    {
        NSArray* tmpArray = [AZDataMigration readSQLByFile:fileArray[i]];
        [sqlArray addObjectsFromArray:tmpArray];
    }
    
    return sqlArray;
}

+ (NSArray *)readSQLByFile:(NSString *)path
{
    NSCharacterSet* seperateLineSet = [NSCharacterSet newlineCharacterSet];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:
                         nil];
    NSArray* sqlArray = [content componentsSeparatedByCharactersInSet:seperateLineSet];
    return sqlArray;
}

+(void)WirteCurrentVersionToDB
{
    NSString *current_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    [[AZDataManager shareManager] open];
    [[AZDataManager shareManager] insertRecordWithColumns:@{
                                                            @"version":current_version,
                                                            @"time":[NSString stringWithFormat:@"%f",time]
                                                            } toTable:@"tb_app_version"];
    [[AZDataManager shareManager] close];
}

/**
 *  检测当前版本和 db 中最大的版本号 是否一致
 *
 *  @return
 */
+(BOOL)CheckVersion
{
    BOOL flag = NO;
    NSString *max_version = [AZDataMigration getMaxVersionFromDB];
    NSString *current_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if ([AZDataMigration getIntegerFromString:max_version]>=[AZDataMigration getIntegerFromString:current_version]) {
        flag=YES;
    }
    return flag;
}


+(NSString *)getMaxVersionFromDB
{
    NSString *maxVersion=@"0";
    [[AZDataManager shareManager] open];
    
    FMResultSet *rs = [[AZDataManager shareManager] executeQuery:@"SELECT time,max(version) as version FROM tb_app_version"];
    if ([rs next]) {
        NSString *version = [rs stringForColumn:@"version"];
        maxVersion = version?:@"0";
    }
    [rs close];
    [[AZDataManager shareManager] close];
    return maxVersion;
}


+ (NSInteger)getIntegerFromString:(NSString *)str
{
    NSString *originalString = str?:@"0";
    // Intermediate
    NSMutableString *numberString = [[NSMutableString alloc] init];
    NSString *tempStr;
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while (![scanner isAtEnd]) {
        // Throw away characters before the first number.
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
        
        // Collect numbers.
        [scanner scanCharactersFromSet:numbers intoString:&tempStr];
        if (tempStr != nil) {
            [numberString appendString:tempStr];
        }
        
        tempStr = @"";
    }
    // Result.
    NSInteger number = [numberString integerValue];

    return number;
}


+(void)dataMigrationClass:(Class)className
{
    [AZDataMigration dataMigrationClass:className TableName:[AZDao tableNameByClassName:className]];
}

+(void)dataMigrationClass:(Class)className TableName:(NSString *)tableName
{
    [AZDataMigration dataMigrationClass:className TableName:tableName IgnoreRecondNames:nil];
}


+(void)dataMigrationClass:(Class)className TableName:(NSString *)tableName IgnoreRecondNames:(nullable NSArray *)ignoreRecondNames
{
    NSArray *propertyList = [AZDao propertyListFromClass:className];
    
    if (ignoreRecondNames.count>0) {
        NSMutableArray *tempPropertyList = [propertyList mutableCopy];
        [tempPropertyList removeObjectsInArray:ignoreRecondNames];
        propertyList = [tempPropertyList copy];
    }
    
    NSMutableArray *alertSqlArray = [NSMutableArray array];
    [[AZDataManager shareManager] open];
    NSString *sql = [NSString stringWithFormat:@"select sql from sqlite_master where tbl_name = '%@' and type='table' ",tableName];
    FMResultSet *resultSet = [[AZDataManager shareManager] executeQuery:sql];
    bool flag = [resultSet next];
    // NSString *db_sql  =  [resultSet stringForColumnIndex:0]; // 表结构
    [resultSet close];
    if (flag) {
        // 存在数据表
        
        // 获取表所有字段
        NSString *sql_recond = [NSString stringWithFormat:@"PRAGMA table_info('%@')",tableName];
        FMResultSet *sql_recond_resultSet = [[AZDataManager shareManager] executeQuery:sql_recond];
        NSMutableArray *db_reconds = [NSMutableArray array];
        while ([sql_recond_resultSet next]) {
            NSString *recond_name = [sql_recond_resultSet stringForColumn:@"name"];
            [db_reconds addObject:recond_name];
        }
        [sql_recond_resultSet close];

        for (NSString *recondName in propertyList)
        {
            if (![db_reconds containsObject:recondName]) {
                // 不存在该字段
                NSString *alertAddSql = [NSString stringWithFormat:@"alter table %@ add %@ %@",tableName,recondName,[AZDao sqlLiteTypeFromAttributeName:recondName]];
                [alertSqlArray addObject:alertAddSql];
            }
        }
    }
    
    // 执行 alert add sql
    if (alertSqlArray.count>0) {
        [[AZDataManager shareManager] executeUpdateByTransaction:alertSqlArray];
    }
    
    [[AZDataManager shareManager] close];
}


@end
