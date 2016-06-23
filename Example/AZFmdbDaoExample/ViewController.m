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
    [zhangsan.ary addObjectsFromArray:@[@"123",@"abc"]];
    
    AZUser *lisi=[AZUser new];
    lisi.name=@"lisi";
    lisi.age=[NSNumber numberWithInt:22];
    lisi.sex=[NSNumber numberWithBool:NO];
  
    // 插入数据
#if 1
    
    // 使用model方式操作
    
    // 单次插入数据
    [[AZDataManager shareManager] insertModel:lisi];
    [[AZDataManager shareManager] insertModel:lisi inTable:@"tb_user"];
    
    
    [[AZDataManager shareManager] updateModel:lisi Condition:@"where id = 2"];
    
    // brief_sql
//    [[AZDataManager shareManager] insertRecordWithColumns:@{
//                                                           @"name":@"zja",
//                                                           @"sex":[NSNumber numberWithBool:YES],
//                                                           @"age":[NSNumber numberWithInt:29]
//                                                           } toTable:[AZDao tableNameByClassName:[AZUser class]]];
    
    // 批量插入数据
    [[AZDataManager shareManager] insertModelsByTransaction:@[zhangsan,
                                                                                                    lisi,
                                                                                                    lisi,
                                                                                                    zhangsan,
                                                                                                    lisi
                                                                                                    ]];
    
//    // brief_sql
//    [[AZDataManager shareManager] insertRecordByTransactionWithColumns:@[
//                                                                        @{
//                                                                            @"name":@"zja",
//                                                                            @"sex":[NSNumber numberWithBool:YES],
//                                                                            @"age":[NSNumber numberWithInt:29]
//                                                                            },
//                                                                        @{
//                                                                            @"name":@"sds",
//                                                                            @"sex":[NSNumber numberWithBool:NO],
//                                                                            @"age":[NSNumber numberWithInt:19]
//                                                                            },
//                                                                        @{
//                                                                            @"name":@"jj",
//                                                                            @"sex":[NSNumber numberWithBool:NO],
//                                                                            @"age":[NSNumber numberWithInt:39]
//                                                                            }
//                                                                        ] toTable:[AZDao tableNameByClassName:[AZUser class]]];
    
    
#endif
    

#if 0
    // 删除数据
    
    // 删除某一个记录
 
    [[AZDataManager shareManager] removeOneModel:lisi];
    
    // brief_sql
    [[AZDataManager shareManager] removeRecordWithCondition:@"where age='1'" fromTable:[AZDao tableNameByClassName:[AZUser class]]];
    
    // 删除所有
//    [[AZDataManager shareManager] removeAllModel:[AZUser class]];
    
    // brief_sql
//    [[AZDataManager shareManager] removeRecordWithCondition:nil fromTable:[AZDao tableNameByClassName:[AZUser class]]];
   
  
    
#endif
    
    
    AZUser *newZhangSan=[AZUser new];
    newZhangSan.name=zhangsan.name;
    newZhangSan.age=[NSNumber numberWithInt:28];
    newZhangSan.sex=[NSNumber numberWithBool:YES];
    
#if 0
    // 改数据
    [[AZDataManager shareManager] updateOneNewModel:newZhangSan oldModel:zhangsan];
    
    // brief_sql
//    [[AZDataManager shareManager] updataRecordWithColumns:@{@"name":@"历史"} Condition:@"where age='23'" toTable:[AZDao tableNameByClassName:[AZUser class]]];
    
    
#endif
    
    // 查询
    
#if 1
    // 部分查询
//    AZUser *u=[[[AZDataManager shareManager] findModel:[AZUser class] WithCondition:@"where age='39'"] lastObject];
//    NSLog(@"u.name=%@",u.name);
//    
//    // 部分查询 指定列名
//    AZUser *sm=[[[AZDataManager shareManager] findModel:[AZUser class] ColumnNames:@[@"age"] WithCondition:@"where age='39'"] lastObject];
//    NSLog(@"u.age=%ld",[sm.age integerValue]);
  
    // 全部查询
    NSArray *ary=[[AZDataManager shareManager] findAllModelWithClass:[AZUser class]];
    for (AZUser *user in ary) {
        NSLog(@"u.name=%@，u.age=%ld ，u.sex=%ld",user.name,(long)[user.age integerValue],[user.sex boolValue]);
    }
    
    //brief_sql
//    [[AZDataManager shareManager] findColumnNames:@[@"name",@"age"] recordsWithCondition:@"where age='22'" fromTable:[AZDao tableNameByClassName:[AZUser class]]];
    
#endif
    
    NSLog(@"%@",DB_PATH_ADDR);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
