//
//  ADJAttributionStateStorage.m
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAttributionStateStorage.h"

#import "ADJUtilSys.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kAttributionStateStorageTableName = @"attribution_state";

@implementation ADJAttributionStateStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"AttributionStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kAttributionStateStorageTableName
                      metadataTypeValue:ADJAttributionStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJAttributionStateData alloc] initWithIntialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nullable ADJAttributionStateData *)concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData {
    return [ADJAttributionStateData instanceFromIoData:ioData
                                                logger:self.logger];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJAttributionStateData *)dataValue {
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
    ADJV4Attribution *_Nullable v4Attribution = [v4FilesData v4Attribution];
    if (v4Attribution == nil) {
        [self.logger debug:@"Attribution v4 file not found"];
        return;
    }

    [self.logger debug:@"Read v4 attribution: %@", v4Attribution];

    ADJAttributionData *_Nonnull v4AttributionData =
    [[ADJAttributionData alloc] initFromExternalDataWithLogger:self.logger
                                            trackerTokenString:v4Attribution.trackerToken
                                             trackerNameString:v4Attribution.trackerName
                                                 networkString:v4Attribution.network
                                                campaignString:v4Attribution.campaign
                                                 adgroupString:v4Attribution.adgroup
                                                creativeString:v4Attribution.creative
                                              clickLabelString:v4Attribution.clickLabel
                                                    adidString:v4Attribution.adid
                                                costTypeString:v4Attribution.costType
                                        costAmountDoubleNumber:v4Attribution.costAmount
                                            costCurrencyString:v4Attribution.costCurrency];

    ADJAttributionStateData *_Nonnull intialAttributionStateData =
    [self readOnlyStoredDataValue];
    
    // TODO should state fields change because it was read from v4?
    [self updateWithNewDataValue:[[ADJAttributionStateData alloc]
                                  initWithAttributionData:v4AttributionData
                                  receivedSessionResponse:YES
                                  unavailableAttribution:intialAttributionStateData.unavailableAttribution
                                  askingFromSdk:intialAttributionStateData.askingFromSdk
                                  askingFromBackend:intialAttributionStateData.askingFromBackend]];
}

@end

