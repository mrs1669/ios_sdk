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
@property (nonnull, readonly, strong, nonatomic)
    NSMutableDictionary<ADJNonNegativeInt *, id> *inMemoryQueueByPosition;
@property (nonnull, readonly, strong, nonatomic) NSMutableIndexSet *inMemoryPositionIndexSet;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *deleteElementByPositionSql;
@property (nonnull, readwrite, strong, nonatomic) ADJTallyCounter *lastElementPosition;
@property (nonnull, readwrite, strong, nonatomic) ADJStringMap *metadataMap;

@end

@implementation ADJSQLiteStorageQueueBase
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                   loggerName:(nonnull NSString *)loggerName
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
                                    tableName:(nonnull NSString *)tableName
                            metadataTypeValue:(nonnull NSString *)metadataTypeValue
{
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJSQLiteStorageQueueBase class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }

    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:loggerName
                        storageExecutor:storageExecutor
                 sqliteDatabaseProvider:sqliteController
                              tableName:tableName
                      metadataTypeValue:metadataTypeValue];

    _inMemoryQueueByPosition = [NSMutableDictionary dictionary];
    //_inMemoryPositionArray = [NSMutableArray array];
    _inMemoryPositionIndexSet = [NSMutableIndexSet indexSet];

    _deleteElementByPositionSql = [self generateDeleteElementSqlWithTableName:tableName];

    // starts at zero, but it is always increments before adding
    //  therefore, no element added will be less than one
    _lastElementPosition = [ADJTallyCounter instanceStartingAtZero];

    ADJIoDataBuilder *_Nonnull ioDataBuilder =
        [[ADJIoDataBuilder alloc] initWithMetadataTypeValue:self.metadataTypeValue];
    ADJIoData *_Nonnull ioData = [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
    _metadataMap = ioData.metadataMap;

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

- (nullable ADJNonNegativeInt *)positionAtFront {
    if ([self isEmpty]) {
        return nil;
    }

    NSUInteger firstIndex = self.inMemoryPositionIndexSet.firstIndex;
    if (firstIndex == NSNotFound) {
        return nil;
    }

    return [[ADJNonNegativeInt alloc] initWithUIntegerValue:firstIndex];
}

- (nullable id)elementAtFront {
    return [self elementByPosition:[self positionAtFront]];
}

- (nullable id)elementByPosition:(nullable ADJNonNegativeInt *)elementPosition {
    return elementPosition != nil ?
        [self.inMemoryQueueByPosition objectForKey:elementPosition] : nil;
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
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
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
            [[ADJNonNegativeInt alloc] initWithUIntegerValue:firstIndex]
                     sqliteStorageAction:nil];
}

- (nullable id)removeElementByPosition:(nonnull ADJNonNegativeInt *)elementPositionToRemove
                   sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    id _Nullable elementToRemove =
        [self removeElementByPositionInMemoryOnly:elementPositionToRemove];

    [self removeElementByPositionInStorageOnly:elementPositionToRemove
                           sqliteStorageAction:sqliteStorageAction];

    return elementToRemove;
}

- (BOOL)removeElementByPositionInTransaction:(nonnull ADJNonNegativeInt *)elementPositionToRemove
                                    sqliteDb:(nonnull ADJSQLiteDb *)sqliteDb
{
    ADJSQLiteStatement *_Nullable deleteElementStatement =
        [sqliteDb prepareStatementWithSqlString:self.deleteElementByPositionSql.stringValue];

    if (deleteElementStatement == nil) {
        [self.logger debugDev:
         @"Cannot remove element by position in sqliteDb without a prepared statement"
                    issueType:ADJIssueStorageIo];
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
    (nonnull ADJNonNegativeInt *)elementPositionToRemove
{
    [self.inMemoryPositionIndexSet removeIndex:elementPositionToRemove.uIntegerValue];

    id _Nullable elementRemoved =
        [self.inMemoryQueueByPosition objectForKey:elementPositionToRemove];
    [self.inMemoryQueueByPosition removeObjectForKey:elementPositionToRemove];

    return elementRemoved;
}
- (void)removeElementByPositionInStorageOnly:(nonnull ADJNonNegativeInt *)elementPositionToRemove {
     [self removeElementByPositionInStorageOnly:elementPositionToRemove
                            sqliteStorageAction:nil];
}
- (void)
    removeElementByPositionInStorageOnly:(nonnull ADJNonNegativeInt *)elementPositionToRemove
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.storageExecutor
     executeInSequenceWithLogger:self.logger
     from:@"remove element by position in storage only"
     block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }

        [strongSelf removeElementByPosition:elementPositionToRemove
                                   sqliteDb:[strongSelf.sqliteDatabaseProvider sqliteDb]
                        sqliteStorageAction:sqliteStorageAction];
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
    __typeof(self) __weak weakSelf = self;
    [self.storageExecutor executeInSequenceWithLogger:self.logger
                                                     from:@"remove all elements"
                                                    block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        ADJSQLiteDb *_Nonnull sqliteDb = [strongSelf.sqliteDatabaseProvider sqliteDb];
        [sqliteDb executeStatements:strongSelf.deleteAllSql.stringValue];
    }];
}

- (void)updateMetadataWithMap:(nonnull ADJStringMap *)newMetadataMap {
    [self updateMetadataInMemoryOnlyWithMap:newMetadataMap];

    [self updateMetadataInStorageOnlyWitMap:newMetadataMap];
}

- (void)updateMetadataInMemoryOnlyWithMap:(nonnull ADJStringMap *)newMetadataMap {
    self.metadataMap = newMetadataMap;
}
- (BOOL)updateMetadataInTransactionWithMap:(nonnull ADJStringMap *)newMetadataMap
                                  sqliteDb:(nonnull ADJSQLiteDb *)sqliteDb
{
    return
        [self removeElementByPositionInTransaction:[ADJNonNegativeInt instanceAtZero]
                                          sqliteDb:sqliteDb]
        &&
        [self addElementInTransactionToSqliteDb:sqliteDb
                                     newElement:newMetadataMap
                             newElementPosition:[ADJNonNegativeInt instanceAtZero]];
}
- (void)updateMetadataInStorageOnlyWitMap:(nonnull ADJStringMap *)newMetadataMap {
    [self removeElementByPositionInStorageOnly:[ADJNonNegativeInt instanceAtZero]];

    [self addElementToStorage:newMetadataMap
           newElementPosition:[ADJNonNegativeInt instanceAtZero]
          sqliteStorageAction:nil];
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStorageBase
- (void)concreteWriteInStorageDefaultInitialDataSyncWithSqliteDb:(nonnull ADJSQLiteDb *)sqliteDb {
    [self removeElementByPosition:[ADJNonNegativeInt instanceAtZero]
                         sqliteDb:sqliteDb
              sqliteStorageAction:nil];

    [self addElementToSqliteDb:sqliteDb
                     newElement:self.metadataMap
             newElementPosition:[ADJNonNegativeInt instanceAtZero]
            sqliteStorageAction:nil];
}

- (BOOL)concreteReadIntoMemoryFromSelectStatementInFirstRowSync:
    (nonnull ADJSQLiteStatement *)selectStatement
{
    NSNumber *_Nullable currentElementPositionNumber =
        [selectStatement numberIntForColumnIndex:kSelectElementPositionFieldIndex];

    if (currentElementPositionNumber == nil) {
        [self.logger debugDev:@"Cannot get first select element position"
                    issueType:ADJIssueStorageIo];
        return NO;
    }

    ADJIoDataBuilder *_Nonnull ioDataBuilder =
        [[ADJIoDataBuilder alloc] initWithMetadataTypeValue:self.metadataTypeValue];

    BOOL atLeastOneElementAdded = NO;

    do {
        NSNumber *_Nullable readElementPositionNumber =
            [selectStatement numberIntForColumnIndex:kSelectElementPositionFieldIndex];

        // new element:
        if (! [currentElementPositionNumber isEqualToNumber:readElementPositionNumber]) {
            ADJNonNegativeInt *_Nullable positionOfAddedElement =
                [self addReadDataToInMemoryQueueWithIoData:
                 [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder]
                              currentElementPositionNumber:currentElementPositionNumber];
            if (positionOfAddedElement != nil) {
                atLeastOneElementAdded = YES;
            }

            // prepare for new element
            ioDataBuilder = [[ADJIoDataBuilder alloc]
                             initWithMetadataTypeValue:self.metadataTypeValue];
            currentElementPositionNumber = readElementPositionNumber;
        }

        if (readElementPositionNumber == nil) {
            [self.logger debugDev:@"Cannot get select element position"
                        issueType:ADJIssueStorageIo];
            break;
        }

        [self readFromSelectStatementIntoBuildingData:selectStatement
                                        ioDataBuilder:ioDataBuilder];

    } while ([selectStatement nextInQueryStatementWithLogger:self.logger]);

    // last element
    ADJNonNegativeInt *_Nullable positionOfLastAddedElement =
        [self addReadDataToInMemoryQueueWithIoData:
         [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder]
                      currentElementPositionNumber:currentElementPositionNumber];

    if (positionOfLastAddedElement != nil) {
        self.lastElementPosition =
            [[ADJTallyCounter alloc] initWithCountValue:positionOfLastAddedElement];

        atLeastOneElementAdded = YES;
    }

    if (atLeastOneElementAdded) {
        [self.logger debugDev:@"Read elements to the queue"
                          key:@"count"
                  stringValue:[self count].description];
    } else {
        [self.logger debugDev:@"Did not read any element to the queue"];
    }

    return atLeastOneElementAdded;
}

- (nonnull ADJNonEmptyString *)concreteGenerateSelectSqlWithTableName:
    (nonnull NSString *)tableName
{
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
    (nonnull NSString *)tableName
{
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
- (nonnull ADJResult<id> *)concreteGenerateElementFromIoData:(nonnull ADJIoData *)ioData {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromElement:(nonnull id)element {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Internal Methods
- (nonnull ADJNonEmptyString *)generateDeleteElementSqlWithTableName:(nonnull NSString *)tableName {
    return [[ADJNonEmptyString alloc]
            initWithConstStringValue:
                [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",
                 tableName,
                 kColumnElementPosition]];
}
static int const kDeleteElementPositionFieldPosition = 1;

- (nullable ADJNonNegativeInt *)
    addReadDataToInMemoryQueueWithIoData:(nonnull ADJIoData *)readIoData
    currentElementPositionNumber:(nonnull NSNumber *)currentElementPositionNumber
{
    ADJResult<ADJNonNegativeInt *> *_Nonnull elementPositionToAddResult =
        [ADJNonNegativeInt instanceFromIntegerNumber:currentElementPositionNumber];

    if (elementPositionToAddResult.fail != nil) {
        [self.logger debugWithMessage:@"Cannot add element to memory queue"
                         builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
         {
            [logBuilder withSubject:@"element position"
                                why:@"failed to parse from number"];
            [logBuilder withFail:elementPositionToAddResult.fail
                           issue:ADJIssueStorageIo];
            [logBuilder withKey:@"metadata type"
                    stringValue:self.metadataTypeValue];
        }];

        return nil;
    }

    ADJNonNegativeInt *_Nonnull elementPositionToAdd = elementPositionToAddResult.value;

    if (elementPositionToAdd.uIntegerValue == 0) {
         self.metadataMap = readIoData.metadataMap;
         return elementPositionToAdd;
     }

    ADJResult<id> *lastReadElementResult = [self concreteGenerateElementFromIoData:readIoData];
    if (lastReadElementResult.fail != nil) {
        [self.logger debugWithMessage:@"Cannot add element to memory queue"
                         builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
         {
            [logBuilder withFail:lastReadElementResult.fail
                           issue:ADJIssueStorageIo];
            [logBuilder withKey:@"element position"
                    stringValue:elementPositionToAddResult.value.description];
            [logBuilder withKey:@"metadata type"
                    stringValue:self.metadataTypeValue];
        }];

        return nil;
    }

    [self.inMemoryQueueByPosition setObject:lastReadElementResult.value
                                     forKey:elementPositionToAdd];
    [self.inMemoryPositionIndexSet addIndex:elementPositionToAdd.uIntegerValue];

    return elementPositionToAdd;
}

- (void)readFromSelectStatementIntoBuildingData:(nonnull ADJSQLiteStatement *)selectStatement
                                  ioDataBuilder:(nonnull ADJIoDataBuilder *)ioDataBuilder
{
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
    self.lastElementPosition = [[self maxPositionCounter] generateIncrementedCounter];
    return self.lastElementPosition.countValue;
}

- (nonnull ADJTallyCounter *)maxPositionCounter {
    BOOL isQueueEmpty = [self isEmpty];
    BOOL isPositionIndexEmpty = self.inMemoryPositionIndexSet.lastIndex == NSNotFound;
    BOOL isPositionIndexWithinLastElementPosition =
        self.inMemoryPositionIndexSet.lastIndex
        <= self.lastElementPosition.countValue.uIntegerValue;

    if (isQueueEmpty || isPositionIndexEmpty || isPositionIndexWithinLastElementPosition) {
        return self.lastElementPosition;
    } else {
        return [[ADJTallyCounter alloc] initWithCountValue:
                [[ADJNonNegativeInt alloc] initWithUIntegerValue:
                 self.inMemoryPositionIndexSet.lastIndex]];
    }
}

- (void)addElementToStorage:(nonnull id)newElement
         newElementPosition:(nonnull ADJNonNegativeInt *)newElementPosition
        sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.storageExecutor executeInSequenceWithLogger:self.logger
                                                     from:@"add element to storage"
                                                    block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
            return;
        }

        [strongSelf addElementToSqliteDb:[strongSelf.sqliteDatabaseProvider sqliteDb]
                              newElement:newElement
                      newElementPosition:newElementPosition
                     sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)addElementToSqliteDb:(nonnull ADJSQLiteDb *)sqliteDb
                  newElement:(nonnull id)newElement
          newElementPosition:(nonnull ADJNonNegativeInt *)newElementPosition
         sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    [sqliteDb beginTransaction];

    BOOL addWasSuccessful =
        [self addElementInTransactionToSqliteDb:sqliteDb
                                     newElement:newElement
                             newElementPosition:newElementPosition];

    if (! addWasSuccessful) {
        [sqliteDb rollback];
        [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
        return;
    }

    if (sqliteStorageAction != nil) {
        if (! [sqliteStorageAction performStorageActionInDbTransaction:sqliteDb
                                                                logger:self.logger])
        {
            [self.logger debugDev:
             @"Cannot add element by position in storage with failed storage action"
                        issueType:ADJIssueStorageIo];
            [sqliteDb rollback];
            return;
        }
    }

    [sqliteDb commit];
    [self.logger debugDev:@"Element added to database"];
}
- (BOOL)addElementInTransactionToSqliteDb:(nonnull ADJSQLiteDb *)sqliteDb
                               newElement:(nonnull id)newElement
                       newElementPosition:(nonnull ADJNonNegativeInt *)newElementPosition
{
    ADJSQLiteStatement *_Nullable insertStatement =
        [sqliteDb prepareStatementWithSqlString:self.insertSql.stringValue];

    if (insertStatement == nil) {
        [self.logger debugDev:
         @"Cannot add element by position in storage without a compiled insertStatement"
                    issueType:ADJIssueStorageIo];
        return NO;
    }

    ADJIoData *_Nonnull newElementIoData =
        [self generateIoDataFromElement:newElement
                     newElementPosition:newElementPosition];

    BOOL insertSuccess =
        [self insertElementWithStatement:insertStatement
                        newElementIoData:newElementIoData
                      newElementPosition:newElementPosition];

    [insertStatement closeStatement];
    return insertSuccess;
}
- (nonnull ADJIoData *)generateIoDataFromElement:(nonnull id)newElement
                              newElementPosition:(nonnull ADJNonNegativeInt *)newElementPosition
{
    if (newElementPosition.uIntegerValue != 0) {
        return [self concreteGenerateIoDataFromElement:newElement];;
    }

    ADJIoDataBuilder *_Nonnull ioDataBuilder =
        [[ADJIoDataBuilder alloc] initWithMetadataTypeValue:self.metadataTypeValue];

    if (! [newElement isKindOfClass:[ADJStringMap class]]) {
        [self.logger debugDev:@"Element at position 0 should be a metadata string map"
                    issueType:ADJIssueLogicError];
    } else {
        ADJStringMap *_Nonnull elementMetadataMap = (ADJStringMap *)newElement;
        [ioDataBuilder.metadataMapBuilder addAllPairsWithStringMap:elementMetadataMap];
    }

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}
- (BOOL)insertElementWithStatement:(nonnull ADJSQLiteStatement *)insertStatement
                  newElementIoData:(nonnull ADJIoData *)newElementIoData
                newElementPosition:(nonnull ADJNonNegativeInt *)newElementPosition
{
    BOOL allSuccess = YES;
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

            allSuccess =
                [insertStatement executeUpdatePreparedStatementWithLogger:self.logger]
                && allSuccess;
        }
    }
    return allSuccess;
}

- (void)removeElementByPosition:(nonnull ADJNonNegativeInt *)elementPositionToRemove
                       sqliteDb:(nonnull ADJSQLiteDb *)sqliteDb
            sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    [sqliteDb beginTransaction];

    BOOL elementDeleted = [self removeElementByPositionInTransaction:elementPositionToRemove
                                                            sqliteDb:sqliteDb];

    if (sqliteStorageAction != nil
        && ! [sqliteStorageAction performStorageActionInDbTransaction:sqliteDb
                                                               logger:self.logger])
    {
        [self.logger debugDev:
         @"Cannot remove element by position in storage with failed storage action"
                    issueType:ADJIssueStorageIo];
        [sqliteDb rollback];
        return;
    }

    if (elementDeleted) {
        [sqliteDb commit];
    } else {
        [sqliteDb rollback];
    }
}

@end

