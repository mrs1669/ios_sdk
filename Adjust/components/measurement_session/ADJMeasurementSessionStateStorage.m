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
- (nonnull ADJResultNN<ADJMeasurementSessionStateData *> *)
    concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData
{
    ADJCollectionAndValue<ADJResultFail *, ADJResultNN<ADJMeasurementSessionStateData *> *> *_Nonnull
    resultWithOptionals = [ADJMeasurementSessionStateData instanceFromIoData:ioData];

    for (ADJResultFail *_Nonnull optionalFail in resultWithOptionals.collection) {
        [self.logger debugDev:@"Failed setting measurement session state data optional field"
         " when generating value from io data"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    return resultWithOptionals.value;
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
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    ADJV4ActivityState *_Nullable v4ActivityState = [v4FilesData v4ActivityState];
    if (v4ActivityState == nil) {
        [self.logger debugDev:@"Activity state v4 file not found"];
        return;
    }

    [self.logger debugDev:@"Read v4 activity state"
                      key:@"activity_state"
                    value:[v4ActivityState description]];

    ADJResultNN<ADJMeasurementSessionData *> *_Nonnull v4MeasurementSessionDataResult =
        [ADJMeasurementSessionData
         instanceFromExternalWithSessionCountNumberInt:v4ActivityState.sessionCountNumberInt
         lastActivityTimestampNumberDoubleSeconds:v4ActivityState.lastActivityNumberDouble
         sessionLengthNumberDoubleSeconds:v4ActivityState.sessionLengthNumberDouble
         timeSpentNumberDoubleSeconds:v4ActivityState.timeSpentNumberDouble];
    if (v4MeasurementSessionDataResult.fail != nil) {
        [self.logger debugDev:@"Cannot convert v4 session data"
                   resultFail:v4MeasurementSessionDataResult.fail
                    issueType:ADJIssueStorageIo];
        return;
    }

    ADJMeasurementSessionStateData *_Nullable v4MeasurementSessionStateData =
        [[ADJMeasurementSessionStateData alloc] initWithMeasurementSessionData:
         v4MeasurementSessionDataResult.value];

    [self updateWithNewDataValue:v4MeasurementSessionStateData];
}

@end
