//
//  ADJAdidStateStorage.m
//  Adjust
//
//  Created by Pedro Silva on 13.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJAdidStateStorage.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kAdidStateStorageTableName = @"adid_state";

@implementation ADJAdidStateStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
{
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"AdidStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kAdidStateStorageTableName
                      metadataTypeValue:ADJAdidStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJAdidStateData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nonnull ADJResult<ADJAdidStateData *> *)
    concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData
{
    return [ADJAdidStateData instanceFromIoData:ioData];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJAdidStateData *)dataValue {
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
    ADJAdidStateData *_Nullable adidStateData =
    [self adidStateFromV4WithActivityState:[v4FilesData v4ActivityState]];

    if (adidStateData == nil) {
        return;
    }

    [self updateWithNewDataValue:adidStateData];
}

- (nullable ADJAdidStateData *)
    adidStateFromV4WithActivityState:(nullable ADJV4ActivityState *)v4ActivityState
{
    if (v4ActivityState == nil) {
        return nil;
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull adidResult =
    [ADJNonEmptyString instanceFromString:v4ActivityState.adid];

    if (adidResult.failNonNilInput != nil) {
        [self.logger debugDev:@"Invalid adid from v4 activity state"
                   resultFail:adidResult.fail
                    issueType:ADJIssueStorageIo];
    }

    if (adidResult.value == nil) {
        return nil;
    }

    return [[ADJAdidStateData alloc] initWithAdid:adidResult.value];
}

@end

