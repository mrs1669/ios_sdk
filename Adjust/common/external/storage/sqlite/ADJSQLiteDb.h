//
//  ADJSQLiteDb.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSQLiteDbMessageProvider.h"
#import "ADJTeardownFinalizer.h"
#import "ADJSQLiteStatement.h"

@interface ADJSQLiteDb : ADJCommonBase<ADJSQLiteDbMessageProvider, ADJTeardownFinalizer>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                 databasePath:(nullable NSString *)databasePath;

// public properties
@property (nullable, readonly, strong, nonatomic) NSString *databasePath;

// public api
- (int)dbVersion;
- (void)setDbVersion:(int)dbVersion;

- (BOOL)openDb;
- (BOOL)beginTransaction;
- (BOOL)commit;
- (BOOL)rollback;
- (void)close;

- (BOOL)executeStatements:(nonnull NSString *)sqlString;

- (nullable ADJSQLiteStatement *)prepareStatementWithSqlString:(nonnull NSString *)sqlString;

- (BOOL)executeUpdate:(nonnull NSString *)sqlUpdateString;

@end
