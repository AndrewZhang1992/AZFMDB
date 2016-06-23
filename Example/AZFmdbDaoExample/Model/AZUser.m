//
//  AZUser.m
//  AZFmdbDaoExample
//
//  Created by Andrew on 16/3/8.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZUser.h"

@implementation AZUser
-(instancetype)init
{
    if (self=[super init]) {
        [self initData];
    }
    return self;
}

-(void)initData
{
    _name=@"";
    _age=[NSNumber numberWithInt:0];
    _sex=[NSNumber numberWithBool:YES];
    _ary=[NSMutableArray array];
}

@end
