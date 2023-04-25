//
//  ADJPushTokenStateStorage.m
//  Adjust
//
//  Created by Aditi Agrawal on 13/02/23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJPushTokenStateStorage.h"

#import "ADJUtilSys.h"
#import "ADJMeasurementSessionStateData.h"
#import "ADJMeasurementSessionData.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kPushTokenStateTableName = @"push_token_state";

@implementation ADJPushTokenStateStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"PushTokenStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kPushTokenStateTableName
                      metadataTypeValue:ADJPushTokenStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJPushTokenStateData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nonnull ADJResult<ADJPushTokenStateData *> *)
    concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData
{
    return [ADJPushTokenStateData instanceFromIoData:ioData];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJPushTokenStateData *)dataValue {
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
              stringValue:[v4ActivityState description]];

    ADJOptionalFailsNL<ADJPushTokenStateData *> *_Nonnull stateDataOptFails =
        [ADJPushTokenStateData instanceFromExternalWithPushTokenString:v4ActivityState.pushToken];
    for (ADJResultFail *_Nonnull optionalFail in stateDataOptFails.optionalFails) {
        [self.logger debugDev:@"Could not parse value for v4 push token"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    if (stateDataOptFails.value == nil) {
        [self.logger debugDev:@"Did not find valid v4 push token to migrate"];
        return;
    }

    [self updateWithNewDataValue:stateDataOptFails.value];
}

@end
