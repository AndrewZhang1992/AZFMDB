//
//  AZDataManager.h
//  AZFmdbDaoExample
//
//  Created by Andrew on 16/3/8.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZDataBaseManager.h"
#import "AZDao.h"

#define DB_PATH_ADDR [NSString stringWithFormat:@"%@/Library/testDB.db",NSHomeDirectory()]

@interface AZDataManager : AZDataBaseManager

/**
 *  单例对象
 *
 *  @return 实例
 */
+(instancetype)shareManager;

#pragma mark -.- 对外接口

/**
 *  根据模型 创建表
 *  表名 为 tb_modelname
 *
 *  @param model
 */
-(void)createTableModel:(id)model;

/**
 *   根据模型 创建表
 *   表名 为 tb_modelname
 *
 *  @param model
 *  @param key   指定主键（该主键必须在model的成员变量中,且该类型应该为NSInteger）
 */
-(void)createTableModel:(id)model primaryKey:(NSString *)key;

/**
 *  增加model
 *
 *  @param model
 */
-(BOOL)insertModel:(id)model;

/**
 *  删除某一个model
 *
 *  @param model
 *
 *  @return
 */
-(BOOL)deleteOneModel:(id)model;


/**
 *  删除表下的所有该model
 *
 *  @param model
 *
 *  @return
 */
-(BOOL)deleteAllModel:(id)model;

/**
 *  修改某一个model
 *
 *  @param model
 *
 *  @return
 */
-(BOOL)updateOneNewModel:(id)newModel oldModel:(id)oldModel;


/**
 *  查询 返回所有的model
 *
 *  @param className 类名
 *
 *  @return NSArray<model>
 */
-(NSArray *)selectAllModelFromTable:(Class)className;


/**
 *  根据sql语句查询返回该model
 *
 *  @param className 类名
 *  @param condition 条件查询语句
 *
 *  @return NSArray<model>
 */
-(NSArray *)selectModel:(Class)className WithCondition:(NSString *)condition;



@end
