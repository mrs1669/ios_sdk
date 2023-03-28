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
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"LaunchedDeeplinkStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kLaunchedDeeplinkStateTableName
                      metadataTypeValue:ADJLaunchedDeeplinkStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJLaunchedDeeplinkStateData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase

- (nullable ADJLaunchedDeeplinkStateData *)
concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData {
    return [ADJLaunchedDeeplinkStateData instanceFromIoData:ioData
                                                     logger:self.logger];
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

    [self.logger debugDev:@"Read v4 activity state"
                      key:@"activity_state"
                    value:[v4ActivityState description]];

    ADJNonEmptyString *_Nullable v4LaunchedDeeplink =
    [ADJNonEmptyString instanceFromOptionalString:v4ActivityState.pushToken
                                sourceDescription:@"v4 push token"
                                           logger:self.logger];
    if (v4LaunchedDeeplink == nil) {
        return;
    }

    ADJLaunchedDeeplinkStateData *_Nonnull v4LaunchedDeeplinkData =
    [[ADJLaunchedDeeplinkStateData alloc] initWithLaunchedDeeplink:v4LaunchedDeeplink];

    [self updateWithNewDataValue:v4LaunchedDeeplinkData];
}

@end

