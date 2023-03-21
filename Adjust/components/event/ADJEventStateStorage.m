//
//  ADJEventStateStorage.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJEventStateStorage.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kEventStateStorageTableName = @"event_state";

@implementation ADJEventStateStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"EventStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kEventStateStorageTableName
                      metadataTypeValue:ADJEventStateDataMetadataTypeValue
                initialDefaultDataValue:[[ADJEventStateData alloc] initWithIntialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nonnull ADJResultNN<ADJEventStateData *> *)
    concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData
{
    return [ADJEventStateData instanceFromIoData:ioData];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJEventStateData *)dataValue {
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
    ADJOptionalFailsNL<ADJEventStateData *> *_Nonnull eventStateDataOptFails =
        [ADJEventStateData instanceFromV4WithActivityState:[v4FilesData v4ActivityState]];
    for (ADJResultFail *_Nonnull optionalFail in eventStateDataOptFails.optionalFails) {
        [self.logger debugDev:@"Could not parse value for v4 event"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    if (eventStateDataOptFails.value == nil) {
        return;
    }

    [self updateWithNewDataValue:eventStateDataOptFails.value];
}

@end
