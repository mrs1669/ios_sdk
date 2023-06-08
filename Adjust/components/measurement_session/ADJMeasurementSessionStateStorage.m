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
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
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
- (nonnull ADJResult<ADJMeasurementSessionStateData *> *)
    concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData
{
    ADJOptionalFailsNN<ADJResult<ADJMeasurementSessionStateData *> *> *_Nonnull
    resultDataOptFails = [ADJMeasurementSessionStateData instanceFromIoData:ioData];

    for (ADJResultFail *_Nonnull optionalFail in resultDataOptFails.optionalFails) {
        [self.logger debugDev:@"Failed setting measurement session state data optional field"
         " when generating value from io data"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    return resultDataOptFails.value;
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue: (nonnull ADJMeasurementSessionStateData *)dataValue {
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
    ADJResult<ADJMeasurementSessionStateData *> *_Nonnull sessionStateDataResult =
        [ADJMeasurementSessionStateData instanceFromV4WithActivityState:
         [v4FilesData v4ActivityState]];

    if (sessionStateDataResult.wasInputNil) {
        return;
    }

    if (sessionStateDataResult.fail != nil) {
        [self.logger debugDev:@"Cannot migrate measurement session from v4"
                   resultFail:sessionStateDataResult.fail
                    issueType:ADJIssueStorageIo];
        return;
    }

    [self updateWithNewDataValue:sessionStateDataResult.value];
}

@end
