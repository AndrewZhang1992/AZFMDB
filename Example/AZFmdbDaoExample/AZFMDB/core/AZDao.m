//
//  AZDao.m
//
//  Created by Andrew on 16/3/8.
//  Copyright © 2016年 Andrew. All rights reserved.
//


#import "AZDao.h"
#import <UIKit/UIKit.h>

#define intAry [AZDao intTypeArray]
#define textAry [AZDao textTypeArray]
#define blobAry [AZDao blobTypeArray]


NSString * const sql_int=@"integer";
NSString * const sql_text=@"text";
NSString * const sql_blob=@"blob";

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
    NSString *typeStr = [self propertyTypeFromAttributeName:attributeName];
    if ([typeStr hasPrefix:@"T@"]) {
        // cocoa 下的类名
        NSString *className=[typeStr substringWithRange:NSMakeRange(3, typeStr.length-2-2)];
        if ([textAry containsObject:className]) {
            // NSNumber
            if ([className isEqualToString:@"NSNumber"]) {
                NSString *lastStr=[[[attrAry lastObject] componentsSeparatedByString:@"V_"] lastObject];
                _Pragma("clang diagnostic push")
                _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
                NSNumber *number=[model performSelector:NSSelectorFromString(lastStr)]?:[NSNumber numberWithFloat:0.0];
                _Pragma("clang diagnostic pop")
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
        if ([intAry containsObject:[typeStr substringFromIndex:1]]) {
            return sql_int;
        }
        if ([textAry containsObject:[typeStr substringFromIndex:1]]){
            return sql_text;
        }
    }
    
    return nil;
}

+(NSString const*)sqlLiteTypeFromAttributeName:(NSString *)attributeName
{
    NSString *typeStr = [self propertyTypeFromAttributeName:attributeName];
    if ([typeStr hasPrefix:@"T@"]) {
        // cocoa 下的类名
        NSString *className=[typeStr substringWithRange:NSMakeRange(3, typeStr.length-2-2)];
        if ([textAry containsObject:className]) {
            // NSNumber
            return sql_text;
        }
        if ([blobAry containsObject:className]) {
            return sql_blob;
        }
    } else {
        // 基础类型
        // bool--Tc NSInteger--Tq NSUInteger--TQ CGFloat--Td int --Ti float --Tf
        if ([intAry containsObject:[typeStr substringFromIndex:1]]) {
            return sql_int;
        }
        if ([textAry containsObject:[typeStr substringFromIndex:1]]){
            return sql_text;
        }
    }
    return sql_text;
}

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
        
        // 更加精确体现在 @10   对应为 sql_int
        [valueArray addObject:[AZDao sqlLiteTypeFrom:propertyAttibute andModel:model]?:sql_text];
    }
    free(propertyList);
    return [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
}

+(NSDictionary *)propertySqlDictionaryFromClass:(Class)className
{
    Class class=className;
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
        
        // 扩展向上 体现在 nsnumber  全部为 sql_text
        [valueArray addObject:[AZDao sqlLiteTypeFrom:propertyAttibute]?:sql_text];
    }
    free(propertyList);
    return [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
}


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
        SEL selector = NSSelectorFromString([NSString stringWithUTF8String:propertyName]);
        NSMethodSignature* methodSig = [model methodSignatureForSelector:selector];
        if(methodSig == nil) {
            continue;
        }
        [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        const char* retType = [methodSig methodReturnType];
        if (strcmp(retType, @encode(NSInteger)) == 0) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
            [invocation setSelector:selector];
            [invocation setTarget:model];
            [invocation invoke];
            NSInteger result = 0;
            [invocation getReturnValue:&result];
            [valueArray addObject:@(result)];
            continue;
        }
        
        if (strcmp(retType, @encode(BOOL)) == 0) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
            [invocation setSelector:selector];
            [invocation setTarget:model];
            [invocation invoke];
            BOOL result = 0;
            [invocation getReturnValue:&result];
            [valueArray addObject:@(result)];
            continue;
        }
        
        if (strcmp(retType, @encode(CGFloat)) == 0) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
            [invocation setSelector:selector];
            [invocation setTarget:model];
            [invocation invoke];
            CGFloat result = 0;
            [invocation getReturnValue:&result];
            [valueArray addObject:@(result)];
            continue;
        }
        
        if (strcmp(retType, @encode(NSUInteger)) == 0) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
            [invocation setSelector:selector];
            [invocation setTarget:model];
            [invocation invoke];
            NSUInteger result = 0;
            [invocation getReturnValue:&result];
            [valueArray addObject:@(result)];
            continue;
        }
        _Pragma("clang diagnostic push")
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
        id value = [model performSelector:selector];
        _Pragma("clang diagnostic pop")
        if (value ==nil)
        [valueArray addObject:@""];
        else {
            if ([value isKindOfClass:[NSDictionary class]] ||
                [value isKindOfClass:[NSMutableDictionary class]] ||
                [value isKindOfClass:[NSArray class]] ||
                [value isKindOfClass:[NSMutableArray class]]) {
                
                [valueArray addObject:[AZDao jsonStrWithJSONObject:value]?:value];
            } else {
                [valueArray addObject:value];
            }
        }
    }
    free(properties);
    NSDictionary* returnDic = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    return returnDic;
}

+ (NSDictionary *)propertyListFromClass:(Class)className {
    u_int count;
    objc_property_t *properties = class_copyPropertyList(className, &count);
    NSMutableDictionary *propertyDic = [NSMutableDictionary dictionary];
    for (int i = 0; i < count; i++)
    {
        objc_property_t prop=properties[i];
        const char *propertyName = property_getName(prop);
        const char *propertyAttribute = property_getAttributes(prop);
        [propertyDic setValue:[AZDao propertyTypeFromAttributeName:[NSString stringWithCString:propertyAttribute encoding:NSUTF8StringEncoding]] forKey:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
    }
    free(properties);
    return [propertyDic copy];
}
    
#pragma mark - private
+ (NSString const*)sqlLiteTypeFrom:(const char *)strChar {
    NSString *attributeName=[NSString stringWithCString:strChar encoding:NSUTF8StringEncoding];
    return  [AZDao sqlLiteTypeFromAttributeName:attributeName];
}
    
+ (NSString *)propertyTypeFromAttributeName:(NSString *)attributeName {
    NSArray *attrAry=[attributeName componentsSeparatedByString:@","];
    NSString *propertyType =[attrAry firstObject];
    return propertyType;
}
    
+ (NSArray *)intTypeArray {
    NSArray *intTypeArray =  @[@"c",@"C",@"i",@"I",@"q",@"Q"];
    return intTypeArray;
}
    
+ (NSArray *)textTypeArray {
    NSArray *textTypeArray = @[@"f",@"F",@"d",@"D",
                               @"NSNumber",
                               @"NSDictionary",
                               @"NSMutableDictionary",
                               @"NSArray",
                               @"NSMutableArray",
                               @"NSString"
                               ];
    return textTypeArray;
}
    
+ (NSArray *)blobTypeArray {
    NSArray * blobTypeArray = @[@"UIImage"];
    return blobTypeArray;
}
    
+ (NSString *)jsonStrWithJSONObject:(id)jsonObjc {
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObjc options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = nil;
    if (data) {
        jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return jsonStr;
}
    
+ (id)jsonObjcWithJSONStr:(NSString *)jsonStr {
    if (jsonStr == nil) {
        return nil;
    }
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id jsonObjc = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return jsonObjc;
}

@end
