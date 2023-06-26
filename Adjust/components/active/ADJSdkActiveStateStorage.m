//
//  ADJSdkActiveStateStorage.m
//  AdjustV5
//
//  Created by Pedro S. on 21.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJSdkActiveStateStorage.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kSdkActiveStateStorageTableName = @"sdk_active_state";

@implementation ADJSdkActiveStateStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
{
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"SdkActiveStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kSdkActiveStateStorageTableName
                      metadataTypeValue:ADJSdkActiveStateDataMetadataTypeValue
                initialDefaultDataValue:
            [[ADJSdkActiveStateData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nonnull ADJResult<ADJSdkActiveStateData *> *)
    concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData
{
    return [ADJSdkActiveStateData instanceFromIoData:ioData];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJSdkActiveStateData *)dataValue {
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
    ADJSdkActiveStateData *_Nullable stateData =
        [ADJSdkActiveStateData instanceFromV4WithActivityState:[v4FilesData v4ActivityState]];

    if (stateData == nil) {
        return;
    }

    [self updateWithNewDataValue:stateData];
}

@end
