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

// 默认db存在的路径
#define DB_PATH_ADDR [NSString stringWithFormat:@"%@/Library/testDB.db",NSHomeDirectory()]

@interface ViewController ()
@property (nonatomic, strong) AZDataManager *dbManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 创建数据库
    self.dbManager = [[AZDataManager alloc] initWithPath:DB_PATH_ADDR];
    
    // 开启数据迁移
    // 如果项目中 没有sql 需要在版本升级的时候，执行数据迁移。那么 可以 不在项目中出现 [AZDataMigration startSQL], 不过建议开始执行该代码。
//    
    [AZDataMigration startSQLWithDataManager:self.dbManager];
//
//
    
//    NSArray *sql = @[
//                     @"alter table tb_AZUser change mail email text",
//                     @"alter table tb_AZUser drop abc"
//                     ];
//    [self.dbManager executeUpdateByTransaction:sql];
    
    
    // 创建表
    [self.dbManager createTableClassName:[AZUser class]];
    
    AZUser *zhangsan=[AZUser new];
    zhangsan.name=@"zhangsan";
    zhangsan.age=[NSNumber numberWithInt:25];
    zhangsan.sex=[NSNumber numberWithBool:YES];
    zhangsan.ageNum = 25;
    zhangsan.sexBool = YES;
    zhangsan.time = [[NSDate date] timeIntervalSince1970];
    [zhangsan.ary addObjectsFromArray:@[@"123",@"abc"]];
    zhangsan.dic = @{@"name":@"zhangsan",@"age":@24};
    
    AZUser *lisi=[AZUser new];
    lisi.name=@"lisi";
    lisi.age=[NSNumber numberWithInt:22];
    lisi.sex=[NSNumber numberWithBool:NO];
    lisi.dic = @{@"name":@"lisi",@"age":@24};
    
    [self.dbManager insertModel:zhangsan];
    [self.dbManager insertModel:lisi];
  
    NSArray *userArray = [self.dbManager findModel:[AZUser class] WithCondition:@"LIMIT 2"];
    AZUser *zhangsan1 = userArray[0];
    NSLog(@"%@",zhangsan1.age);
    NSLog(@"%ld",(long)zhangsan1.ageNum);
    NSLog(@"%d",zhangsan1.sexBool);
    NSLog(@"%@",zhangsan1.ary);
    NSLog(@"%@",zhangsan1.dic);
    
    // 多线程
#if 1
    
    [self.dbManager insertModel:zhangsan];
    [self.dbManager insertModel:lisi];
    dispatch_async(dispatch_queue_create("com.azfmdb.queue", DISPATCH_QUEUE_SERIAL), ^{
        [self.dbManager insertModel:zhangsan];
    });
    
    dispatch_async(dispatch_queue_create("com.azfmdb.queue", DISPATCH_QUEUE_SERIAL), ^{
        [self.dbManager insertModel:lisi];
    });
    
    dispatch_async(dispatch_queue_create("com.azfmdb.queue", DISPATCH_QUEUE_SERIAL), ^{
        [self.dbManager insertModel:zhangsan];
    });
    [self.dbManager findAllModelWithClass:[AZUser class]];
    [self.dbManager insertModel:lisi];
    dispatch_async(dispatch_queue_create("com.azfmdb.queue", DISPATCH_QUEUE_SERIAL), ^{
        [self.dbManager insertModel:lisi];
    });
    [self.dbManager findAllModelWithClass:[AZUser class]];
    
    
#endif
    // 插入数据
#if 0
    
    // 使用model方式操作
    
    // 单次插入数据
    [self.dbManager insertModel:lisi];
    [self.dbManager insertModel:lisi inTable:@"tb_user"];
    
    
    [self.dbManager updateModel:lisi Condition:@"where id = 2"];
    
    // brief_sql
//    [self.dbManager insertRecordWithColumns:@{
//                                                           @"name":@"zja",
//                                                           @"sex":[NSNumber numberWithBool:YES],
//                                                           @"age":[NSNumber numberWithInt:29]
//                                                           } toTable:[AZDao tableNameByClassName:[AZUser class]]];
    
    // 批量插入数据
    [self.dbManager insertModelsByTransaction:@[zhangsan,
                                                                                                    lisi,
                                                                                                    lisi,
                                                                                                    zhangsan,
                                                                                                    lisi
                                                                                                    ]];
    
//    // brief_sql
//    [self.dbManager insertRecordByTransactionWithColumns:@[
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
 
    [self.dbManager removeOneModel:lisi];
    
    // brief_sql
    [self.dbManager removeRecordWithCondition:@"where age='1'" fromTable:[AZDao tableNameByClassName:[AZUser class]]];
    
    // 删除所有
//    [self.dbManager removeAllModel:[AZUser class]];
    
    // brief_sql
//    [self.dbManager removeRecordWithCondition:nil fromTable:[AZDao tableNameByClassName:[AZUser class]]];
   
  
    
#endif
    
    
    AZUser *newZhangSan=[AZUser new];
    newZhangSan.name=zhangsan.name;
    newZhangSan.age=[NSNumber numberWithInt:28];
    newZhangSan.sex=[NSNumber numberWithBool:YES];
    
#if 0
    // 改数据
    [self.dbManager updateOneNewModel:newZhangSan oldModel:zhangsan];
    
    // brief_sql
//    [self.dbManager updataRecordWithColumns:@{@"name":@"历史"} Condition:@"where age='23'" toTable:[AZDao tableNameByClassName:[AZUser class]]];
    
    
#endif
    
    // 查询
    
#if 0
    // 部分查询
//    AZUser *u=[[self.dbManager findModel:[AZUser class] WithCondition:@"where age='39'"] lastObject];
//    NSLog(@"u.name=%@",u.name);
//    
//    // 部分查询 指定列名
//    AZUser *sm=[[self.dbManager findModel:[AZUser class] ColumnNames:@[@"age"] WithCondition:@"where age='39'"] lastObject];
//    NSLog(@"u.age=%ld",[sm.age integerValue]);
  
    // 全部查询
    NSArray *ary=[self.dbManager findAllModelWithClass:[AZUser class]];
    for (AZUser *user in ary) {
        NSLog(@"u.name=%@，u.age=%ld ，u.sex=%ld",user.name,(long)[user.age integerValue],[user.sex boolValue]);
    }
    
    //brief_sql
//    [self.dbManager findColumnNames:@[@"name",@"age"] recordsWithCondition:@"where age='22'" fromTable:[AZDao tableNameByClassName:[AZUser class]]];
    
#endif
    
    NSLog(@"%@",DB_PATH_ADDR);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
