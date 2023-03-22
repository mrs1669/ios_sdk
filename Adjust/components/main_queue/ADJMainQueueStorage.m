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
- (nullable id<ADJSdkPackageData>)concreteGenerateElementFromIoData:(nonnull ADJIoData *)ioData {
    return [ADJSdkPackageBaseData instanceFromIoData:ioData logger:self.logger];
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
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {

    NSArray *_Nullable v4ActivityPackageArray = [v4FilesData v4ActivityPackageArray];

    if (v4ActivityPackageArray == nil) {
        [self.logger debugDev:@"Activity Packages v4 file not found"];
        return;
    }

    [self.logger debugDev:@"Activity Packages v4 file found"
                      key:@"count"
                    value:[ADJUtilF uIntegerFormat:v4ActivityPackageArray.count]];

    for (id _Nullable activityPackageObject in v4ActivityPackageArray) {
        if (activityPackageObject == nil) {
            [self.logger debugDev:@"Cannot not add v4 package with nil object"];
            continue;
        }

        if (! [activityPackageObject isKindOfClass:[ADJV4ActivityPackage class]]) {
            [self.logger debugDev:@"Cannot not add v4 package that is not of expected class"];
            continue;
        }

        ADJV4ActivityPackage *_Nonnull v4ActivityPackage =
            (ADJV4ActivityPackage *)activityPackageObject;

        ADJNonEmptyString *_Nullable v4ClientSdk =
            [ADJNonEmptyString instanceFromString:v4ActivityPackage.clientSdk
                                sourceDescription:@"v4 Activity Package client sdk"
                                           logger:self.logger];
        if (v4ClientSdk == nil) {
            [self.logger debugDev:@"Cannot not add v4 package without client sdk"];
            continue;
        }

        ADJStringMap *_Nullable parameters =
            [self convertV4ParametersWithV4ActivityPackage:v4ActivityPackage];
        if (parameters == nil) {
            [self.logger debugDev:@"Cannot not add v4 package without parameters"];
            continue;
        }

        id<ADJSdkPackageData> _Nullable sdkPackageData =
            [self convertSdkPackageFromV4WithV4Path:v4ActivityPackage.path
                                        v4ClientSdk:v4ClientSdk
                                         parameters:parameters];
        if (sdkPackageData == nil) {
            [self.logger debugDev:@"Cannot not add v4 package that could not be converted"];
            continue;
        }

        [self.logger debugDev:@"Adding v4 package that could be converted"];

        [self enqueueElementToLast:sdkPackageData sqliteStorageAction:nil];
    }
}

#pragma mark Internal Methods
- (nullable ADJStringMap *)convertV4ParametersWithV4ActivityPackage:(nonnull ADJV4ActivityPackage *)v4ActivityPackage {

    if (v4ActivityPackage.parameters == nil || v4ActivityPackage.parameters.count == 0) {
        return nil;
    }

    ADJStringMapBuilder *_Nonnull parametersBuilder = [[ADJStringMapBuilder alloc] initWithEmptyMap];

    for (NSString *key in v4ActivityPackage.parameters) {
        ADJNonEmptyString *_Nullable verifiedKey = [ADJNonEmptyString instanceFromString:key
                                                                       sourceDescription:@"v4 activity package key"
                                                                                  logger:self.logger];
        if (verifiedKey == nil) {
            continue;
        }

        NSString *_Nullable value = [v4ActivityPackage.parameters objectForKey:key];

        ADJNonEmptyString *_Nullable verifiedValue = [ADJNonEmptyString instanceFromString:value
                                                                         sourceDescription:@"v4 activity package value"
                                                                                    logger:self.logger];
        if (verifiedValue == nil) {
            continue;
        }

        [parametersBuilder addPairWithValue:verifiedValue
                                        key:key];
    }

    return [[ADJStringMap alloc] initWithStringMapBuilder:parametersBuilder];
}

#define v4PathToPackage(v4PathConst, packageClass)                                      \
if ([v4Path isEqualToString:v4PathConst]) {                                         \
return [[packageClass alloc] initWithClientSdk:v4ClientSdk.stringValue          \
parameters:parameters];                     \
}

- (nullable ADJSdkPackageBaseData *)convertSdkPackageFromV4WithV4Path:(nullable NSString *)v4Path
                                                          v4ClientSdk:(nonnull ADJNonEmptyString *)v4ClientSdk
                                                           parameters:(nonnull ADJStringMap *)parameters {
    if (v4Path == nil) {
        return nil;
    }

    v4PathToPackage(ADJV4PurchasePath, ADJBillingSubscriptionPackageData)
    v4PathToPackage(ADJV4SessionPath, ADJSessionPackageData)
    v4PathToPackage(ADJV4EventPath, ADJEventPackageData)
    v4PathToPackage(ADJV4AdRevenuePath, ADJAdRevenuePackageData)
    v4PathToPackage(ADJV4InfoPath, ADJInfoPackageData)
    v4PathToPackage(ADJV4ThirdPartySharingPath, ADJThirdPartySharingPackageData)

    // there are no attribution, click or gdpr packages in v4 main queue

    if ([v4Path isEqualToString:ADJV4DisableThirdPartySharingPath]) {
        return [[ADJThirdPartySharingPackageData alloc]
                initV4DisableThirdPartySharingMigratedWithClientSdk:v4ClientSdk.stringValue
                parameters:parameters];
    }
    return nil;
}

@end

