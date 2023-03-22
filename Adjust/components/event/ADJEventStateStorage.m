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
- (nullable ADJEventStateData *)concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData {
    return [ADJEventStateData instanceFromIoData:ioData
                                          logger:self.logger];
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
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    ADJV4ActivityState *_Nullable v4ActivityState = [v4FilesData v4ActivityState];
    if (v4ActivityState == nil) {
        [self.logger debugDev:@"Activity state v4 file not found"];
        return;
    }

    if (v4ActivityState.eventCountNumberInt == nil) {
        [self.logger debugDev:@"Cannot find event count in v4 activity state"];
        return;
    }

    ADJEventStateData *_Nullable eventStateData =
    [ADJEventStateData instanceFromExternalWithEventCountNumberInt:v4ActivityState.eventCountNumberInt
                                                            logger:self.logger];
    if (eventStateData == nil) {
        return;
    }

    [self updateWithNewDataValue:eventStateData];
}

@end

