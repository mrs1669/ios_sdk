//
//  ADJDeviceIdsStorage.m
//  Adjust
//
//  Created by Pedro S. on 23.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJDeviceIdsStorage.h"

#import "ADJUtilSys.h"
#import "ADJMeasurementSessionStateData.h"
#import "ADJMeasurementSessionData.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kDeviceIdsStorageTableName = @"device_ids";

@implementation ADJDeviceIdsStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"DeviceIdsStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kDeviceIdsStorageTableName
                      metadataTypeValue:ADJDeviceIdsDataMetadataTypeValue
                initialDefaultDataValue:[[ADJDeviceIdsData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nonnull ADJResult<ADJDeviceIdsData *> *)concreteGenerateValueFromIoData:
    (nonnull ADJIoData *)ioData
{
    return [ADJDeviceIdsData instanceFromIoData:ioData];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJDeviceIdsData *)dataValue {
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
    ADJResult<ADJDeviceIdsData *> *_Nonnull deviceIdsDataResult =
        [ADJDeviceIdsData instanceFromV4WithActivityState:[v4FilesData v4ActivityState]];
    if (deviceIdsDataResult.wasInputNil) {
        return;
    }
    if (deviceIdsDataResult.fail != nil) {
        [self.logger debugDev:@"Cannot migrate v4 device ids"
                   resultFail:deviceIdsDataResult.fail
                    issueType:ADJIssueStorageIo];

        return;
    }

    [self updateWithNewDataValue:deviceIdsDataResult.value];
}

@end
