//
//  ADJLaunchedDeeplinkStateStorage.m
//  Adjust
//
//  Created by Aditi Agrawal on 27/03/23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJLaunchedDeeplinkStateStorage.h"

#import "ADJUtilSys.h"
#import "ADJMeasurementSessionStateData.h"
#import "ADJMeasurementSessionData.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kLaunchedDeeplinkStateTableName = @"launched_deeplink_state";

@implementation ADJLaunchedDeeplinkStateStorage

#pragma mark Instantiation

- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
{
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"LaunchedDeeplinkStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kLaunchedDeeplinkStateTableName
                      metadataTypeValue:ADJLaunchedDeeplinkStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJLaunchedDeeplinkStateData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nonnull ADJResult<ADJLaunchedDeeplinkStateData *> *)
    concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData
{
    return [ADJLaunchedDeeplinkStateData instanceFromIoData:ioData];
}

- (nonnull ADJIoData *)
concreteGenerateIoDataFromValue:(nonnull ADJLaunchedDeeplinkStateData *)dataValue {
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

    ADJResult<ADJNonEmptyString *> *_Nonnull v4LaunchedDeeplinkResult =
        [ADJNonEmptyString instanceFromString:v4ActivityState.launchedDeeplink];

    if (v4LaunchedDeeplinkResult.failNonNilInput != nil) {
        [self.logger debugDev:@"Invalid v4 lauched deeplink detected"
                   resultFail:v4LaunchedDeeplinkResult.fail
                    issueType:ADJIssueStorageIo];
    }
    if (v4LaunchedDeeplinkResult.value == nil) {
        return;
    }

    ADJLaunchedDeeplinkStateData *_Nonnull v4LaunchedDeeplinkData =
        [[ADJLaunchedDeeplinkStateData alloc]
         initWithLaunchedDeeplink:v4LaunchedDeeplinkResult.value];

    [self updateWithNewDataValue:v4LaunchedDeeplinkData];
}

@end

