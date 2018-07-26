//
//  AZDataManager.h
//  https://github.com/AndrewZhang1992/AZFMDB
//  Created by Andrew on 16/3/8.
//  Copyright © 2016年 Andrew. All rights reserved.
//


#import "AZBaseDataManager.h"
#import "AZDao.h"


@interface AZDataManager : AZBaseDataManager

#pragma mark -.- 对外接口

/**
 *  根据模型 创建表
 *  表名 为 tb_modelname
 *
 *  @param model 实例
 */
- (void)createTableModel:(id)model;

/**
 *  根据类 创建表
 *  表名 为 tb_className
 *  @param className Class
 */
- (void)createTableClassName:(Class)className;


/**
 *   根据模型 创建表
 *   表名 为 tb_modelname
 *
 *  @param model 实例
 *  @param key   指定主键（该主键必须在model的成员变量中,且该类型应该为NSInteger）
 */
- (void)createTableModel:(id)model primaryKey:(NSString *)key;

/**
 *   根据类名 创建表
 *   表名 为 tb_className
 *
 *  @param className 类名
 *  @param key   指定主键（该主键必须在model的成员变量中,且该类型应该为NSInteger）
 */
- (void)createTableClassName:(Class)className primaryKey:(NSString *)key;


/**
 *  增加model
 *
 */
- (BOOL)insertModel:(id)model;


/**
 *  增加model
 *
 *  @param tableName 表名
 *
 */
- (BOOL)insertModel:(id)model inTable:(NSString *)tableName;


/**
 *  批量增加model
 *
 *  @param ary NSArray< model >
 *
 *  @return bool
 */
- (BOOL)insertModelsByTransaction:(NSArray *)ary;



/**
 *  批量增加model
 *
 *  @param ary NSArray< model >
 *
 *  @param tableName 表名
 *
 *  @return bool
 */
- (BOOL)insertModelsByTransaction:(NSArray *)ary inTable:(NSString *)tableName;



/**
 *  删除某一个model
 */
- (BOOL)removeOneModel:(id)model;



/**
 *  删除某一个model
 *
 *  @param tableName 表名
 *
 */
- (BOOL)removeOneModel:(id)model  inTable:(NSString *)tableName;

/**
 批量删除一些model
 
 @param modelArray NSArray
 @return Bool
 */
- (BOOL)removeSomeModel:(NSArray *)modelArray;
    
/**
 批量删除一些model
 
 @param modelArray NSArray
 @return Bool
 */
- (BOOL)removeSomeModel:(NSArray *)modelArray inTable:(NSString *)tableName;

/**
 *  删除表下的所有该model
 *
 *  @param className class
 *
 */
- (BOOL)removeAllModel:(Class)className;

/**
 *  删除表下的所有该model
 *
 *  @param className class
 *  @param tableName 表名
 *
 */
- (BOOL)removeAllModel:(Class)className inTable:(NSString *)tableName;



/**
 *  修改某一个model
 *
 *  @param condition 条件
 *
 */
- (BOOL)updateModel:(id)newModel Condition:(NSString *)condition;


/**
 *  修改某一个model
 *
 *  @param condition 条件
 *  @param tableName 表名
 *
 */
- (BOOL)updateModel:(id)newModel Condition:(NSString *)condition inTable:(NSString *)tableName;



/**
 *  修改某一个model
 *
 */
- (BOOL)updateOneNewModel:(id)newModel oldModel:(id)oldModel;


/**
 *  修改某一个model
 *
 *  @param tableName 表名
 */
- (BOOL)updateOneNewModel:(id)newModel oldModel:(id)oldModel inTable:(NSString *)tableName;



/**
 *  查询 返回所有的model
 *
 *  @param className 类名, 返回的 model 的类
 *
 *  @return NSArray<model>
 */
- (NSArray *)findAllModelWithClass:(Class)className;


/**
 *  查询 返回所有的model
 *
 *  @param className 类名, 返回的 model 的类
 *  @param tableName 表名
 *
 *  @return NSArray<model>
 */
- (NSArray *)findAllModelWithClass:(Class)className inTable:(NSString *)tableName;


/**
 *  根据sql语句查询返回该model
 *
 *  @param className 类名
 *  @param condition 条件查询语句
 *
 *  @return NSArray<model>
 */
- (NSArray *)findModel:(Class)className WithCondition:(NSString *)condition;



/**
 *  根据sql语句查询返回该model
 *
 *  @param className 类名
 *  @param condition 条件查询语句
 *  @param tableName 表名
 *
 *  @return NSArray<model>
 */
- (NSArray *)findModel:(Class)className WithCondition:(NSString *)condition inTable:(NSString *)tableName;

/**
 *  查找model 指定列名
 *
 *  @param className   类名
 *  @param cloumnNames NSArray< cloumnName > 列名数组
 *  @param condition  条件查询语句
 *
 *  @return NSArray<model>
 */
- (NSArray *)findModel:(Class)className ColumnNames:(NSArray *)cloumnNames WithCondition:(NSString *)condition;


/**
 *  查找model 指定列名
 *
 *  @param className   类名
 *  @param cloumnNames NSArray< cloumnName > 列名数组
 *  @param condition  条件查询语句
 *  @param tableName 表名
 *
 *  @return NSArray<model>
 */
- (NSArray *)findModel:(Class)className ColumnNames:(NSArray *)cloumnNames WithCondition:(NSString *)condition inTable:(NSString *)tableName;



@end
