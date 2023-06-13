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
                             loggerName:@"AttributionStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kAttributionStateStorageTableName
                      metadataTypeValue:ADJAttributionStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJAttributionStateData alloc] initWithIntialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nonnull ADJResult<ADJAttributionStateData *> *)concreteGenerateValueFromIoData:
    (nonnull ADJIoData *)ioData
{
    ADJOptionalFails<ADJResult<ADJAttributionStateData *> *> *_Nonnull
    attributionStateDataOptFails = [ADJAttributionStateData instanceFromIoData:ioData];

    for (ADJResultFail *_Nonnull optionalFail in attributionStateDataOptFails.optionalFails) {
        [self.logger debugDev:@"Failed setting attribution state data optional field"
         " when generating value from io data"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    return attributionStateDataOptFails.value;
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
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData
{
    ADJAttributionStateData *_Nullable attributionStateData =
        [self attributionStateFromV4:[v4FilesData v4Attribution]];

    if (attributionStateData == nil) {
        return;
    }

    [self updateWithNewDataValue:attributionStateData];
}

- (nullable ADJAttributionStateData *)
    attributionStateFromV4:(nullable ADJV4Attribution *)v4Attribution
{
    if (v4Attribution == nil) {
        return nil;
    }

    ADJAttributionData *_Nullable attributionData =
        [self attributionFromV4:v4Attribution];

    if (attributionData == nil) {
        return nil;
    }

    return [ADJAttributionStateData instanceFromMigratedV4Attribution:attributionData];
}

#define convV4String(field) \
    ADJResult<ADJNonEmptyString *> *_Nonnull field ## Result =      \
        [ADJNonEmptyString instanceFromString:v4Attribution.field]; \
    if (field ## Result.failNonNilInput != nil) {                   \
        [self.logger debugDev:@"Invalid field from v4 attribution"  \
                   resultFail:field ## Result.fail                  \
                  issueType:ADJIssueStorageIo];                     \
    }                                                               \
    if (field ## Result.value != nil) {     \
        hasAtLeastOneValidField = YES;      \
    }                                       \

- (nonnull ADJAttributionData *)attributionFromV4:(nonnull ADJV4Attribution *)v4Attribution {
    BOOL hasAtLeastOneValidField = NO;

    ADJResult<ADJMoneyDoubleAmount *> *_Nonnull costAmountDoubleResult =
        [ADJMoneyDoubleAmount instanceFromDoubleNumberValue:v4Attribution.costAmount];
    if (costAmountDoubleResult.failNonNilInput != nil) {
        [self.logger debugDev:@"Invalid cost amount from v4 attribution"
                   resultFail:costAmountDoubleResult.fail
                    issueType:ADJIssueStorageIo];
    }
    if (costAmountDoubleResult.value != nil) {
        hasAtLeastOneValidField = YES;
    }

    convV4String(trackerToken)
    convV4String(trackerName)
    convV4String(network)
    convV4String(campaign)
    convV4String(adgroup)
    convV4String(creative)
    convV4String(clickLabel)
    // TODO: adid to be extracted from attribution
    convV4String(adid)
    convV4String(costType)
    convV4String(costCurrency)

    if (! hasAtLeastOneValidField) {
        return nil;
    }

    return [[ADJAttributionData alloc]
            initWithTrackerToken:trackerTokenResult.value
            trackerName:trackerNameResult.value
            network:networkResult.value
            campaign:campaignResult.value
            adgroup:adgroupResult.value
            creative:creativeResult.value
            clickLabel:clickLabelResult.value
            // TODO: adid to be extracted from attribution
            adid:adidResult.value
            // deeplink and state not coming from v4
            // TODO: confirm that assumption is correct
            deeplink:nil
            state:nil
            costType:costTypeResult.value
            costAmount:costAmountDoubleResult.value
            costCurrency:costCurrencyResult.value];
}

@end
