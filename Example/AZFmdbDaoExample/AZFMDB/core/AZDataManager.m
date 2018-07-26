//
//  AZDataManager.m
//
//  Created by Andrew on 16/3/8.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZDataManager.h"
#import "AZBaseDataManager.h"
#import "AZDataMigration.h"

@interface AZDataManager ()


@end

@implementation AZDataManager

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super initWithPath:path]) {
        [self createAppVersionTable];
        [AZDataMigration startSQLWithDataManager:self];
    }
    return self;
}
    
#pragma mark - private
-(void)createAppVersionTable
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
-(void)createTableModel:(id)model
{
    NSString *tableName=[AZDao tableNameByModel:model];
    [self createTableWithName:tableName Column:[AZDao propertySqlDictionaryFromModel:model]];
    [AZDataMigration dataMigrationClass:[model class] DataManager:self];
}

-(void)createTableClassName:(Class)className
{
    NSString *tableName=[AZDao tableNameByClassName:className];
    [self createTableWithName:tableName Column:[AZDao propertySqlDictionaryFromClass:className]];
    [AZDataMigration dataMigrationClass:className DataManager:self];
}

-(void)createTableModel:(id)model primaryKey:(NSString *)key
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
    [self createTableWithName:tableName primaryKey:key type:sql_int otherColumn:sqlDic];
    [AZDataMigration dataMigrationClass:[model class] DataManager:self];
}

-(void)createTableClassName:(Class)className primaryKey:(NSString *)key
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
    [self createTableWithName:tableName primaryKey:key type:sql_int otherColumn:sqlDic];
    [AZDataMigration dataMigrationClass:className DataManager:self];
}

-(BOOL)insertModel:(id)model
{
    return [self insertModel:model inTable:[AZDao tableNameByModel:model]];
}

-(BOOL)insertModel:(id)model inTable:(NSString *)tableName
{
    BOOL ret= [self insertRecordWithColumns:[self filterPrimaryKeyDefaultValueWithColumns:[AZDao propertyKeyValueFromModel:model] InTable:tableName] toTable:tableName];
    return ret;
}

-(BOOL)insertModelsByTransaction:(NSArray *)ary
{
   return  [self insertModelsByTransaction:ary inTable:[AZDao tableNameByModel:[ary firstObject]]];
}

-(BOOL)insertModelsByTransaction:(NSArray *)ary inTable:(NSString *)tableName
{
    NSMutableArray *dicArray=[NSMutableArray array];
    for (id model in ary) {
        NSDictionary *dic=[AZDao propertyKeyValueFromModel:model];
        [dicArray addObject:dic];
    }
    BOOL ret=[self insertRecordByTransactionWithColumns:[dicArray copy] toTable:tableName];
    return ret;
}

-(BOOL)removeOneModel:(id)model
{
    return [self removeOneModel:model inTable:[AZDao tableNameByModel:model]];
}

-(BOOL)removeOneModel:(id)model  inTable:(NSString *)tableName
{
    BOOL ret = [self removeRecordWithCondition:[AZDao conditionAllByModel:model] fromTable:tableName];
    return ret;
}

- (BOOL)removeSomeModel:(NSArray *)modelArray {
    return [self removeSomeModel:modelArray inTable:[AZDao tableNameByModel:[modelArray firstObject]]];
}
    
- (BOOL)removeSomeModel:(NSArray *)modelArray inTable:(NSString *)tableName {
    if (modelArray.count<=0) {
        return NO;
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
    BOOL ret = NO;
    if (sqlArray.count>0) {
        ret = [self executeUpdateByTransaction:sqlArray];
    }
    return ret;
}

-(BOOL)removeAllModel:(Class)className
{
    return [self removeAllModel:className inTable:[AZDao tableNameByClassName:className]];
}

-(BOOL)removeAllModel:(Class)className inTable:(NSString *)tableName
{
    BOOL ret=[self removeRecordWithCondition:nil fromTable:tableName];
    return ret;
}

-(BOOL)updateModel:(id)newModel Condition:(NSString *)condition
{
    return [self updateModel:newModel Condition:condition inTable:[AZDao tableNameByModel:newModel]];
}


-(BOOL)updateModel:(id)newModel Condition:(NSString *)condition inTable:(NSString *)tableName
{
    BOOL ret=[self updataRecordWithColumns:[AZDao propertyKeyValueFromModel:newModel] Condition:condition toTable:tableName];
    return ret;
}



-(BOOL)updateOneNewModel:(id)newModel oldModel:(id)oldModel
{
    return [self updateOneNewModel:newModel oldModel:oldModel inTable:[AZDao tableNameByModel:oldModel]];
}

-(BOOL)updateOneNewModel:(id)newModel oldModel:(id)oldModel inTable:(NSString *)tableName
{
    if (![newModel isKindOfClass:[oldModel class]]) {
        NSLog(@"两个模型类型 不一致");
        return NO;
    }
    
    BOOL ret=[self updataRecordWithColumns:[AZDao propertyKeyValueFromModel:newModel] Condition:[AZDao conditionAllByModel:oldModel] toTable:tableName];
    return ret;
}


-(NSArray *)findAllModelWithClass:(Class)className
{
    //全部查询
    return [self findModel:className WithCondition:nil];
}

-(NSArray *)findAllModelWithClass:(Class)className inTable:(NSString *)tableName
{
    return [self findModel:className WithCondition:nil inTable:tableName];
}


-(NSArray *)findModel:(Class)className WithCondition:(NSString *)condition
{
    return [self findModel:className WithCondition:condition inTable:[AZDao tableNameByClassName:className]];
}

-(NSArray *)findModel:(Class)className WithCondition:(NSString *)condition inTable:(NSString *)tableName
{
    FMResultSet *rs=[self findColumnNames:nil recordsWithCondition:condition fromTable:tableName];
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
    return array;
}

/**
 *  查找model 指定列名
 *
 *  @param className   类名
 *  @param cloumnNames NSArray< cloumnName > 列名数组
 *  @param condition  条件查询语句
 *
 *  @return NSArray<model>
 */
-(NSArray *)findModel:(Class)className ColumnNames:(NSArray *)cloumnNames WithCondition:(NSString *)condition
{
    return [self findModel:className ColumnNames:cloumnNames WithCondition:condition inTable:[AZDao tableNameByClassName:className]];
}

-(NSArray *)findModel:(Class)className ColumnNames:(NSArray *)cloumnNames WithCondition:(NSString *)condition inTable:(NSString *)tableName
{
    FMResultSet *rs=[self findColumnNames:cloumnNames recordsWithCondition:condition fromTable:tableName];
    NSMutableArray *array=[NSMutableArray array];
    while (rs.next) {
        id anyObject= [className new];
        [anyObject setValuesForKeysWithDictionary:rs.resultDictionary];
        [array addObject:anyObject];
    }
    return array;
}

@end
