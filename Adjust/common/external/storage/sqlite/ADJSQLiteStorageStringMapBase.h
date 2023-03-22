//
//  ADJSQLiteStorageStringMapBase.h
//  Adjust
//
//  Created by Aditi Agrawal on 25/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStorageBase.h"
#import "ADJLoggerFactory.h"
#import "ADJSingleThreadExecutor.h"
#import "ADJSQLiteController.h"
#import "ADJSQLiteStorageActionBase.h"
#import "ADJNonEmptyString.h"
#import "ADJStringMap.h"

@interface ADJSQLiteStorageStringMapBase : ADJSQLiteStorageBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                       source:(nonnull NSString *)source
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
                                    tableName:(nonnull NSString *)tableName;

// public api
- (NSUInteger)countPairs;

- (nullable ADJNonEmptyString *)pairValueWithKey:(nonnull ADJNonEmptyString *)key;

- (nullable ADJNonEmptyString *)
    addPairWithValue:(nonnull ADJNonEmptyString *)value
    key:(nonnull ADJNonEmptyString *)key
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;

- (nullable ADJNonEmptyString *)
    removePairWithKey:(nonnull ADJNonEmptyString *)key
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;

- (NSUInteger)removeAllPairsWithSqliteStorageAction:
    (nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;

- (void)replaceAllWithStringMap:(nonnull ADJStringMap *)stringMap
            sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;

- (nonnull ADJStringMap *)allPairs;

@end

