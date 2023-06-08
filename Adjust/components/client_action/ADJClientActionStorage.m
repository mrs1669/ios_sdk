//
//  ADJClientActionStorage.m
//  Adjust
//
//  Created by Genady Buchatsky on 29.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientActionStorage.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kClientActionStorageTableName = @"client_action";

@implementation ADJClientActionStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"ClientActionStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kClientActionStorageTableName
                      metadataTypeValue:ADJClientActionDataMetadataTypeValue];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStorageQueueBase
- (nonnull ADJResult<ADJClientActionData *> *)concreteGenerateElementFromIoData:(nonnull ADJIoData *)ioData {
    return [ADJClientActionData instanceWithIoData:ioData];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromElement:(nonnull ADJClientActionData *)element {
    return element.ioData;
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
    // nothing to migrate from
}

@end

