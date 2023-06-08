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
- (nonnull ADJResult<ADJLogPackageData *> *)concreteGenerateElementFromIoData:
    (nonnull ADJIoData *)ioData
{
    ADJResult<ADJSdkPackageBaseData *> *_Nonnull sdkPackageDataResult =
        [ADJSdkPackageBaseData instanceFromIoData:ioData];
    if (sdkPackageDataResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Could not parse sdk package data from io data for an expected log package"
                                      key:@"sdkPackageData fail"
                                otherFail:sdkPackageDataResult.fail];
    }

    if (! [sdkPackageDataResult.value isKindOfClass:[ADJLogPackageData class]]) {
        return [ADJResult
                failWithMessage:@"Unexpected non log package"
                key:@"package read short description"
                stringValue:[sdkPackageDataResult.value generateShortDescription].stringValue];
    }

    return (ADJResult<ADJLogPackageData *> *)sdkPackageDataResult;
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromElement:(nonnull ADJLogPackageData *)element {
    return [element toIoData];
}

#pragma mark Public API
#pragma mark - ADJSQLiteStorage
- (nullable NSString *)sqlStringForOnUpgrade:(nonnull ADJNonNegativeInt *)oldVersion {
    // nothing to upgrade from (yet)
    return nil;
}

- (void)migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    // nothing to migrate
}

@end


