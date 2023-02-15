//
//  ADJLogQueueStorage.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLogQueueStorage.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kLogQueueStorageTableName = @"log_queue";

@implementation ADJLogQueueStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"LogQueueStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kLogQueueStorageTableName
                      metadataTypeValue:ADJSdkPackageDataMetadataTypeValue];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStorageQueueBase
- (nullable ADJLogPackageData *)concreteGenerateElementFromIoData:(nonnull ADJIoData *)ioData {
    id<ADJSdkPackageData> _Nullable sdkPackageData =
    [ADJSdkPackageBaseData instanceFromIoData:ioData logger:self.logger];

    if (sdkPackageData == nil) {
        return nil;
    }

    if (! [sdkPackageData isKindOfClass:[ADJLogPackageData class]]) {
        [self.logger debugDev:@"Unexpected non log package data"
                          key:@"package read"
                        value:[sdkPackageData generateShortDescription].stringValue
                    issueType:ADJIssueStorageIo];
        return nil;
    }

    return (ADJLogPackageData *)sdkPackageData;
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromElement:(nonnull ADJLogPackageData *)element {
    return [element toIoData];
}

#pragma mark Public API
#pragma mark - ADJSQLiteStorage
- (nullable NSString *)sqlStringForOnUpgrade:(int)oldVersion {
    // nothing to upgrade from (yet)
    return nil;
}

- (void)migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    // nothing to migrate
}

@end


