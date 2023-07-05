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
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
{
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"AsaAttributionStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kAsaAttributionStateStorageTableName
                      metadataTypeValue:ADJAsaAttributionStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJAsaAttributionStateData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nonnull ADJResult<ADJAsaAttributionStateData *> *)concreteGenerateValueFromIoData:
    (nonnull ADJIoData *)ioData
{
    ADJOptionalFails<ADJResult<ADJAsaAttributionStateData *> *> *_Nonnull resultOptFails =
        [ADJAsaAttributionStateData instanceFromIoData:ioData];

    for (ADJResultFail *_Nonnull optionalFail in resultOptFails.optionalFails) {
        [self.logger debugDev:@"Failed setting asa attribution state data optional field"
         " when generating value from io data"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    return resultOptFails.value;
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
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData
{
    ADJAsaAttributionStateData *_Nullable stateData =
        [ADJAsaAttributionStateData instanceFromV4WithUserDefaults:v4UserDefaultsData];

    if (stateData == nil) {
        [self.logger debugDev:@"Asa attribution tracked not updated from v4 migration"];
        return;
    }

    [self.logger debugDev:@"Asa attribution tracked updated from v4 migration"];

    [self updateWithNewDataValue:stateData];
}

@end
