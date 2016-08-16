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
    NSString *db_sql  =  [resultSet stringForColumnIndex:0];
    [resultSet close];
    if (flag) {
        for (NSString *recondName in propertyList)
        {
            if (![db_sql containsString:recondName]) {
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
