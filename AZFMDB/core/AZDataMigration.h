//
//  AZDataMigration.h
//  AZFmdbDaoExample
//
//  Created by Andrew on 16/8/15.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
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


/**
 *  检测db中 tableName 表中 是否需要添加新字段，可设置不考虑的字段数组
 *
 *  @param className         Class 类名
 *  @param tableName         表名
 *  @param ignoreRecondNames NSArray<NSString> 不考虑的字段数组
 */
+(void)dataMigrationClass:(Class)className TableName:(NSString *)tableName IgnoreRecondNames:(nullable NSArray *)ignoreRecondNames;


@end

NS_ASSUME_NONNULL_END