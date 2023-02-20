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
                                 source:@"PushTokenStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kPushTokenStateTableName
                      metadataTypeValue:ADJPushTokenStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJPushTokenStateData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nullable ADJPushTokenStateData *)concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData {
    return [ADJPushTokenStateData instanceFromIoData:ioData
                                              logger:self.logger];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJPushTokenStateData *)dataValue {
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
        [self.logger debugDev:@"Activity state v4 file not found"];
        return;
    }

    [self.logger debugDev:@"Read v4 activity state"
                      key:@"activity_state"
                    value:[v4ActivityState description]];
    ADJNonEmptyString *_Nullable v4PushTokenString =

    [ADJNonEmptyString instanceFromOptionalString:v4ActivityState.pushToken
                                sourceDescription:@"v4 push token"
                                           logger:self.logger];

    ADJPushTokenStateData *_Nonnull v4PushTokenData =
    [[ADJPushTokenStateData alloc] initWithPushTokenString:v4PushTokenString];

    [self updateWithNewDataValue:v4PushTokenData];
}

@end

