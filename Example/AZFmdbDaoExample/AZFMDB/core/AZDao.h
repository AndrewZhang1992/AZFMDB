//
//  AZDao.h
//
//  Created by Andrew on 16/3/8.
//  Copyright © 2016年 Andrew. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

extern NSString * const sql_int;
extern NSString * const sql_text;
extern NSString * const sql_blob;

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
+ (NSString *)tableNameByModel:(id)model;

+ (NSString *)tableNameByClassName:(Class)className;


/**
 *  获取该模型对应的条件
 *
 *  @param model
 *
 *  @return where='xxxx' and where=' sss'
 */
+ (NSString *)conditionAllByModel:(id)model;


/**
 *  获取模型的成员变量的类型在sqllite中的类型  并返回键值对（映射）
 *
 *  支持 bool, int, float, NSInteger, NSUInteger, CGFloat, NSTimeInterval,  @"NSNumber",@"NSDictionary",@"NSMutableDictionary",@"NSArray",@"NSMutableArray"
 *
 *  @param model model实例
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)propertySqlDictionaryFromModel:(id)model;


/**
 *  获取模型的成员变量的类型在sqllite中的类型  并返回键值对（映射）
 *
 *  支持 bool, int, float, NSInteger, NSUInteger, CGFloat, NSTimeInterval,  @"NSNumber",@"NSDictionary",@"NSMutableDictionary",@"NSArray",@"NSMutableArray"
 *
 *  @param className Class
 *
 *  @return NSDictionary
 */
+(NSDictionary *)propertySqlDictionaryFromClass:(Class)className;


/**
 *  获取一个对象的 成员变量 键值对 （映射）
 *
 *  @param model model实例
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)propertyKeyValueFromModel:(id)model;



    
/**
 *  获取 一个类的 属性列表
 *
 *  @param className 类名
 *
 *  @return  NSDictionary @{属性名称:属性类型}
 *  eg. {@"cid":@"Ti",@"name":@"T@\NSString\",@"ary":@"T@\NSArray\"}
 */
+ (NSDictionary *)propertyListFromClass:(Class)className;


/**
 *  获取对应的 sql 字段类型
 *
 *  @param attributeName 属性propertyAttibute
 *
 *  @return
 */
+(NSString const*)sqlLiteTypeFromAttributeName:(NSString *)attributeName;

@end
