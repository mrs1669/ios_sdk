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
#import "ADJNonNegativeInt.h"

@interface ADJSQLiteDb : ADJCommonBase<ADJSQLiteDbMessageProvider, ADJTeardownFinalizer>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory;

// public api
- (nonnull ADJNonNegativeInt *)dbVersion;
- (void)setDbVersion:(int)dbVersion;

- (BOOL)openDbWithPath:(nonnull NSString *)dbPath;
- (BOOL)beginTransaction;
- (BOOL)commit;
- (BOOL)rollback;
- (void)close;

- (BOOL)executeStatements:(nonnull NSString *)sqlString;

- (nullable ADJSQLiteStatement *)prepareStatementWithSqlString:(nonnull NSString *)sqlString;

- (BOOL)executeUpdate:(nonnull NSString *)sqlUpdateString;

@end
