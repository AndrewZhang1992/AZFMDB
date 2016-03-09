//
//  ViewController.m
//  AZFmdbDaoExample
//
//  Created by Andrew on 16/3/8.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "ViewController.h"
#import "AZFMDB.h"
#import "AZUser.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    AZUser *user=[AZUser new];
    
    // 创建数据库
    [AZDataManager shareManager];
    
    // 开启数据库
    [[AZDataManager shareManager] open];
    
    // 创建表
    [[AZDataManager shareManager] createTableModel:user];
    

    AZUser *zhangsan=[AZUser new];
    zhangsan.name=@"zhangsan";
    zhangsan.age=[NSNumber numberWithInt:25];
    zhangsan.sex=[NSNumber numberWithBool:YES];
    
    AZUser *lisi=[AZUser new];
    lisi.name=@"lisi";
    lisi.age=[NSNumber numberWithInt:22];
    lisi.sex=[NSNumber numberWithBool:NO];
  
    // 插入数据
#if 0
    
    [[AZDataManager shareManager] insertModel:lisi];
    
#endif
    

#if 0
    // 删除数据
    [[AZDataManager shareManager] deleteOneModel:lisi];
#endif
    
    
    AZUser *newZhangSan=[AZUser new];
    newZhangSan.name=zhangsan.name;
    newZhangSan.age=[NSNumber numberWithInt:28];
    newZhangSan.sex=[NSNumber numberWithBool:YES];
    
#if 0
    // 改数据
    [[AZDataManager shareManager] updateOneNewModel:newZhangSan oldModel:zhangsan];
#endif
    
    // 查询
    
#if 0
    // 部分查询
    AZUser *u=[[[AZDataManager shareManager] selectModel:[AZUser class] WithCondition:@"where age='22'"] lastObject];
    NSLog(@"u.name=%@",u.name);

    // 全部查询
    NSArray *ary=[[AZDataManager shareManager] selectAllModelFromTable:[AZUser class]];
    for (AZUser *user in ary) {
        NSLog(@"u.name=%@，u.age=%ld ，u.sex=%ld",user.name,(long)[user.age integerValue],[user.sex boolValue]);
    }
#endif
    
    NSLog(@"%@",DB_PATH_ADDR);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
