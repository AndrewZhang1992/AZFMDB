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
    NSArray *propertyList = [AZDao propertyListFromClass:className];
    NSMutableArray *alertSqlArray = [NSMutableArray array];
    [[AZDataManager shareManager] open];
    NSString *sql = [NSString stringWithFormat:@"select sql from sqlite_master where tbl_name = '%@' and type='table' ",tableName];
    FMResultSet *resultSet = [[AZDataManager shareManager] executeQuery:sql];
    if ([resultSet next]) {
        for (NSString *recondName in propertyList)
        {
            NSString *db_sql = [resultSet stringForColumnIndex:0];
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
