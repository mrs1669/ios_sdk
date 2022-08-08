//
//  ADJ5IadAttributionStateStorage.m
//  Adjust
//
//  Created by Pedro S. on 02.08.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//
/*
#import "ADJ5IadAttributionStateStorage.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kIadAttributionStateStorageTableName = @"iad_attribution_state";

@implementation ADJ5IadAttributionStateStorage
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJ5LoggerFactory>)loggerFactory
    storageExecutor:(nonnull ADJ5SingleThreadExecutor *)storageExecutor
    sqliteController:(nonnull ADJ5SQLiteController *)sqliteController
{
     self = [super initWithLoggerFactory:loggerFactory
                                 source:@"ADJ5IadAttributionStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kIadAttributionStateStorageTableName
                      metadataTypeValue:ADJ5IadAttributionStateDataMetadataTypeValue
                 initialDefaultDataValue:[[ADJ5IadAttributionStateData alloc] initWithIntialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJ5SQLiteStoragePropertiesBase
- (nullable ADJ5IadAttributionStateData *)concreteGenerateValueFromIoData:
    (nonnull ADJ5IoData *)ioData
{
    return [ADJ5IadAttributionStateData instanceFromIoData:ioData
                                                    logger:self.logger];
}
- (nonnull ADJ5IoData *)concreteGenerateIoDataFromValue:
    (nonnull ADJ5IadAttributionStateData *)dataValue
{
    return [dataValue toIoData];
}

#pragma mark Public API
#pragma mark - ADJ5SQLiteStorage
- (nullable NSString *)sqlStringForOnUpgrade:(int)oldVersion {
    // nothing to upgrade from (yet)
    return nil;
}

- (void)
    migrateFromV4WithV4FilesData:(nonnull ADJ5V4FilesData *)v4FilesData
    v4UserDefaultsData:(nonnull ADJ5V4UserDefaultsData *)v4UserDefaultsData
{
    // TODO
}

@end
*/
