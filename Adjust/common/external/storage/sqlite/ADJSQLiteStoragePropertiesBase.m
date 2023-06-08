//
//  ADJSQLiteStoragePropertiesBase.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSQLiteStoragePropertiesBase.h"

#import "ADJIoDataBuilder.h"
#import "ADJConstants.h"
#import "ADJSQLiteStatement.h"
#import "ADJUtilSys.h"

#pragma mark Fields
#pragma mark - Protected properties
/* ADJSQLiteStorageBase.h
 @property (nullable, readonly, weak, nonatomic) ADJSingleThreadExecutor *storageExecutorWeak;
 @property (nullable, readonly, weak, nonatomic)
 id<ADJSQLiteDatabaseProvider> sqliteDatabaseProviderWeak;
 @property (nonnull, readonly, strong, nonatomic) NSString *tableName;
 @property (nonnull, readonly, strong, nonatomic) NSString *metadataTypeValue;
 
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *selectSql;
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *insertSql;
 */

#pragma mark - Private constants
static NSString *const kColumnMapName = @"map_name";
static NSString *const kColumnKey = @"key";
static NSString *const kColumnValue = @"value";

@interface ADJSQLiteStoragePropertiesBase ()
#pragma mark - Internal variables
@property (nonnull, readwrite, strong, nonatomic) id inMemoryDataValue;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *deleteSql;

@end

@implementation ADJSQLiteStoragePropertiesBase
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                       source:(nonnull NSString *)source
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
                                    tableName:(nonnull NSString *)tableName
                            metadataTypeValue:(nonnull NSString *)metadataTypeValue
                      initialDefaultDataValue:(nonnull id)initialDefaultDataValue {
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJSQLiteStoragePropertiesBase class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    
    self = [super initWithLoggerFactory:loggerFactory
                                 source:source
                        storageExecutor:storageExecutor
                 sqliteDatabaseProvider:sqliteController
                              tableName:tableName
                      metadataTypeValue:metadataTypeValue];
    
    _inMemoryDataValue = initialDefaultDataValue;
    
    _deleteSql =
    [[ADJNonEmptyString alloc]
     initWithConstStringValue:[NSString stringWithFormat:@"DELETE FROM %@",
                               self.tableName]];
    
    return self;
}

#pragma mark Public API
- (nonnull id)readOnlyStoredDataValue {
    return self.inMemoryDataValue;
}

- (void)updateWithNewDataValue:(nonnull id)newDataValue {
    [self updateInMemoryOnlyWithNewDataValue:newDataValue];
    
    [self updateInStorageOnlyWithNewDataValue:newDataValue];
}

- (void)updateInMemoryOnlyWithNewDataValue:(nonnull id)newDataValue {
    [self.logger debugDev:@"Updating value in memory"
                     key1:@"inMemoryDataValue"
                   value1:[self.inMemoryDataValue description]
                     key2:@"newDataValue"
                   value2:[newDataValue description]];

    self.inMemoryDataValue = newDataValue;
}

- (void)updateInStorageOnlyWithNewDataValue:(nonnull id)newDataValue {
    __typeof(self) __weak weakSelf = self;
    [self.storageExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf updateInStorageSyncWithSqliteDb:[strongSelf.sqliteDatabaseProvider sqliteDb]
                                       newDataValue:newDataValue];
    } source:@"update in storage only"];
}

- (BOOL)updateInTransactionWithsSQLiteDb:(nonnull ADJSQLiteDb *)sqliteDb
                            newDataValue:(nonnull id)newDataValue
{
    //[self printRowNumberWithSQLiteDb:sqliteDb];
    // delete all rows
    BOOL deletedSuccess = [self deleteAllInTransactionWithDb:sqliteDb];
    if (! deletedSuccess) {
        return NO;
    }
    [self.logger debugDev:@"Deleted all rows in update transaction"];
    
    //[self printRowNumberWithSQLiteDb:sqliteDb];
    
    BOOL insertedSuccess =
        [self insertValueInTransactionToDb:sqliteDb newDataValue:newDataValue];
    
    if (! insertedSuccess) {
        return NO;
    }
    [self.logger debugDev:@"Inserted new data values in update transaction"
                      key:@"newDataValue"
                    value:[newDataValue description]];

    return YES;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStorageBase
- (void)concreteWriteInStorageDefaultInitialDataSyncWithSqliteDb:(nonnull ADJSQLiteDb *)sqliteDb {
    // write the initial default set in the constructor in memory
    [self updateInStorageSyncWithSqliteDb:sqliteDb
                             newDataValue:self.inMemoryDataValue];
}

- (BOOL)concreteReadIntoMemoryFromSelectStatementInFirstRowSync:
    (nonnull ADJSQLiteStatement *)selectStatement
{
    ADJIoDataBuilder *_Nonnull ioDataBuilder =
        [[ADJIoDataBuilder alloc] initWithMetadataTypeValue:self.metadataTypeValue];
    
    do {
        [self readFromSelectStatementIntoBuildingData:selectStatement
                                        ioDataBuilder:ioDataBuilder];
    } while ([selectStatement nextInQueryStatementWithLogger:self.logger]);
    
    ADJIoData *_Nonnull ioData =
        [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];

    ADJResult<id> *_Nonnull valueFromIoDataResult =
        [self concreteGenerateValueFromIoData:ioData];

    if (valueFromIoDataResult.fail != nil) {
        [self.logger debugWithMessage:@"Cannot generate value from io data"
                         builderBlock:^(ADJLogBuilder * _Nonnull logBuilder) {
            [logBuilder withFail:valueFromIoDataResult.fail
                           issue:ADJIssueStorageIo];
            [logBuilder withKey:@"io data" value:[ioData description]];
        }];
    } else {
        _inMemoryDataValue = valueFromIoDataResult.value;
    }

    return valueFromIoDataResult.fail != nil;
}

- (nonnull ADJNonEmptyString *)concreteGenerateSelectSqlWithTableName:
    (nonnull NSString *)tableName
{
    return [[ADJNonEmptyString alloc]
            initWithConstStringValue:
                [NSString stringWithFormat:@"SELECT %@, %@, %@ FROM %@",
                 kColumnMapName,
                 kColumnKey,
                 kColumnValue,
                 tableName]];
}
static int const kSelectMapNameFieldIndex = 0;
static int const kSelectKeyFieldIndex = 1;
static int const kSelectValueFieldIndex = 2;

- (nonnull ADJNonEmptyString *)concreteGenerateInsertSqlWithTableName:(nonnull NSString *)tableName {
    return [[ADJNonEmptyString alloc]
            initWithConstStringValue:
                [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@) VALUES (?, ?, ?)",
                 tableName,
                 kColumnMapName,
                 kColumnKey,
                 kColumnValue]];
}
static int const kInsertMapNameFieldPosition = 1;
static int const kInsertKeyFieldPosition = 2;
static int const kInsertValueFieldPosition = 3;

- (nonnull NSString *)concreteGenerateCreateTableFieldsSql {
    return [NSString stringWithFormat:@"%@ TEXT NOT NULL, %@ TEXT NOT NULL, %@ TEXT",
            kColumnMapName,
            kColumnKey,
            kColumnValue];
}

- (nonnull NSString *)concreteGenerateCreateTablePrimaryKeySql {
    return [NSString stringWithFormat:@"PRIMARY KEY(%@, %@)",
            kColumnMapName,
            kColumnKey];
}

#pragma mark - Abstract
- (nonnull ADJResult<id> *)concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull id)dataValue {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Internal Methods
- (void)updateInStorageSyncWithSqliteDb:(nonnull ADJSQLiteDb *)sqliteDb
                           newDataValue:(nonnull id)newDataValue
{
    [sqliteDb beginTransaction];
    
    [self updateInTransactionWithsSQLiteDb:sqliteDb newDataValue:newDataValue];
    
    [sqliteDb commit];
    
    [self.logger debugDev:@"Updated in db"];
}

- (BOOL)deleteAllInTransactionWithDb:(nonnull ADJSQLiteDb *)sqliteDb {
    ADJSQLiteStatement *_Nullable deleteAllStatement =
        [sqliteDb prepareStatementWithSqlString:self.deleteAllSql.stringValue];
    
    if (deleteAllStatement == nil) {
        [self.logger debugDev:
         @"Cannot remove all in sqliteDb without a prepared statement"
                    issueType:ADJIssueStorageIo];
        return NO;
    }
    
    BOOL deleteAllSuccess =
    [deleteAllStatement executeUpdatePreparedStatementWithLogger:self.logger];
    
    [deleteAllStatement closeStatement];
    
    return deleteAllSuccess;
}

- (BOOL)insertValueInTransactionToDb:(nonnull ADJSQLiteDb *)sqliteDb
                        newDataValue:(nonnull id)newDataValue {
    ADJSQLiteStatement *_Nullable insertStatement =
        [sqliteDb prepareStatementWithSqlString:self.insertSql.stringValue];
    
    if (insertStatement == nil) {
        [self.logger debugDev:@"Cannot insert value to db without a prepared statement"
                    issueType:ADJIssueStorageIo];
        return NO;
    }
    
    ADJIoData *_Nonnull newValueIoData = [self concreteGenerateIoDataFromValue:newDataValue];
    
    BOOL success = [self insertValueInTransactionWithStatement:insertStatement
                                                newValueIoData:newValueIoData];
    
    [insertStatement closeStatement];
    
    return success;
}

- (BOOL)insertValueInTransactionWithStatement:(nonnull ADJSQLiteStatement *)insertStatement
                               newValueIoData:(nonnull ADJIoData *)newValueIoData {
    BOOL success = YES;
    
    for (NSString *_Nonnull mapName in newValueIoData.mapCollectionByName) {
        ADJStringMap *_Nonnull stringMap = [newValueIoData mapWithName:mapName];
        
        for (NSString *_Nonnull key in stringMap.map) {
            ADJNonEmptyString *_Nonnull value =
            [stringMap.map objectForKey:key];
            
            // clear bindings
            [insertStatement resetStatement];
            
            [insertStatement bindString:mapName columnIndex:kInsertMapNameFieldPosition];
            [insertStatement bindString:key columnIndex:kInsertKeyFieldPosition];
            [insertStatement bindString:value.stringValue columnIndex:kInsertValueFieldPosition];
            
            success = [insertStatement executeUpdatePreparedStatementWithLogger:self.logger];
            
            if (! success) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)readFromSelectStatementIntoBuildingData:(nonnull ADJSQLiteStatement *)selectStatement
                                  ioDataBuilder:(nonnull ADJIoDataBuilder *)ioDataBuilder {
    ADJNonEmptyString *_Nullable mapName =
    [self stringFromSelectStatement:selectStatement
                        columnIndex:kSelectMapNameFieldIndex
                          fieldName:kColumnMapName];
    if (mapName == nil) {
        return;
    }
    
    ADJNonEmptyString *_Nullable key =
    [self stringFromSelectStatement:selectStatement
                        columnIndex:kSelectKeyFieldIndex
                          fieldName:kColumnKey];
    if (key == nil) {
        return;
    }
    
    ADJNonEmptyString *_Nullable value =
    [self stringFromSelectStatement:selectStatement
                        columnIndex:kSelectValueFieldIndex
                          fieldName:kColumnValue];
    if (value == nil) {
        return;
    }
    
    [ioDataBuilder addEntryToMapByName:mapName.stringValue
                                   key:key.stringValue
                                 value:value];
}

- (void)printRowNumberWithSQLiteDb:(nonnull ADJSQLiteDb *)sqliteDb {
    NSString *selectCountSql =
        [NSString stringWithFormat: @"select count(*) from %@", self.tableName];
    
    ADJSQLiteStatement *_Nullable selectCountStatement =
        [sqliteDb prepareStatementWithSqlString:selectCountSql];
    
    if (selectCountStatement == nil) {
        [self.logger debugDev:
         @"Cannot count rows without a prepared statement from the select query"
                         key:@"selectCountSql"
                       value:selectCountSql
                    issueType:ADJIssueStorageIo];
        return;
    }
    
    BOOL wasAbleToStepToFirstRow =
        [selectCountStatement nextInQueryStatementWithLogger:self.logger];


    if (! wasAbleToStepToFirstRow) {
        [self.logger debugDev:
         @"Cannot count rows from Select queryCursor without a queryCursor from the select query"
                          key:@"selectCountSql"
                        value:selectCountSql
                    issueType:ADJIssueStorageIo];
        [selectCountStatement closeStatement];
        return;
    }
    
    NSNumber *_Nullable countNumber = [selectCountStatement numberIntForColumnIndex:0];
    
    [self.logger debugDev:@"table read with count number"
                     key1:@"tableName"
                   value1:self.tableName
                     key2:@"countNumber"
                   value2:countNumber.description];
    
    [selectCountStatement closeStatement];
}

@end
