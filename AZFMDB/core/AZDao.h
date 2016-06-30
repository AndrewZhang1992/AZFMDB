//
//  AZDao.h
//
//  Created by Andrew on 16/3/8.
//  Copyright © 2016年 Andrew. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

static NSString const *sql_int=@"integer";
static NSString const *sql_text=@"text";
static NSString const *sql_blob=@"blob";


/**
 *  数据处理层
 */
@interface AZDao : NSObject

/**
 *  获取表名  tb_model
 *
 *  @param model model
 *
 *  @return 表名
 */
+(NSString *)tableNameByModel:(id)model;

+(NSString *)tableNameByClassName:(Class)className;


/**
 *  获取该模型对应的条件
 *
 *  @param model
 *
 *  @return where='xxxx' and where=' sss'
 */
+(NSString *)conditionAllByModel:(id)model;


/**
 *  获取模型的成员变量的类型在sqllite中的类型  并返回键值对（映射）
 * !!! 对像中的成员变量必须是 cocoa 下的类型 不能有基础类型
 *
 *  支持 @"NSNumber",@"NSDictionary",@"NSMutableDictionary",@"NSArray",@"NSMutableArray"
 
 *  @param model model实例
 *
 *  @return NSDictionary
 */
+(NSDictionary *)propertySqlDictionaryFromModel:(id)model;


/**
 *  获取一个对象的 成员变量 键值对 （映射）
 * !!! 对像中的成员变量必须是 cocoa 下的类型 不能有基础类型，基础类型会被过滤掉。（可容 基础类型）
 *
 *  @param model model实例
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)propertyKeyValueFromModel:(id)model;



@end
