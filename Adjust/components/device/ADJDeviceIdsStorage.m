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
                                 source:@"DeviceIdsStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kDeviceIdsStorageTableName
                      metadataTypeValue:ADJDeviceIdsDataMetadataTypeValue
                initialDefaultDataValue:[[ADJDeviceIdsData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nullable ADJDeviceIdsData *)concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData {
    return [ADJDeviceIdsData instanceFromIoData:ioData
                                         logger:self.logger];
}
- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJDeviceIdsData *)dataValue {
    return [dataValue toIoData];
}

#pragma mark Public API
#pragma mark - ADJSQLiteStorage
- (nullable NSString *)sqlStringForOnUpgrade:(int)oldVersion {
    // nothing to upgrade from (yet)
    return nil;
}

- (void)migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    ADJV4ActivityState *_Nullable v4ActivityState = [v4FilesData v4ActivityState];
    if (v4ActivityState == nil) {
        [self.logger debug:@"Activity state v4 file not found"];
        return;
    }

    [self.logger debug:@"Read v4 activity state: %@", v4ActivityState];

    ADJNonEmptyString *_Nullable v4Uuid =
    [ADJNonEmptyString instanceFromOptionalString:v4ActivityState.uuid
                                sourceDescription:@"v4 uuid"
                                           logger:self.logger];

    ADJDeviceIdsData *_Nonnull v4DeviceIdsData =
    [[ADJDeviceIdsData alloc] initWithUuid:v4Uuid];

    [self updateWithNewDataValue:v4DeviceIdsData];
}

@end


