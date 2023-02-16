//
//  ADJSQLiteStorageBase.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSQLiteStorageBase.h"

#pragma mark Fields
#pragma mark - Protected properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *storageExecutor;
 @property (nonnull, readonly, strong, nonatomic)
     id<ADJSQLiteDatabaseProvider> sqliteDatabaseProvider;
 @property (nonnull, readonly, strong, nonatomic) NSString *tableName;
 @property (nonnull, readonly, strong, nonatomic) NSString *metadataTypeValue;

 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *selectSql;
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *insertSql;
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *deleteAllSql;
 */

@implementation ADJSQLiteStorageBase
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    source:(nonnull NSString *)source
    storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
    sqliteDatabaseProvider:(nonnull id<ADJSQLiteDatabaseProvider>)sqliteDatabaseProvider
    tableName:(nonnull NSString *)tableName
    metadataTypeValue:(nonnull NSString *)metadataTypeValue
{
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJSQLiteStorageBase class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }

    self = [super initWithLoggerFactory:loggerFactory source:source];
    _storageExecutor = storageExecutor;
    _sqliteDatabaseProvider = sqliteDatabaseProvider;
    _tableName = tableName;
    _metadataTypeValue = metadataTypeValue;

    _selectSql = [self concreteGenerateSelectSqlWithTableName:tableName];
    _insertSql = [self concreteGenerateInsertSqlWithTableName:tableName];
    _deleteAllSql = [self generateDeleteAllSqlWithTableName:tableName];

    return self;
}

#pragma mark Public API
#pragma mark - ADJSQLiteStorage
- (void)readIntoMemorySync:(nonnull ADJSQLiteDb *)sqliteDb {
    [self.logger debugDev:@"Trying to read data from table in database to memory"
                      key:@"table name" value:self.tableName];

    if ([self transactReadIntoMemory:sqliteDb]) {
        [self.logger debugDev:@"Read data to memory"];
        return;
    }

    [self.logger debugDev:@"Did not read data to memory. Writing default initial state"];

    [self concreteWriteInStorageDefaultInitialDataSyncWithSqliteDb:sqliteDb];
}

- (nonnull NSString *)sqlStringForOnCreate {
    return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@ , %@)",
            self.tableName,
            [self concreteGenerateCreateTableFieldsSql],
            [self concreteGenerateCreateTablePrimaryKeySql]];
}

// - implemented by final class
- (nullable NSString *)sqlStringForOnUpgrade:(nonnull ADJNonNegativeInt *)oldVersion {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

// - implemented by final class
- (void)migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    [self doesNotRecognizeSelector:_cmd];
    return;
}

#pragma mark Protected Methods
- (nullable ADJNonEmptyString *)stringFromSelectStatement:(nonnull ADJSQLiteStatement *)selectStatement
                                              columnIndex:(int)columnIndex
                                                fieldName:(nonnull NSString *)fieldName {
    NSString *_Nullable fieldString = [selectStatement stringForColumnIndex:columnIndex];

    ADJResultNN<ADJNonEmptyString *> *_Nonnull fieldValueResult =
        [ADJNonEmptyString instanceFromString:fieldString];

    if (fieldValueResult.failMessage != nil) {
        [self.logger debugDev:@"Cannot get string value from select statement"
                    valueName:fieldName
                  failMessage:fieldValueResult.failMessage
                    issueType:ADJIssueStorageIo];

        return nil;
    }

    return fieldValueResult.value;
}

#pragma mark - Abstract
- (nonnull ADJNonEmptyString *)concreteGenerateSelectSqlWithTableName:(nonnull NSString *)tableName {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (nonnull ADJNonEmptyString *)concreteGenerateInsertSqlWithTableName:(nonnull NSString *)tableName {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)concreteWriteInStorageDefaultInitialDataSyncWithSqliteDb:(nonnull ADJSQLiteDb *)sqliteDb {
    [self doesNotRecognizeSelector:_cmd];
}

- (nonnull NSString *)concreteGenerateCreateTableFieldsSql {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (nonnull NSString *)concreteGenerateCreateTablePrimaryKeySql {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)concreteReadIntoMemoryFromSelectStatementInFirstRowSync:(nonnull ADJSQLiteStatement *)selectStatement {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

#pragma mark - NSObject
 - (nonnull NSString *)description {
     return self.source;
 }

#pragma mark Internal Methods
- (BOOL)transactReadIntoMemory:(nonnull ADJSQLiteDb *)sqliteDb {
    [sqliteDb beginTransaction];

    ADJSQLiteStatement *_Nullable selectStatement =
        [sqliteDb prepareStatementWithSqlString:self.selectSql.stringValue];

    if (selectStatement == nil) {
        [self.logger debugDev:
         @"Cannot read value from Db without a prepared statement from the select query"
                          key:@"selectSql"
                        value:self.selectSql.stringValue
                    issueType:ADJIssueStorageIo];
        [sqliteDb rollback];
        return NO;
    }

    BOOL wasAbleToStepToFirstRow = [selectStatement nextInQueryStatementWithLogger:self.logger];

    if (! wasAbleToStepToFirstRow) {
        [self.logger debugDev:
         @"Was not able to step to first row of select statement. It could be empty"
                          key:@"selectSql"
                        value:self.selectSql.stringValue];
        [selectStatement closeStatement];
        [sqliteDb rollback];
        return NO;
    }

    BOOL readIntoMemory =
    [self concreteReadIntoMemoryFromSelectStatementInFirstRowSync:selectStatement];

    [selectStatement closeStatement];
    [sqliteDb commit];

    return readIntoMemory;
}

- (nonnull ADJNonEmptyString *)generateDeleteAllSqlWithTableName:(nonnull NSString *)tableName {
    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            [NSString stringWithFormat:@"DELETE FROM %@", tableName]];
}

@end

