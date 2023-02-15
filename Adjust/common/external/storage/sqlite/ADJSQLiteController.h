//
//  ADJSQLiteController.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSQLiteDatabaseProvider.h"
#import "ADJSQLiteDb.h"
#import "ADJSQLiteStorage.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJSQLiteDatabaseName;

NS_ASSUME_NONNULL_END

@interface ADJSQLiteController : ADJCommonBase<ADJSQLiteDatabaseProvider>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                   instanceId:(nonnull NSString *)instanceId;

// public api
- (void)addSqlStorage:(nonnull id<ADJSQLiteStorage>)sqlStorage;

- (void)readAllIntoMemorySync;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJSQLiteDb *sqliteDb;

@end

