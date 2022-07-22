//
//  ADJMeasurementSessionStateStorage.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMeasurementSessionStateStorage.h"

#import "ADJUtilSys.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kMeasurementSessionStateStorageTableName = @"sdk_session_state";

@implementation ADJMeasurementSessionStateStorage
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
    sqliteController:(nonnull ADJSQLiteController *)sqliteController
{
     self = [super initWithLoggerFactory:loggerFactory
                                 source:@"MeasurementSessionStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kMeasurementSessionStateStorageTableName
                      metadataTypeValue:ADJMeasurementSessionStateDataMetadataTypeValue
                 initialDefaultDataValue:[[ADJMeasurementSessionStateData alloc] initWithIntialState]];
             /*
                    [[ADJMeasurementSessionStateData alloc] initWithIntialStateWithNewUuid:
                        [[ADJNonEmptyString alloc] initWithValidatedStringValue:
                            [ADJUtilSys generateUuid]]]];*/

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nullable ADJMeasurementSessionStateData *)concreteGenerateValueFromIoData:
    (nonnull ADJIoData *)ioData
{
    return [ADJMeasurementSessionStateData instanceFromIoData:ioData
                                                logger:self.logger];
}
- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:
    (nonnull ADJMeasurementSessionStateData *)dataValue
{
    return [dataValue toIoData];
}

#pragma mark Public API
#pragma mark - ADJSQLiteStorage
- (nullable NSString *)sqlStringForOnUpgrade:(int)oldVersion {
    // nothing to upgrade from (yet)
    return nil;
}

- (void)
    migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
    v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData
{
    ADJV4ActivityState *_Nullable v4ActivityState = [v4FilesData v4ActivityState];
    if (v4ActivityState == nil) {
        [self.logger debug:@"Activity state v4 file not found"];
        return;
    }

    [self.logger debug:@"Read v4 activity state: %@", v4ActivityState];

    ADJMeasurementSessionData *_Nullable v4MeasurementSessionData =
        [ADJMeasurementSessionData
             instanceFromExternalWithSessionCountNumberInt:v4ActivityState.sessionCountNumberInt
             lastActivityTimestampNumberDoubleSeconds:v4ActivityState.lastActivityNumberDouble
             sessionLengthNumberDoubleSeconds:v4ActivityState.sessionLengthNumberDouble
             timeSpentNumberDoubleSeconds:v4ActivityState.timeSpentNumberDouble
             logger:self.logger];

    ADJMeasurementSessionStateData *_Nullable v4MeasurementSessionStateData =
        [ADJMeasurementSessionStateData instanceFromExternalWithMeasurementSessionData:v4MeasurementSessionData
                                                                 logger:self.logger];

    if (v4MeasurementSessionStateData == nil) {
        return;
    }

    [self updateWithNewDataValue:v4MeasurementSessionStateData];
}

@end
