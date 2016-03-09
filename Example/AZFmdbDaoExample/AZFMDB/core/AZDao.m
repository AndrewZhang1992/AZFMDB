//
//  AZDao.m
//
//  Created by Andrew on 16/3/8.
//  Copyright © 2016年 Andrew. All rights reserved.
//


#import "AZDao.h"

@implementation AZDao

/**
 *  获取表名  tb_model
 *
 *  @param model model
 *
 *  @return 表名
 */
+(NSString *)tableNameByModel:(id)model
{
    const char *charClassName= class_getName([model class]);
    NSString *className=[NSString stringWithCString:charClassName encoding:NSUTF8StringEncoding];
    NSString *tableName=[NSString stringWithFormat:@"tb_%@",className];
    return tableName;
}

+(NSString *)tableNameByClassName:(Class)className
{
    const char *charClassName= class_getName(className);
    NSString *xclassName=[NSString stringWithCString:charClassName encoding:NSUTF8StringEncoding];
    NSString *tableName=[NSString stringWithFormat:@"tb_%@",xclassName];
    return tableName;
}

/**
 *  获取该模型对应的条件
 *
 *  @param model
 *
 *  @return where age='xxxx' and name='sss'
 */
+(NSString *)conditionAllByModel:(id)model
{
    if (model)
    {
        NSString *condition=@"where ";
        NSDictionary *dic=[AZDao propertyKeyValueFromModel:model];
        for (NSString *key in dic) {
            NSString *str=[NSString stringWithFormat:@"%@='%@' and ",key,[dic objectForKey:key]];
            condition=[condition stringByAppendingString:str];
        }
        condition = [condition substringToIndex:condition.length-5];
        return condition;
    }
    return nil;
}


+(NSString const*)sqlLiteTypeFrom:(const char *)strChar andModel:(id)model
{
    NSString *attributeName=[NSString stringWithCString:strChar encoding:NSUTF8StringEncoding];
    NSArray *attrAry=[attributeName componentsSeparatedByString:@","];
    NSString *firstStr=[attrAry firstObject];
    NSArray *intAry=@[@"c",@"i",@"C",@"I"];
    NSArray *textAry=@[@"f",@"F",@"NSNumber",@"NSDictionary",@"NSMutableDictionary",@"NSArray",@"NSMutableArray",@"NSString"];
    NSArray *blobAry=@[@"UIImage"];
    
    if ([firstStr hasPrefix:@"T@"]) {
        // cocoa 下的类名
        NSString *className=[firstStr substringWithRange:NSMakeRange(3, firstStr.length-2-2)];
        if ([textAry containsObject:className]) {
            
            // NSNumber
            if ([className isEqualToString:@"NSNumber"]) {
                NSString *lastStr=[[[attrAry lastObject] componentsSeparatedByString:@"V_"] lastObject];
                NSNumber *number=[model performSelector:NSSelectorFromString(lastStr)]?:[NSNumber numberWithFloat:0.0];
                if ([intAry containsObject:[NSString stringWithCString:[number objCType] encoding:NSUTF8StringEncoding]]) {
                    return sql_int;
                }
            }
            return sql_text;
        }
        if ([blobAry containsObject:className]) {
            return sql_blob;
        }
        
    }else{
        // 基础类型
        // bool--Tc NSInteger--Ti CGFloat--Tf
        if ([intAry containsObject:[firstStr substringFromIndex:1]]) {
            return sql_int;
        }
        if ([textAry containsObject:[firstStr substringFromIndex:1]]){
            return sql_text;
        }
    }
    
    return nil;
}


/**
 *  获取模型的成员变量的类型在sqllite中的类型  并返回键值对（映射）
 *
 *  @param model model实例
 *  实例中含有NSNumber 但是未附初始值，将默认返回 text 类型，建议模型初始化必须有初始值
 *
 *  @return NSDictionary
 */
+(NSDictionary *)propertySqlDictionaryFromModel:(id)model
{
    Class class=[model class];
    u_int count;
    
    // 获取所有成员变量
    objc_property_t *propertyList=class_copyPropertyList(class, &count);
    NSMutableArray *keyArray=[NSMutableArray arrayWithCapacity:count];
    NSMutableArray *valueArray=[NSMutableArray arrayWithCapacity:count];
    
    for (int i=0; i<count; i++) {
        const char * property=property_getName(propertyList[i]);
        const char * propertyAttibute=property_getAttributes(propertyList[i]);
        
        NSString *propertyName=[NSString stringWithCString:property encoding:NSUTF8StringEncoding];
        [keyArray addObject:propertyName];
        [valueArray addObject:[AZDao sqlLiteTypeFrom:propertyAttibute andModel:model]?:sql_text];
    }
    free(propertyList);
    return [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
}


/**
 *  获取一个对象的 成员变量 键值对 （映射）
 * !!! 对像中的成员变量必须是 cocoa 下的类型 不能有基础类型
 *
 *  @param model model实例
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)propertyKeyValueFromModel:(id)model
{
    Class clazz = [model class];
    u_int count;
    
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++)
    {
        
        objc_property_t prop=properties[i];
        const char *propertyName = property_getName(prop);
        [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        
//        id value= objc_msgSend(model,NSSelectorFromString([NSString stringWithUTF8String:propertyName]));
        id value= [model performSelector:NSSelectorFromString([NSString stringWithUTF8String:propertyName])];
        if(value ==nil)
            [valueArray addObject:@""];
        else {
            [valueArray addObject:value];
        }
    }
    free(properties);
    NSDictionary* returnDic = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    return returnDic;
}


@end
