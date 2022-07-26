//
//  ADJSQLiteStorageQueueBase.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSQLiteStorageQueueBase.h"

#import "ADJTallyCounter.h"
#import "ADJUtilSys.h"

#pragma mark Fields
#pragma mark - Protected properties

#pragma mark - Private constants
static NSString *const kColumnElementPosition = @"element_position";
static NSString *const kColumnMapName = @"map_name";
static NSString *const kColumnKey = @"key";
static NSString *const kColumnValue = @"value";

@interface ADJSQLiteStorageQueueBase ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) NSMutableDictionary<ADJNonNegativeInt *, id> *inMemoryQueueByPosition;
@property (nonnull, readonly, strong, nonatomic) NSMutableIndexSet *inMemoryPositionIndexSet;
//NSMutableArray<ADJNonNegativeInt *> *inMemoryPositionArray;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *deleteElementByPositionSql;
@property (nonnull, readwrite, strong, nonatomic) ADJTallyCounter *lastElementPosition;
@end

@implementation ADJSQLiteStorageQueueBase
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                       source:(nonnull NSString *)source
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
                                    tableName:(nonnull NSString *)tableName
                            metadataTypeValue:(nonnull NSString *)metadataTypeValue {
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJSQLiteStorageQueueBase class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    
    self = [super initWithLoggerFactory:loggerFactory
                                 source:source
                        storageExecutor:storageExecutor
                 sqliteDatabaseProvider:sqliteController
                              tableName:tableName
                      metadataTypeValue:metadataTypeValue];
    
    _inMemoryQueueByPosition = [NSMutableDictionary dictionary];
    //_inMemoryPositionArray = [NSMutableArray array];
    _inMemoryPositionIndexSet = [NSMutableIndexSet indexSet];
    
    _deleteElementByPositionSql = [self generateDeleteElementSqlWithTableName:tableName];
    
    _lastElementPosition = [ADJTallyCounter instanceStartingAtZero];
    
    return self;
}

#pragma mark Public API
- (nonnull ADJNonNegativeInt *)count {
    return [[ADJNonNegativeInt alloc]
            initWithUIntegerValue:self.inMemoryPositionIndexSet.count];
}

- (BOOL)isEmpty {
    return self.inMemoryQueueByPosition.count == 0;
}

- (nullable id)elementAtFront {
    if ([self isEmpty]) {
        return nil;
    }
    
    NSUInteger firstIndex = self.inMemoryPositionIndexSet.firstIndex;
    if (firstIndex == NSNotFound) {
        return nil;
    }
    
    return [self elementByPosition:
            [[ADJNonNegativeInt alloc] initWithUIntegerValue:firstIndex]];
}

- (nullable id)elementByPosition:(nonnull ADJNonNegativeInt *)elementPosition {
    return [self.inMemoryQueueByPosition objectForKey:elementPosition];
}

- (nonnull NSArray<id> *)copyElementList {
    return [NSArray arrayWithArray:[self.inMemoryQueueByPosition allValues]];
}

- (nonnull NSArray<ADJNonNegativeInt *> *)copySortedElementPositionList {
    // could also use inMemoryPositionIndexSet,
    //  but it's more straightforward with inMemoryQueueByPosition
    //  and it should be equivalent
    return [[self.inMemoryQueueByPosition allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (nonnull NSDictionary<ADJNonNegativeInt *, id> *)copyElementWithPositionList {
    return [NSDictionary dictionaryWithDictionary:self.inMemoryQueueByPosition];
}

- (nonnull ADJNonNegativeInt *)
enqueueElementToLast:(nonnull id)newElement
sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    ADJNonNegativeInt *_Nonnull newElementPosition = [self incrementAndReturnNewElementPosition];
    
    [self.inMemoryQueueByPosition setObject:newElement forKey:newElementPosition];
    [self.inMemoryPositionIndexSet addIndex:newElementPosition.uIntegerValue];
    
    [self addElementToStorage:newElement
           newElementPosition:newElementPosition
          sqliteStorageAction:sqliteStorageAction];
    
    return newElementPosition;
}

- (nullable id)removeElementAtFront {
    if ([self isEmpty]) {
        return nil;
    }
    
    NSUInteger firstIndex = self.inMemoryPositionIndexSet.firstIndex;
    if (firstIndex == NSNotFound) {
        return nil;
    }
    
    return [self removeElementByPosition:
            [[ADJNonNegativeInt alloc] initWithUIntegerValue:firstIndex]];
}

- (nullable id)removeElementByPosition:(nonnull ADJNonNegativeInt *)elementPositionToRemove {
    id _Nullable elementToRemove =
    [self removeElementByPositionInMemoryOnly:elementPositionToRemove];
    
    [self removeElementByPositionInStorageOnly:elementPositionToRemove];
    
    return elementToRemove;
}

- (BOOL)removeElementByPositionInTransaction:(nonnull ADJNonNegativeInt *)elementPositionToRemove
                                    sqliteDb:(nonnull ADJSQLiteDb *)sqliteDb {
    ADJSQLiteStatement *_Nullable deleteElementStatement =
    [sqliteDb prepareStatementWithSqlString:self.deleteElementByPositionSql.stringValue];
    
    if (deleteElementStatement == nil) {
        [self.logger error:@"Cannot remove element by position in sqliteDb"
         " without a prepared statement"];
        return NO;
    }
    
    [deleteElementStatement bindInt:(int)elementPositionToRemove.uIntegerValue
                        columnIndex:kDeleteElementPositionFieldPosition];
    
    BOOL deleteSuccess =
    [deleteElementStatement executeUpdatePreparedStatementWithLogger:self.logger];
    
    [deleteElementStatement closeStatement];
    
    return deleteSuccess;
}

- (nullable id)removeElementByPositionInMemoryOnly:
(nonnull ADJNonNegativeInt *)elementPositionToRemove {
    [self.inMemoryPositionIndexSet removeIndex:elementPositionToRemove.uIntegerValue];
    
    id _Nullable elementRemoved =
    [self.inMemoryQueueByPosition objectForKey:elementPositionToRemove];
    [self.inMemoryQueueByPosition removeObjectForKey:elementPositionToRemove];
    
    return elementRemoved;
}

- (void)removeElementByPositionInStorageOnly:
(nonnull ADJNonNegativeInt *)elementPositionToRemove {
    ADJSingleThreadExecutor *_Nullable storageExecutor = self.storageExecutorWeak;
    if (storageExecutor == nil) {
        [self.logger error:@"Cannot remove element by position in storage"
         " without a reference to storageExecutor"];
        return;
    }
    
    __typeof(self) __weak weakSelf = self;
    [storageExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        id<ADJSQLiteDatabaseProvider> _Nullable sqliteDatabaseProvider =
        strongSelf.sqliteDatabaseProviderWeak;
        
        if (sqliteDatabaseProvider == nil) {
            [strongSelf.logger error:@"Cannot remove element by position in storage"
             " without a reference to sqliteDatabaseProvider"];
            return;
        }
        
        ADJSQLiteDb *_Nullable sqliteDb = [sqliteDatabaseProvider sqliteDb];
        
        if (sqliteDb == nil) {
            [strongSelf.logger error:@"Cannot remove element by position in storage"
             " without a sqliteDb"];
            return;
        }
        
        [strongSelf removeElementByPosition:elementPositionToRemove
                                   sqliteDb:sqliteDb];
    }];
}

- (void)removeAllElements {
    if ([self isEmpty]) {
        return;
    }
    
    // in memory
    [self.inMemoryQueueByPosition removeAllObjects];
    [self.inMemoryPositionIndexSet removeAllIndexes];
    
    // in storage
    ADJSingleThreadExecutor *_Nullable storageExecutor = self.storageExecutorWeak;
    if (storageExecutor == nil) {
        [self.logger error:@"Cannot remove all elements in storage"
         " without a reference to storageExecutor"];
        return;
    }
    
    __typeof(self) __weak weakSelf = self;
    [storageExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        id<ADJSQLiteDatabaseProvider> _Nullable sqliteDatabaseProvider =
        strongSelf.sqliteDatabaseProviderWeak;
        
        if (sqliteDatabaseProvider == nil) {
            [strongSelf.logger error:@"Cannot remove all elements in storage"
             " without a reference to sqliteDatabaseProvider"];
            return;
        }
        
        ADJSQLiteDb *_Nullable sqliteDb = [sqliteDatabaseProvider sqliteDb];
        
        if (sqliteDb == nil) {
            [strongSelf.logger error:@"Cannot remove all elements in storage"
             " without a sqliteDb"];
            return;
        }
        
        [sqliteDb executeStatements:strongSelf.deleteAllSql.stringValue];
    }];
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStorageBase
- (void)concreteWriteInStorageDefaultInitialDataSyncWithSqliteDb:(nonnull ADJSQLiteDb *)sqliteDb {
    // an empty queue does not have anything written in storage
    //  so, there is nothing to do
}

- (BOOL)concreteReadIntoMemoryFromSelectStatementInFirstRowSync:(nonnull ADJSQLiteStatement *)selectStatement {
    NSNumber *_Nullable currentElementPositionNumber =
    [selectStatement numberIntForColumnIndex:kSelectElementPositionFieldIndex];
    
    if (currentElementPositionNumber == nil) {
        [self.logger error:@"Cannot get first select element position"];
        return NO;
    }
    
    ADJIoDataBuilder *_Nonnull ioDataBuilder =
    [[ADJIoDataBuilder alloc]
     initWithMetadataTypeValue:self.metadataTypeValue];
    
    BOOL atLeastOneElementAdded = NO;
    
    do {
        NSNumber *_Nullable readElementPositionNumber =
        [selectStatement numberIntForColumnIndex:kSelectElementPositionFieldIndex];
        
        // new element:
        if (! [currentElementPositionNumber isEqualToNumber:readElementPositionNumber]) {
            ADJNonNegativeInt *_Nullable elementPositionToAdd =
            [ADJNonNegativeInt instanceFromIntegerNumber:currentElementPositionNumber
                                                  logger:self.logger];
            
            BOOL elementAdded =
            [self
             addReadDataToInMemoryQueueWithIoData:
                 [[ADJIoData alloc] initWithIoDataBuider:ioDataBuilder]
             elementPositionToAdd:elementPositionToAdd];
            if (elementAdded) {
                atLeastOneElementAdded = YES;
            }
            
            // prepare for new element
            ioDataBuilder = [[ADJIoDataBuilder alloc]
                             initWithMetadataTypeValue:self.metadataTypeValue];
            currentElementPositionNumber = readElementPositionNumber;
        }
        
        if (readElementPositionNumber == nil) {
            [self.logger error:@"Cannot get select element position"];
            break;
        }
        
        [self readFromSelectStatementIntoBuildingData:selectStatement
                                        ioDataBuilder:ioDataBuilder];
        
    } while ([selectStatement nextInQueryStatementWithLogger:self.logger]);
    
    // last element
    ADJNonNegativeInt *_Nullable lastElementPositionToAdd =
    [ADJNonNegativeInt instanceFromIntegerNumber:currentElementPositionNumber
                                          logger:self.logger];
    
    BOOL elementAdded =
    [self addReadDataToInMemoryQueueWithIoData:[[ADJIoData alloc]
                                                initWithIoDataBuider:ioDataBuilder]
                          elementPositionToAdd:lastElementPositionToAdd];
    
    if (lastElementPositionToAdd != nil) {
        self.lastElementPosition =
        [[ADJTallyCounter alloc] initWithCountValue:lastElementPositionToAdd];
    }
    
    if (elementAdded) {
        atLeastOneElementAdded = YES;
    }
    
    if (atLeastOneElementAdded) {
        [self.logger debug:@"Read %@ elements to the queue", [self count]];
    } else {
        [self.logger debug:@"Did not read any element to the queue"];
    }
    
    return atLeastOneElementAdded;
}

- (nonnull ADJNonEmptyString *)concreteGenerateSelectSqlWithTableName:
(nonnull NSString *)tableName {
    return [[ADJNonEmptyString alloc]
            initWithConstStringValue:
                [NSString stringWithFormat:@"SELECT %@, %@, %@, %@ FROM %@ ORDER BY %@",
                 kColumnElementPosition,
                 kColumnMapName,
                 kColumnKey,
                 kColumnValue,
                 tableName,
                 kColumnElementPosition]];
}
static int const kSelectElementPositionFieldIndex = 0;
static int const kSelectMapNameFieldIndex = 1;
static int const kSelectKeyFieldIndex = 2;
static int const kSelectValueFieldIndex = 3;

- (nonnull ADJNonEmptyString *)concreteGenerateInsertSqlWithTableName:
(nonnull NSString *)tableName {
    return [[ADJNonEmptyString alloc]
            initWithConstStringValue:
                [NSString stringWithFormat:
                 @"INSERT INTO %@ (%@, %@, %@, %@) VALUES (?, ?, ?, ?)",
                 tableName,
                 kColumnElementPosition,
                 kColumnMapName,
                 kColumnKey,
                 kColumnValue]];
}
static int const kInsertElementPositionFieldPosition = 1;
static int const kInsertMapNameFieldPosition = 2;
static int const kInsertKeyFieldPosition = 3;
static int const kInsertValueFieldPosition = 4;

- (nonnull NSString *)concreteGenerateCreateTableFieldsSql {
    return [NSString stringWithFormat:
            @"%@ INTEGER NOT NULL, %@ TEXT NOT NULL, %@ TEXT NOT NULL, %@ TEXT",
            kColumnElementPosition,
            kColumnMapName,
            kColumnKey,
            kColumnValue];
}

- (nonnull NSString *)concreteGenerateCreateTablePrimaryKeySql {
    return [NSString stringWithFormat:@"PRIMARY KEY(%@, %@, %@)",
            kColumnElementPosition,
            kColumnMapName,
            kColumnKey];
}

#pragma mark - Abstract
- (nullable id)concreteGenerateElementFromIoData:(nonnull ADJIoData *)ioData {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (nonnull ADJIoData *)concreteGenerateIoDataFromElement:(nonnull id)element {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Internal Methods
- (nonnull ADJNonEmptyString *)generateDeleteElementSqlWithTableName:
(nonnull NSString *)tableName {
    return [[ADJNonEmptyString alloc]
            initWithConstStringValue:
                [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",
                 tableName,
                 kColumnElementPosition]];
}
static int const kDeleteElementPositionFieldPosition = 1;

- (BOOL)addReadDataToInMemoryQueueWithIoData:(nonnull ADJIoData *)readIoData
                        elementPositionToAdd:(nullable ADJNonNegativeInt *)elementPositionToAdd {
    if (elementPositionToAdd == nil) {
        [self.logger error:@"Cannot add element to queue %@, without a valid element position",
         self.metadataTypeValue];
        return NO;
    }
    
    id _Nullable lastReadElement = [self concreteGenerateElementFromIoData:readIoData];
    
    if (lastReadElement == nil) {
        [self.logger error:@"Cannot create element for queue %@,"
         " from IoData: %@, with element position: %@",
         self.metadataTypeValue, readIoData, elementPositionToAdd];
        return NO;
    }
    
    [self.inMemoryQueueByPosition setObject:lastReadElement forKey:elementPositionToAdd];
    [self.inMemoryPositionIndexSet addIndex:elementPositionToAdd.uIntegerValue];
    
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

- (nonnull ADJNonNegativeInt *)incrementAndReturnNewElementPosition {
    if ([self isEmpty]) {
        self.lastElementPosition = [self.lastElementPosition generateIncrementedCounter];
        return self.lastElementPosition.countValue;
    }
    
    NSUInteger lastIndex = self.inMemoryPositionIndexSet.lastIndex;
    if (lastIndex == NSNotFound) {
        self.lastElementPosition = [self.lastElementPosition generateIncrementedCounter];
        return self.lastElementPosition.countValue;
    }
    
    if (lastIndex > self.lastElementPosition.countValue.uIntegerValue) {
        self.lastElementPosition =
        [[ADJTallyCounter alloc] initWithCountValue:
         [[ADJNonNegativeInt alloc] initWithUIntegerValue:lastIndex]];
    }
    
    self.lastElementPosition = [self.lastElementPosition generateIncrementedCounter];
    return self.lastElementPosition.countValue;
}

- (void)addElementToStorage:(nonnull id)newElement
         newElementPosition:(nonnull ADJNonNegativeInt *)newElementPosition
        sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    ADJSingleThreadExecutor *_Nullable storageExecutor = self.storageExecutorWeak;
    if (storageExecutor == nil) {
        [self.logger error:@"Cannot add element by position in storage"
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
            [strongSelf.logger error:@"Cannot add element by position in storage"
             " without a reference to sqliteDatabaseProvider"];
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }
        
        ADJSQLiteDb *_Nullable sqliteDb = [sqliteDatabaseProvider sqliteDb];
        
        if (sqliteDb == nil) {
            [strongSelf.logger error:@"Cannot add element by position in storage"
             " without a sqliteDb"];
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }
        
        [strongSelf addElementToSqliteDb:sqliteDb
                              newElement:newElement
                      newElementPosition:newElementPosition
                     sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)addElementToSqliteDb:(nonnull ADJSQLiteDb *)sqliteDb
                  newElement:(nonnull id)newElement
          newElementPosition:(nonnull ADJNonNegativeInt *)newElementPosition
         sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    [sqliteDb beginTransaction];
    
    ADJSQLiteStatement *_Nullable insertStatement =
    [sqliteDb prepareStatementWithSqlString:self.insertSql.stringValue];
    
    if (insertStatement == nil) {
        [self.logger error:@"Cannot add element by position in storage"
         " without a compiled insertStatement"];
        [sqliteDb rollback];
        [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
        return;
    }
    
    ADJIoData *_Nonnull newElementIoData =
    [self concreteGenerateIoDataFromElement:newElement];
    
    [self insertElementWithStatement:insertStatement
                    newElementIoData:newElementIoData
                  newElementPosition:newElementPosition];
    
    [insertStatement closeStatement];
    
    if (sqliteStorageAction != nil) {
        if (! [sqliteStorageAction performStorageActionInDbTransaction:sqliteDb
                                                                logger:self.logger])
        {
            [self.logger error:@"Cannot add element by position in storage"
             " with failed storage action"];
            [sqliteDb rollback];
            return;
        }
    }
    
    [sqliteDb commit];
    [self.logger debug:@"Element added to database"];
}

- (void)insertElementWithStatement:(nonnull ADJSQLiteStatement *)insertStatement
                  newElementIoData:(nonnull ADJIoData *)newElementIoData
                newElementPosition:(nonnull ADJNonNegativeInt *)newElementPosition {
    for (NSString *_Nonnull mapName in newElementIoData.mapCollectionByName) {
        ADJStringMap *_Nonnull map = [newElementIoData.mapCollectionByName objectForKey:mapName];
        
        for (NSString *_Nonnull key in map.map) {
            ADJNonEmptyString *_Nonnull value = [map.map objectForKey:key];
            
            // clear bindings
            [insertStatement resetStatement];
            
            [insertStatement bindInt:(int)newElementPosition.uIntegerValue
                         columnIndex:kInsertElementPositionFieldPosition];
            [insertStatement bindString:mapName columnIndex:kInsertMapNameFieldPosition];
            [insertStatement bindString:key columnIndex:kInsertKeyFieldPosition];
            [insertStatement bindString:value.stringValue columnIndex:kInsertValueFieldPosition];
            
            [insertStatement executeUpdatePreparedStatementWithLogger:self.logger];
        }
    }
}

- (void)removeElementByPosition:(nonnull ADJNonNegativeInt *)elementPositionToRemove
                       sqliteDb:(nonnull ADJSQLiteDb *)sqliteDb {
    [sqliteDb beginTransaction];
    
    BOOL elementDeleted = [self removeElementByPositionInTransaction:elementPositionToRemove
                                                            sqliteDb:sqliteDb];
    
    if (elementDeleted) {
        [sqliteDb commit];
    } else {
        [sqliteDb rollback];
    }
}

@end
