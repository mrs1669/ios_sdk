//
//  ADJSQLiteStorageBase.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSQLiteStorage.h"
#import "ADJSingleThreadExecutor.h"
#import "ADJSQLiteDatabaseProvider.h"
#import "ADJNonEmptyString.h"
#import "ADJSQLiteDb.h"
#import "ADJSQLiteStatement.h"

@interface ADJSQLiteStorageBase : ADJCommonBase<ADJSQLiteStorage>
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    source:(nonnull NSString *)source
    storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
    sqliteDatabaseProvider:(nonnull id<ADJSQLiteDatabaseProvider>)sqliteDatabaseProvider
    tableName:(nonnull NSString *)tableName
    metadataTypeValue:(nonnull NSString *)metadataTypeValue;

// protected
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *storageExecutor;
@property (nonnull, readonly, strong, nonatomic)
    id<ADJSQLiteDatabaseProvider> sqliteDatabaseProvider;
@property (nonnull, readonly, strong, nonatomic) NSString *tableName;
@property (nonnull, readonly, strong, nonatomic) NSString *metadataTypeValue;

@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *selectSql;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *insertSql;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *deleteAllSql;

- (nullable ADJNonEmptyString *)stringFromSelectStatement:(nonnull ADJSQLiteStatement *)selectStatement
                                              columnIndex:(int)columnIndex
                                                fieldName:(nonnull NSString *)fieldName;

// protected abstract
- (nonnull ADJNonEmptyString *)concreteGenerateSelectSqlWithTableName:(nonnull NSString *)tableName;
- (nonnull ADJNonEmptyString *)concreteGenerateInsertSqlWithTableName:(nonnull NSString *)tableName;

- (void)concreteWriteInStorageDefaultInitialDataSyncWithSqliteDb:(nonnull ADJSQLiteDb *)sqliteDb;

- (nonnull NSString *)concreteGenerateCreateTableFieldsSql;
- (nonnull NSString *)concreteGenerateCreateTablePrimaryKeySql;
- (BOOL)concreteReadIntoMemoryFromSelectStatementInFirstRowSync:(nonnull ADJSQLiteStatement *)selectStatement;
@end

