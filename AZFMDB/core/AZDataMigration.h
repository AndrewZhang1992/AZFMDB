//
//  AZDataMigration.h
//  AZFmdbDaoExample
//
//  Created by Andrew on 16/8/15.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  数据迁移
 */
@interface AZDataMigration : NSObject


/**
 *  检测db中 tb_className 表中 是否需要添加新字段
 *
 *  @discussion 默认数据表名为： tb_ ' className '
 *  @param className Class 类名
 */
+(void)dataMigrationClass:(Class)className;

/**
 *  检测db中 tableName 表中 是否需要添加新字段
 *
 *  @param className Class 类名
 *  @param tableName 表名
 */
+(void)dataMigrationClass:(Class)className TableName:(NSString *)tableName;


@end
