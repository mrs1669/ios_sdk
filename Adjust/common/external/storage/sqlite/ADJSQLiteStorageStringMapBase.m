//
//  ADJSQLiteStorageStringMapBase.m
//  Adjust
//
//  Created by Aditi Agrawal on 25/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSQLiteStorageStringMapBase.h"

#import "ADJStringMapBuilder.h"
#import "ADJUtilSys.h"
#import "ADJUtilF.h"

#pragma mark Fields

#pragma mark - Private constants
static NSString *const kColumnKey = @"key";
static NSString *const kColumnValue = @"value";

@interface ADJSQLiteStorageStringMapBase ()
#pragma mark - Internal variables
@property (nonnull, readwrite, strong, nonatomic) ADJStringMap *inMemoryMapRO;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *deleteWhereKeySql;

@end

@implementation ADJSQLiteStorageStringMapBase
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                       source:(nonnull NSString *)source
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
                                    tableName:(nonnull NSString *)tableName {
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJSQLiteStorageStringMapBase class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }

    self = [super initWithLoggerFactory:loggerFactory
                                 source:source
                        storageExecutor:storageExecutor
                 sqliteDatabaseProvider:sqliteController
                              tableName:tableName
                      metadataTypeValue:@"StringMap"];

    _inMemoryMapRO = [[ADJStringMap alloc] initWithStringMapBuilder:
                      [[ADJStringMapBuilder alloc] initWithEmptyMap]];

    _deleteWhereKeySql = [self generateDeleteWhereKeySqlWithTableName:tableName];

    return self;
}

#pragma mark Public API
- (NSUInteger)countPairs {
    return [self.inMemoryMapRO countPairs];
}

- (nullable ADJNonEmptyString *)pairValueWithKey:(nonnull NSString *)key {
    return [self.inMemoryMapRO pairValueWithKey:key];
}

- (nullable ADJNonEmptyString *)addPairWithValue:(nonnull ADJNonEmptyString *)value
                                             key:(nonnull NSString *)key
                             sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    ADJStringMapBuilder *_Nonnull mapBuilder = [[ADJStringMapBuilder alloc] initWithStringMap:self.inMemoryMapRO];

    ADJNonEmptyString *_Nullable valueRemoved = [mapBuilder addPairWithValue:value key:key];

    self.inMemoryMapRO = [[ADJStringMap alloc] initWithStringMapBuilder:mapBuilder];

    [self addPairToStorageWithValue:value
                                key:key
                sqliteStorageAction:sqliteStorageAction];

    return valueRemoved;
}

- (nullable ADJNonEmptyString *)removePairWithKey:(nonnull NSString *)key
                              sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    ADJStringMapBuilder *_Nonnull mapBuilder = [[ADJStringMapBuilder alloc] initWithStringMap:self.inMemoryMapRO];

    ADJNonEmptyString *_Nullable valueRemoved = [mapBuilder removePairWithKey:key];

    self.inMemoryMapRO = [[ADJStringMap alloc] initWithStringMapBuilder:mapBuilder];

    [self removePairFromStorageWithKey:key
                   sqliteStorageAction:sqliteStorageAction];

    return valueRemoved;
}

- (NSUInteger)removeAllPairsWithSqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    NSUInteger removedPairsCount = [self.inMemoryMapRO countPairs];

    ADJStringMap *_Nonnull emptyMap = [[ADJStringMap alloc] initWithStringMapBuilder: [[ADJStringMapBuilder alloc] initWithEmptyMap]];

    [self replaceAllWithStringMap:emptyMap
              sqliteStorageAction:sqliteStorageAction];

    return removedPairsCount;
}

- (void)replaceAllWithStringMap:(nonnull ADJStringMap *)stringMap
            sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    self.inMemoryMapRO = stringMap;

    [self replaceAllFromStorageWithStringMap:stringMap
                         sqliteStorageAction:sqliteStorageAction];
}

- (nonnull ADJStringMap *)allPairs {
    return self.inMemoryMapRO;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStorageBase
- (void)concreteWriteInStorageDefaultInitialDataSyncWithSqliteDb:(nonnull ADJSQLiteDb *)sqliteDb {
    // an empty map does not have anything written in storage
    //  so, there is nothing to do
}

- (BOOL)concreteReadIntoMemoryFromSelectStatementInFirstRowSync:(nonnull ADJSQLiteStatement *)selectStatement {
    BOOL atLeastOneElementAdded = NO;

    ADJStringMapBuilder *_Nonnull mapBuilder = [[ADJStringMapBuilder alloc] initWithEmptyMap];
    do {
        NSString *_Nullable pairKeyString =
        [selectStatement stringForColumnIndex:kSelectKeyFieldIndex];

        ADJNonEmptyString *_Nullable pairKey =
        [ADJNonEmptyString instanceFromString:pairKeyString
                            sourceDescription:@"SQLite string map key"
                                       logger:self.logger];

        if (pairKey == nil) {
            continue;
        }

        NSString *_Nullable pairValueString =
        [selectStatement stringForColumnIndex:kSelectValueFieldIndex];

        ADJNonEmptyString *_Nullable pairValue =
        [ADJNonEmptyString instanceFromString:pairValueString
                            sourceDescription:@"SQLite string map value"
                                       logger:self.logger];

        if (pairValue == nil) {
            continue;
        }

        [mapBuilder addPairWithValue:pairValue
                                 key:pairKey.stringValue];

        atLeastOneElementAdded = YES;

    } while ([selectStatement nextInQueryStatementWithLogger:self.logger]);

    self.inMemoryMapRO = [[ADJStringMap alloc] initWithStringMapBuilder:mapBuilder];

    if (atLeastOneElementAdded) {
        [self.logger debug:@"Read %@ key value pairs to the map",
         [ADJUtilF uIntegerFormat:[self.inMemoryMapRO countPairs]]];
    } else {
        [self.logger debug:@"Did not read any key value pairs to the map"];
    }

    return atLeastOneElementAdded;
}

- (nonnull ADJNonEmptyString *)concreteGenerateSelectSqlWithTableName:(nonnull NSString *)tableName {
    return [[ADJNonEmptyString alloc] initWithConstStringValue:[NSString stringWithFormat:@"SELECT %@, %@ FROM %@",
                 kColumnKey, kColumnValue, tableName]];
}
static int const kSelectKeyFieldIndex = 0;
static int const kSelectValueFieldIndex = 1;

- (nonnull ADJNonEmptyString *)concreteGenerateInsertSqlWithTableName:(nonnull NSString *)tableName {
    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@, %@) VALUES (?, ?)",
             tableName,
             kColumnKey,
             kColumnValue]];
}
static int const kInsertKeyFieldPosition = 1;
static int const kInsertValueFieldPosition = 2;

- (nonnull NSString *)concreteGenerateCreateTableFieldsSql {
    return [NSString stringWithFormat:@"%@ TEXT NOT NULL, %@ TEXT",
            kColumnKey,
            kColumnValue];
}

- (nonnull NSString *)concreteGenerateCreateTablePrimaryKeySql {
    return [NSString stringWithFormat:@"PRIMARY KEY(%@)",
            kColumnKey];
}

#pragma mark Internal Methods
- (nonnull ADJNonEmptyString *)generateDeleteWhereKeySqlWithTableName:(nonnull NSString *)tableName {
    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",
             tableName,
             kColumnKey]];
}
static int const kDeleteKeyFieldPosition = 1;

- (void)addPairToStorageWithValue:(nonnull ADJNonEmptyString *)value
                              key:(nonnull NSString *)key
              sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    ADJSingleThreadExecutor *_Nullable storageExecutor = self.storageExecutorWeak;
    if (storageExecutor == nil) {
        [self.logger error:@"Cannot put key/value in storage"
         " without a reference to storageExecutor"];
        [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [storageExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }

        id<ADJSQLiteDatabaseProvider> _Nullable sqliteDatabaseProvider =
        strongSelf.sqliteDatabaseProviderWeak;

        if (sqliteDatabaseProvider == nil) {
            [strongSelf.logger error:@"Cannot put key/value in storage"
             " without a reference to sqliteDatabaseProvider"];
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }

        ADJSQLiteDb *_Nullable sqliteDb = [sqliteDatabaseProvider sqliteDb];

        if (sqliteDb == nil) {
            [strongSelf.logger error:@"Cannot put key/value in storage"
             " without a sqliteDb"];
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }

        [strongSelf addPairToDatabase:sqliteDb
                                value:value
                                  key:key
                  sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)addPairToDatabase:(nonnull ADJSQLiteDb *)sqliteDb
                    value:(nonnull ADJNonEmptyString *)value
                      key:(nonnull NSString *)key
      sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    [sqliteDb beginTransaction];

    ADJSQLiteStatement *_Nullable insertStatement =
    [sqliteDb prepareStatementWithSqlString:self.insertSql.stringValue];

    if (insertStatement == nil) {
        [self.logger error:@"Cannot add Key/Value in storage"
         " without a compiled insertStatement"];
        [sqliteDb rollback];
        [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
        return;
    }

    [self addPairInInsertStatement:insertStatement
                               key:key
                             value:value];

    [insertStatement closeStatement];

    if (sqliteStorageAction != nil) {
        if (! [sqliteStorageAction performStorageActionInDbTransaction:sqliteDb
                                                                logger:self.logger])
        {
            [self.logger error:@"Cannot add Key/Value in storage"
             " with failed storage action"];
            [sqliteDb rollback];
            return;
        }
    }

    [sqliteDb commit];
    [self.logger debug:@"Key/Value added to database"];
}

- (void)addPairInInsertStatement:(nonnull ADJSQLiteStatement *)insertStatement
                             key:(nonnull NSString *)key
                           value:(nonnull ADJNonEmptyString *)value {
    // clear bindings
    [insertStatement resetStatement];

    [insertStatement bindString:key columnIndex:kInsertKeyFieldPosition];
    [insertStatement bindString:value.stringValue columnIndex:kInsertValueFieldPosition];

    [insertStatement executeUpdatePreparedStatementWithLogger:self.logger];
}

- (void)removePairFromStorageWithKey:(nonnull NSString *)key
                 sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    ADJSingleThreadExecutor *_Nullable storageExecutor = self.storageExecutorWeak;
    if (storageExecutor == nil) {
        [self.logger error:@"Cannot remove key/value in storage"
         " without a reference to storageExecutor"];
        [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [storageExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }

        id<ADJSQLiteDatabaseProvider> _Nullable sqliteDatabaseProvider =
        strongSelf.sqliteDatabaseProviderWeak;

        if (sqliteDatabaseProvider == nil) {
            [strongSelf.logger error:@"Cannot remove key/value in storage"
             " without a reference to sqliteDatabaseProvider"];
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }

        ADJSQLiteDb *_Nullable sqliteDb = [sqliteDatabaseProvider sqliteDb];

        if (sqliteDb == nil) {
            [strongSelf.logger error:@"Cannot remove key/value in storage"
             " without a sqliteDb"];
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }

        [strongSelf removePairFromDatabase:sqliteDb
                                       key:key
                       sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)removePairFromDatabase:(nonnull ADJSQLiteDb *)sqliteDb
                           key:(nonnull NSString *)key
           sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    [sqliteDb beginTransaction];

    ADJSQLiteStatement *_Nullable deleteKeyValueStatement =
    [sqliteDb prepareStatementWithSqlString:self.deleteWhereKeySql.stringValue];

    if (deleteKeyValueStatement == nil) {
        [self.logger error:@"Cannot remove key/value in sqliteDb"
         " without a prepared statement"];
        [sqliteDb rollback];
        [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
        return;
    }

    [deleteKeyValueStatement bindString:key columnIndex:kDeleteKeyFieldPosition];

    [deleteKeyValueStatement executeUpdatePreparedStatementWithLogger:self.logger];

    [deleteKeyValueStatement closeStatement];

    if (sqliteStorageAction != nil) {
        if (! [sqliteStorageAction performStorageActionInDbTransaction:sqliteDb
                                                                logger:self.logger])
        {
            [self.logger error:@"Cannot remove key/value in sqliteDb"
             " with failed storage action"];
            [sqliteDb rollback];
            return;
        }
    }

    [sqliteDb commit];

    [self.logger debug:@"Key/Value removed from database"];
}

- (void)replaceAllFromStorageWithStringMap:(nonnull ADJStringMap *)stringMap
                       sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    ADJSingleThreadExecutor *_Nullable storageExecutor = self.storageExecutorWeak;
    if (storageExecutor == nil) {
        [self.logger error:@"Cannot replace all key/values in storage"
         " without a reference to storageExecutor"];
        [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [storageExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }

        id<ADJSQLiteDatabaseProvider> _Nullable sqliteDatabaseProvider =
        strongSelf.sqliteDatabaseProviderWeak;

        if (sqliteDatabaseProvider == nil) {
            [strongSelf.logger error:@"Cannot replace all key/values in storage"
             " without a reference to sqliteDatabaseProvider"];
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }

        ADJSQLiteDb *_Nullable sqliteDb = [sqliteDatabaseProvider sqliteDb];

        if (sqliteDb == nil) {
            [strongSelf.logger error:@"Cannot replace all key/values in storage"
             " without a sqliteDb"];
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }

        [strongSelf replaceAllFromDatabase:sqliteDb
                                 stringMap:stringMap
                       sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)replaceAllFromDatabase:(nonnull ADJSQLiteDb *)sqliteDb
                     stringMap:(nonnull ADJStringMap *)stringMap
           sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    [sqliteDb beginTransaction];

    ADJSQLiteStatement *_Nullable clearStatement =
    [sqliteDb prepareStatementWithSqlString:self.deleteAllSql.stringValue];

    if (clearStatement == nil) {
        [self.logger error:@"Cannot replace key/values in database"
         " without a prepared clear statement"];
        [sqliteDb rollback];
        [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
        return;
    }

    [clearStatement executeUpdatePreparedStatementWithLogger:self.logger];

    [clearStatement closeStatement];

    ADJSQLiteStatement *_Nullable insertStatement =
    [sqliteDb prepareStatementWithSqlString:self.insertSql.stringValue];

    if (insertStatement == nil) {
        [self.logger error:@"Cannot replace key/values in database"
         " without a compiled insertStatement"];
        [sqliteDb rollback];
        [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
        return;
    }

    for (NSString *_Nonnull key in stringMap.map) {
        ADJNonEmptyString *_Nonnull value = [stringMap.map objectForKey:key];

        [self addPairInInsertStatement:insertStatement
                                   key:key
                                 value:value];
    }

    [insertStatement closeStatement];

    if (sqliteStorageAction != nil) {
        if (! [sqliteStorageAction performStorageActionInDbTransaction:sqliteDb
                                                                logger:self.logger])
        {
            [self.logger error:@"Cannot replace key/values in sqliteDb"
             " with failed storage action"];
            [sqliteDb rollback];
            return;
        }
    }

    [sqliteDb commit];

    [self.logger debug:@"Key/Values replaced from database"];
}

@end
