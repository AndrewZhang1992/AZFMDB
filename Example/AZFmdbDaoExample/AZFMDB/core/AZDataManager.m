//
//  AZDataManager.m
//
//  Created by Andrew on 16/3/8.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZDataManager.h"
#import "AZDataBaseManager.h"

@interface AZDataManager ()


@end

@implementation AZDataManager

/**
 *  单例对象
 *
 *  @return 实例
 */
+(instancetype)shareManager
{
    static AZDataManager *db=nil;
    static dispatch_once_t once_DB;
    dispatch_once(&once_DB, ^{
        db=[[AZDataManager alloc] initWithPath:DB_PATH_ADDR];
    });
    return db;
}

/**
 *  根据模型 创建表
 *  表名 为 tb_modelname
 *
 *  @param model
 */
-(void)createTableModel:(id)model
{
    NSString *tableName=[AZDao tableNameByModel:model];
    [self createTableWithName:tableName Column:[AZDao propertySqlDictionaryFromModel:model]];
}

/**
 *   根据模型 创建表
 *   表名 为 tb_modelname
 *
 *  @param model
 *  @param key   指定主键（该主键必须在model的成员变量中）
 */
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
    [self createTableWithName:tableName primaryKey:key type:sql_int otherColumn:[AZDao propertySqlDictionaryFromModel:model]];
}


/**
 *  增加model
 *
 *  @param model
 */
-(BOOL)insertModel:(id)model
{
    BOOL ret= [self insertRecordWithColumns:[AZDao propertyKeyValueFromModel:model] toTable:[AZDao tableNameByModel:model]];
    return ret;
}

/**
 *  批量增加model
 *
 *  @param ary NSArray< model >
 *
 *  @return bool
 */
-(BOOL)insertModelsByTransaction:(NSArray *)ary
{
    NSMutableArray *dicArray=[NSMutableArray array];
    for (id model in ary) {
        NSDictionary *dic=[AZDao propertyKeyValueFromModel:model];
        [dicArray addObject:dic];
    }
    BOOL ret=[self insertRecordByTransactionWithColumns:[dicArray copy] toTable:[AZDao tableNameByModel:[ary firstObject]]];
    return ret;
}

/**
 *  删除某一个model
 *
 *  @param model
 *
 *  @return
 */
-(BOOL)removeOneModel:(id)model
{
    BOOL ret=[self removeRecordWithCondition:[AZDao conditionAllByModel:model] fromTable:[AZDao tableNameByModel:model]];
    return ret;
}

/**
 *  删除表下的所有该model
 *
 *  @param model
 *
 *  @return
 */
-(BOOL)removeAllModel:(Class)className
{
    BOOL ret=[self removeRecordWithCondition:nil fromTable:[AZDao tableNameByClassName:className]];
    return ret;
}

/**
 *  修改model
 *
 *  @param model
 *
 *  @return
 */
-(BOOL)updateOneNewModel:(id)newModel oldModel:(id)oldModel
{
    if (![newModel isKindOfClass:[oldModel class]]) {
        NSLog(@"两个模型类型 不一致");
        return NO;
    }

    BOOL ret=[self updataRecordWithColumns:[AZDao propertyKeyValueFromModel:newModel] Condition:[AZDao conditionAllByModel:oldModel] toTable:[AZDao tableNameByModel:oldModel]];
    return ret;
}

/**
 *  查询 返回所有的model
 *
 *  @param className 类名
 *
 *  @return NSArray<model>
 */
-(NSArray *)findAllModelFromTable:(Class)className
{
    //全部查询
    return [self findModel:className WithCondition:nil];
}


/**
 *  根据sql语句查询返回该model
 *
 *  @param className 类名
 *  @param condition 条件查询语句
 *
 *  @return NSArray<model>
 */
-(NSArray *)findModel:(Class)className WithCondition:(NSString *)condition
{
    FMResultSet *rs=[self findColumnNames:nil recordsWithCondition:condition fromTable:[AZDao tableNameByClassName:className]];
    NSMutableArray *array=[NSMutableArray array];
    while (rs.next) {
        id anyObject= [className new];
        [anyObject setValuesForKeysWithDictionary:rs.resultDictionary];
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
    FMResultSet *rs=[self findColumnNames:cloumnNames recordsWithCondition:condition fromTable:[AZDao tableNameByClassName:className]];
    NSMutableArray *array=[NSMutableArray array];
    while (rs.next) {
        id anyObject= [className new];
        [anyObject setValuesForKeysWithDictionary:rs.resultDictionary];
        [array addObject:anyObject];
    }
    return array;
}

@end
