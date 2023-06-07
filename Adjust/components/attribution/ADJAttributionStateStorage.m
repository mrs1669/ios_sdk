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
    ADJOptionalFailsNN<ADJResultNN<ADJAttributionStateData *> *> *_Nonnull
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
    ADJOptionalFailsNL<ADJAttributionStateData *> *_Nonnull stateDataOptFails =
        [ADJAttributionStateData instanceFromV4WithAttribution:[v4FilesData v4Attribution]];

    for (ADJResultFail *_Nonnull optionalFail in stateDataOptFails.optionalFails) {
        [self.logger debugDev:@"Could not parse value for v4 attribution"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    if (stateDataOptFails.value == nil) {
        return;
    }

    [self updateWithNewDataValue:stateDataOptFails.value];
}

@end
