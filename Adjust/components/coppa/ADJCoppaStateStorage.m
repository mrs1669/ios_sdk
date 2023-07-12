//
//  ADJCoppaStateStorage.m
//  Adjust
//
//  Created by Pedro Silva on 28.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJCoppaStateStorage.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kCoppaStateStorageTableName = @"coppa_state";

@implementation ADJCoppaStateStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
{
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"CoppaStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kCoppaStateStorageTableName
                      metadataTypeValue:ADJCoppaStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJCoppaStateData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nonnull ADJResult<ADJCoppaStateData *> *)
    concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData
{
    return [ADJCoppaStateData instanceFromIoData:ioData];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJCoppaStateData *)dataValue {
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
    ADJV4ActivityState *_Nullable v4ActivityState = [v4FilesData v4ActivityState];
    if (v4ActivityState == nil) {
        return;
    }

    BOOL coppaNotEnabledInV4 = v4ActivityState.isThirdPartySharingDisabledForCoppaNumberBool == nil
        || ! v4ActivityState.isThirdPartySharingDisabledForCoppaNumberBool;

    if (coppaNotEnabledInV4) {
        return;
    }

    [self.logger debugDev:@"Enabled coppa state found in v4"];

    [self updateWithNewDataValue:
     [[ADJCoppaStateData alloc]initWithIsCoppaEnabled:[ADJBooleanWrapper instanceFromBool:YES]]];
}

@end

@implementation ADJCoppaStateStorageAction
#pragma mark Instantiation
- (nonnull instancetype)initWithCoppaStateStorage:(nonnull ADJCoppaStateStorage *)coppaStateStorage
                                   coppaStateData:(nonnull ADJCoppaStateData *)coppaStateData
{
    self = [super initWithPropertiesStorage:coppaStateStorage
                                       data:coppaStateData
               decoratedSQLiteStorageAction:nil];

    return self;
}

@end
