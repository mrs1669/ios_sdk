//
//  ADJGdprForgetStateStorage.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGdprForgetStateStorage.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kGdprForgetStateStorageTableName = @"gdpr_forget_state";

@implementation ADJGdprForgetStateStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"GdprForgetStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kGdprForgetStateStorageTableName
                      metadataTypeValue:ADJGdprForgetStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJGdprForgetStateData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nonnull ADJResult<ADJGdprForgetStateData *> *)
    concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData
{
    return [ADJGdprForgetStateData instanceFromIoData:ioData];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJGdprForgetStateData *)dataValue {
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
    ADJGdprForgetStateData *_Nullable stateDataFromUserDefaults =
        [ADJGdprForgetStateData instanceFromV4WithUserDefaults:v4UserDefaultsData];
    if (stateDataFromUserDefaults != nil) {
        [self.logger debugDev:@"GDPR forget found in v4 user defaults"];
        [self updateWithNewDataValue:stateDataFromUserDefaults];
        return;
    }

    [self.logger debugDev:@"GDPR forget not found in v4 user defaults"];

    ADJV4ActivityState *_Nullable v4ActivityState = [v4FilesData v4ActivityState];
    if (v4ActivityState == nil) {
        return;
    }

    ADJGdprForgetStateData *_Nullable stateDataFromActivityState =
        [ADJGdprForgetStateData instanceFromV4WithActivityState:v4ActivityState];

    if (stateDataFromActivityState == nil) {
        [self.logger debugDev:@"GDPR forget not found in v4 activity state"];
        return;
    }

    [self.logger debugDev:@"GDPR forget found in v4 activity state"];

    [self updateWithNewDataValue:stateDataFromActivityState];
}

@end
