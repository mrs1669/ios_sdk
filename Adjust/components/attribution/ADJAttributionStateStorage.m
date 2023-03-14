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
- (nonnull ADJResultNN<ADJAttributionStateData *> *)concreteGenerateValueFromIoData:
    (nonnull ADJIoData *)ioData
{
    ADJCollectionAndValue<ADJResultFail *, ADJResultNN<ADJAttributionStateData *> *> *_Nonnull
    resultWithOptionals = [ADJAttributionStateData instanceFromIoData:ioData];

    for (ADJResultFail *_Nonnull optionalFail in resultWithOptionals.collection) {
        [self.logger debugDev:@"Failed setting attribution state data optional field"
         " when generating value from io data"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    return resultWithOptionals.value;
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJAttributionStateData *)dataValue {
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
    ADJV4Attribution *_Nullable v4Attribution = [v4FilesData v4Attribution];
    if (v4Attribution == nil) {
        [self.logger debugDev:@"Attribution v4 file not found"];
        return;
    }

    [self.logger debugDev:@"Read v4 attribution"
                      key:@"attribution"
                    value:[v4Attribution description]];

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

    [self updateWithNewDataValue:
         [[ADJAttributionStateData alloc]
          initWithAttributionData:v4AttributionData
          installSessionTracked:YES
          unavailableAttribution:NO
          isAsking:NO]];
}

@end

