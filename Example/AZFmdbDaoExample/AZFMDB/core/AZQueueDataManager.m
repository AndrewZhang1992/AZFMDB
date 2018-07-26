//
//  AZDataManager.m
//
//  Created by Andrew on 16/3/8.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZQueueDataManager.h"
#import "AZBaseDataManager.h"
#import "AZDataMigration.h"

@interface AZQueueDataManager ()


@end

@implementation AZQueueDataManager

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super initWithPath:path]) {
        [self createAppVersionTable];
        [AZDataMigration startSQLWithDataManager:self];
    }
    return self;
}
    
#pragma mark - private
- (void)createAppVersionTable
{
    [self createTableWithName:@"tb_app_version" Column:@{
                                                         @"version":@"text",
                                                         @"time":@"text"
                                                         }];
}

- (NSDictionary *)filterPrimaryKeyDefaultValueWithColumns:(NSDictionary *)colunms InTable:(NSString *)tableName  {
    NSMutableDictionary *tempColums = [NSMutableDictionary dictionaryWithDictionary:colunms];
    NSString *sql_recond = [NSString stringWithFormat:@"PRAGMA table_info('%@')",tableName];
    FMResultSet *sql_recond_resultSet = [self executeQuery:sql_recond];
    NSString *primaryKey = nil;
    while ([sql_recond_resultSet next]) {
        if ([sql_recond_resultSet boolForColumn:@"pk"]) {
            primaryKey = [sql_recond_resultSet stringForColumn:@"name"];
        }
    }
    [sql_recond_resultSet close];
    if(primaryKey && colunms[primaryKey] && [colunms[primaryKey] integerValue]==0) {
        [tempColums removeObjectForKey:primaryKey];
    }
    return [tempColums copy];
}

#pragma mark - public
- (void)createTableModel:(id)model
{
    NSString *tableName=[AZDao tableNameByModel:model];
    [self createTableInQueueWithName:tableName Column:[AZDao propertySqlDictionaryFromModel:model]];
    [AZDataMigration dataMigrationClass:[model class] DataManager:self];
}

- (void)createTableClassName:(Class)className
{
    NSString *tableName=[AZDao tableNameByClassName:className];
    [self createTableInQueueWithName:tableName Column:[AZDao propertySqlDictionaryFromClass:className]];
    [AZDataMigration dataMigrationClass:className DataManager:self];
}

- (void)createTableModel:(id)model primaryKey:(NSString *)key
{
    NSDictionary *sqlDic=[AZDao propertySqlDictionaryFromModel:model];
    if (![sqlDic objectForKey:key]) {
        NSLog(@"model中没有该主键成员变量");
        return;
    }
    if (![[sqlDic objectForKey:key] isEqualToString:sql_int]) {
        NSLog(@"model中指定主键对应sqllite类型应为integer");
        return;
    }
    NSString *tableName=[AZDao tableNameByModel:model];
    [self createTableInQueueWithName:tableName primaryKey:key type:sql_int otherColumn:sqlDic];
    [AZDataMigration dataMigrationClass:[model class] DataManager:self];
}

- (void)createTableClassName:(Class)className primaryKey:(NSString *)key
{
    NSDictionary *sqlDic=[AZDao propertySqlDictionaryFromClass:className];
    if (![sqlDic objectForKey:key]) {
        NSLog(@"model中没有该主键成员变量");
        return;
    }
    if (![[sqlDic objectForKey:key] isEqualToString:sql_int]) {
        NSLog(@"model中指定主键对应sqllite类型应为integer");
        return;
    }
    NSString *tableName=[AZDao tableNameByClassName:className];
    [self createTableInQueueWithName:tableName primaryKey:key type:sql_int otherColumn:sqlDic];
    [AZDataMigration dataMigrationClass:className DataManager:self];
}

- (void)insertModel:(id)model
{
    [self insertModel:model inTable:[AZDao tableNameByModel:model]];
}

- (void)insertModel:(id)model inTable:(NSString *)tableName
{
   [self insertRecordInQueueWithColumns:[self filterPrimaryKeyDefaultValueWithColumns:[AZDao propertyKeyValueFromModel:model] InTable:tableName] toTable:tableName];
}

- (void)insertModelsByTransaction:(NSArray *)ary
{
    [self insertModelsByTransaction:ary inTable:[AZDao tableNameByModel:[ary firstObject]]];
}

- (void)insertModelsByTransaction:(NSArray *)ary inTable:(NSString *)tableName
{
    NSMutableArray *dicArray=[NSMutableArray array];
    for (id model in ary) {
        NSDictionary *dic=[AZDao propertyKeyValueFromModel:model];
        [dicArray addObject:dic];
    }
    [self insertRecordInQueueByTransactionWithColumns:[dicArray copy] toTable:tableName];
}

- (void)removeOneModel:(id)model
{
    return [self removeOneModel:model inTable:[AZDao tableNameByModel:model]];
}

- (void)removeOneModel:(id)model  inTable:(NSString *)tableName
{
    [self removeRecordInQueueWithCondition:[AZDao conditionAllByModel:model] fromTable:tableName];
}

- (void)removeSomeModel:(NSArray *)modelArray FinishBlock:(void (^)(void))finishBlcok {
    return [self removeSomeModel:modelArray inTable:[AZDao tableNameByModel:[modelArray firstObject]] FinishBlock:finishBlcok];
}
    
- (void)removeSomeModel:(NSArray *)modelArray inTable:(NSString *)tableName FinishBlock:(void (^)(void))finishBlcok{
    if (modelArray.count<=0) {
        return;
    }
    NSMutableArray *sqlArray = [NSMutableArray array];
    for (id eleModel in modelArray) {
        NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
        NSString *condition = [AZDao conditionAllByModel:eleModel];
        if (condition!=nil) {
            sql=[sql stringByAppendingFormat:@" %@;",condition];
            [sqlArray addObject:sql];
        }
    }
    [self executeUpdateInQueueByTransaction:sqlArray FinishBlock:finishBlcok];
}

- (void)removeAllModel:(Class)className
{
    [self removeAllModel:className inTable:[AZDao tableNameByClassName:className]];
}

- (void)removeAllModel:(Class)className inTable:(NSString *)tableName
{
    [self removeRecordInQueueWithCondition:nil fromTable:tableName];
}

- (void)updateModel:(id)newModel Condition:(NSString *)condition
{
    [self updateModel:newModel Condition:condition inTable:[AZDao tableNameByModel:newModel]];
}

- (void)updateModel:(id)newModel Condition:(NSString *)condition inTable:(NSString *)tableName
{
    [self updataRecordInQueueWithColumns:[AZDao propertyKeyValueFromModel:newModel] Condition:condition toTable:tableName];
}

- (void)updateOneNewModel:(id)newModel oldModel:(id)oldModel
{
    [self updateOneNewModel:newModel oldModel:oldModel inTable:[AZDao tableNameByModel:oldModel]];
}

- (void)updateOneNewModel:(id)newModel oldModel:(id)oldModel inTable:(NSString *)tableName
{
    if (![newModel isKindOfClass:[oldModel class]]) {
        NSLog(@"两个模型类型 不一致");
        return;
    }
    [self updataRecordInQueueWithColumns:[AZDao propertyKeyValueFromModel:newModel] Condition:[AZDao conditionAllByModel:oldModel] toTable:tableName];
}


-(void)findAllModelWithClass:(Class)className Block:(void (^)(NSArray *resultArray))block
{
    //全部查询
    return [self findModel:className WithCondition:nil Block:block];
}

-(void)findAllModelWithClass:(Class)className inTable:(NSString *)tableName Block:(void (^)(NSArray *resultArray))block
{
    return [self findModel:className WithCondition:nil inTable:tableName Block:block];
}


-(void)findModel:(Class)className WithCondition:(NSString *)condition Block:(void (^)(NSArray *resultArray))block
{
    return [self findModel:className WithCondition:condition inTable:[AZDao tableNameByClassName:className] Block:block];
}

-(void)findModel:(Class)className WithCondition:(NSString *)condition inTable:(NSString *)tableName Block:(void (^)(NSArray *resultArray))block
{
    [self findInQueueColumnNames:nil recordsWithCondition:condition fromTable:tableName Block:^(FMResultSet * _Nonnull resultSet) {
        FMResultSet *rs = resultSet;
        NSMutableArray *array=[NSMutableArray array];
        while (rs.next) {
            id anyObject= [className new];
            NSDictionary *propertyDic = [AZDao propertyListFromClass:className];
            NSArray *propertyList = propertyDic.allKeys;
            NSDictionary *resultDic = rs.resultDictionary;
            for (NSString *key in resultDic) {
                if ([propertyList containsObject:key]) {
                    NSString *typeStr = propertyDic[key];
                    if ([typeStr hasPrefix:@"T@"]) {
                        // cocoa 下的类名
                        NSString *className=[typeStr substringWithRange:NSMakeRange(3, typeStr.length-2-2)];
                        if ([className isEqualToString:@"NSDictionary"] ||
                            [className isEqualToString:@"NSMutableDictionary"] ||
                            [className isEqualToString:@"NSArray"] ||
                            [className isEqualToString:@"NSMutableArray"] ) {
                            NSError *error = nil;
                            NSData *data = [resultDic[key] dataUsingEncoding:NSUTF8StringEncoding];
                            id jsonObjc = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                            if (error) {
                                NSLog(@"[AZDb] error: %@",error);
                            }
                            [anyObject setValue:jsonObjc?:resultDic[key] forKey:key];
                            continue;
                        }
                    }
                    [anyObject setValue:resultDic[key] forKey:key];
                }
            }
            [array addObject:anyObject];
        }
        if (block) {
            block(array);
        }
    }];
}


-(void)findModel:(Class)className ColumnNames:(NSArray *)cloumnNames WithCondition:(NSString *)condition Block:(void (^)(NSArray *resultArray))block;
{
    [self findModel:className ColumnNames:cloumnNames WithCondition:condition inTable:[AZDao tableNameByClassName:className] Block:block];
}

-(void)findModel:(Class)className ColumnNames:(NSArray *)cloumnNames WithCondition:(NSString *)condition inTable:(NSString *)tableName Block:(void (^)(NSArray *resultArray))block;
{
    [self findInQueueColumnNames:cloumnNames recordsWithCondition:condition fromTable:tableName Block:^(FMResultSet * _Nonnull resultSet) {
        FMResultSet *rs=resultSet;
        NSMutableArray *array=[NSMutableArray array];
        while (rs.next) {
            id anyObject= [className new];
            NSDictionary *propertyDic = [AZDao propertyListFromClass:className];
            NSArray *propertyList = propertyDic.allKeys;
            NSDictionary *resultDic = rs.resultDictionary;
            for (NSString *key in resultDic) {
                if ([propertyList containsObject:key]) {
                    NSString *typeStr = propertyDic[key];
                    if ([typeStr hasPrefix:@"T@"]) {
                        // cocoa 下的类名
                        NSString *className=[typeStr substringWithRange:NSMakeRange(3, typeStr.length-2-2)];
                        if ([className isEqualToString:@"NSDictionary"] ||
                            [className isEqualToString:@"NSMutableDictionary"] ||
                            [className isEqualToString:@"NSArray"] ||
                            [className isEqualToString:@"NSMutableArray"] ) {
                            NSError *error = nil;
                            NSData *data = [resultDic[key] dataUsingEncoding:NSUTF8StringEncoding];
                            id jsonObjc = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                            if (error) {
                                NSLog(@"[AZDb] error: %@",error);
                            }
                            [anyObject setValue:jsonObjc?:resultDic[key] forKey:key];
                            continue;
                        }
                    }
                    [anyObject setValue:resultDic[key] forKey:key];
                }
            }
            [array addObject:anyObject];
        }
        if (block) {
            block(array);
        }
    }];
}

@end
