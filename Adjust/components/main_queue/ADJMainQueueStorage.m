//
//  ADJMainQueueStorage.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMainQueueStorage.h"

#import "ADJSdkPackageBaseData.h"
#import "ADJV4ActivityPackage.h"
#import "ADJStringMap.h"
#import "ADJUtilF.h"
#import "ADJBillingSubscriptionPackageData.h"
#import "ADJSessionPackageData.h"
#import "ADJEventPackageData.h"
#import "ADJAdRevenuePackageData.h"
#import "ADJInfoPackageData.h"
#import "ADJThirdPartySharingPackageData.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kMainQueueStorageTableName = @"main_queue";

@implementation ADJMainQueueStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
{
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"MainQueueStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kMainQueueStorageTableName
                      metadataTypeValue:ADJSdkPackageDataMetadataTypeValue];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStorageQueueBase
- (nonnull ADJResult<id<ADJSdkPackageData>> *)concreteGenerateElementFromIoData:
    (nonnull ADJIoData *)ioData
{
    ADJResult<ADJSdkPackageBaseData *> *_Nonnull sdkPackageDataResult =
        [ADJSdkPackageBaseData instanceFromIoData:ioData];
    if (sdkPackageDataResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Could not parse sdk package data from io data for the main queue"
                                        key:@"sdkPackageData fail"
                                  otherFail:sdkPackageDataResult.fail];
    }

    return (ADJResult<id<ADJSdkPackageData>> *)sdkPackageDataResult;
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromElement:(nonnull id<ADJSdkPackageData>)element {
    return [element toIoData];
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
    ADJOptionalFailsNL<NSArray<id<ADJSdkPackageData>> *> *_Nonnull packageArrayOptFails =
        [ADJSdkPackageBaseData instanceArrayFromV4WithActivityPackageArray:
         [v4FilesData v4ActivityPackageArray]];

    for (ADJResultFail *_Nonnull optionalFail in packageArrayOptFails.optionalFails) {
        [self.logger debugDev:@"Could not parse value for v4 activity package migration"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    if (packageArrayOptFails.value == nil) {
        return;
    }

    for (id<ADJSdkPackageData> _Nonnull sdkPackageData in packageArrayOptFails.value) {
        [self enqueueElementToLast:sdkPackageData sqliteStorageAction:nil];
    }
}

@end
