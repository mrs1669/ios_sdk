//
//  ADJEventStateStorage.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJEventStateStorage.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kEventStateStorageTableName = @"event_state";

@implementation ADJEventStateStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
{
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"EventStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kEventStateStorageTableName
                      metadataTypeValue:ADJEventStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJEventStateData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nonnull ADJResult<ADJEventStateData *> *)
    concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData
{
    return [ADJEventStateData instanceFromIoData:ioData];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJEventStateData *)dataValue {
    return [dataValue toIoData];
}

#pragma mark Public API
#pragma mark - ADJSQLiteStorage
- (nullable NSString *)sqlStringForOnUpgrade:(nonnull ADJNonNegativeInt *)oldVersion {
    // nothing to upgrade from (yet)
    return nil;
}

- (void)migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData
{
    ADJEventStateData *_Nullable eventStateData =
        [self eventStateFromV4WithActivityState:[v4FilesData v4ActivityState]];

    if (eventStateData == nil) {
        return;
    }

    [self updateWithNewDataValue:eventStateData];
}

- (nullable ADJEventStateData *)
    eventStateFromV4WithActivityState:(nullable ADJV4ActivityState *)v4ActivityState
{
    if (v4ActivityState == nil) {
        return nil;
    }

    ADJResult<ADJNonNegativeInt *> *_Nonnull eventCountIntResult =
        [ADJNonNegativeInt instanceFromIntegerNumber:v4ActivityState.eventCountNumberInt];

    if (eventCountIntResult.failNonNilInput != nil) {
        [self.logger debugDev:@"Invalid event count from v4 activity state"
                   resultFail:eventCountIntResult.fail
                    issueType:ADJIssueStorageIo];
    }

    if (eventCountIntResult.value == nil) {
        return nil;
    }

    return [[ADJEventStateData alloc]
            initWithEventCount:
                [[ADJTallyCounter alloc] initWithCountValue:eventCountIntResult.value]];
}

@end
