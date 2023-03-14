//
//  ADJAsaAttributionStateStorage.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAsaAttributionStateStorage.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kAsaAttributionStateStorageTableName = @"asa_attribution_state";

@implementation ADJAsaAttributionStateStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"AsaAttributionStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kAsaAttributionStateStorageTableName
                      metadataTypeValue:ADJAsaAttributionStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJAsaAttributionStateData alloc] initWithIntialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nonnull ADJResultNN<ADJAsaAttributionStateData *> *)concreteGenerateValueFromIoData:
    (nonnull ADJIoData *)ioData
{
    ADJCollectionAndValue<ADJResultFail *, ADJResultNN<ADJAsaAttributionStateData *> *> *_Nonnull
    resultWithOptionals = [ADJAsaAttributionStateData instanceFromIoData:ioData];

    for (ADJResultFail *_Nonnull optionalFail in resultWithOptionals.collection) {
        [self.logger debugDev:@"Failed setting asa attribution state data optional field"
         " when generating value from io data"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    return resultWithOptionals.value;
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJAsaAttributionStateData *)dataValue {
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
    NSNumber *_Nullable adServicesTrackedNumberBool = v4UserDefaultsData.adServicesTrackedNumberBool;

    if (adServicesTrackedNumberBool == nil || !adServicesTrackedNumberBool.boolValue) {
        [self.logger debugDev:@"Asa attribution tracked not found in v4 shared preferences"];
        return;
    }

    [self.logger debugDev:@"Asa attribution tracked found in v4 shared preferences"];

    ADJAsaAttributionStateData *_Nonnull initialStateData =
    [[ADJAsaAttributionStateData alloc] initWithIntialState];

    [self updateWithNewDataValue:[[ADJAsaAttributionStateData alloc]
                                  // overwrite only the received asa click flag
                                  initWithHasReceivedValidAsaClickResponse:YES
                                  hasReceivedAdjustAttribution:initialStateData.hasReceivedAdjustAttribution
                                  cachedToken:initialStateData.cachedToken
                                  cacheReadTimestamp:initialStateData.cacheReadTimestamp
                                  errorReason:initialStateData.errorReason]];
}

@end


