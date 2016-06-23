//
//  AZUser.h
//  AZFmdbDaoExample
//
//  Created by Andrew on 16/3/8.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  成员变量必须为 cocoa 下的类型，不能使用基础类型
 */
@interface AZUser : NSObject

@property (nonatomic,copy)NSString *name;
@property (nonatomic,strong)NSNumber *age;
@property (nonatomic,strong)NSNumber *sex;

@property (nonatomic,strong)NSMutableArray *ary;

@end
