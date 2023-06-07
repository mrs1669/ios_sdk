//
//  ADJDeviceController.m
//  Adjust
//
//  Created by Pedro S. on 16.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJDeviceController.h"

#import <UIKit/UIKit.h>
#import "ADJAtomicBoolean.h"
#import "ADJUtilSys.h"
#import "ADJUtilF.h"
#import "ADJSessionDeviceIdsController.h"
#import "ADJRelativeTimestamp.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJDeviceInfoData *deviceInfoData;
 */

#pragma mark - Private constants
static NSString *const kUuidKey = @"adjust_uuid";
static NSString *const kKeychainServiceKey = @"deviceInfo";

@interface ADJDeviceController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJClock *clockWeak;
@property (nullable, readonly, weak, nonatomic) ADJDeviceIdsStorage *deviceIdsStorageWeak;
@property (nonnull, readonly, strong, nonatomic) ADJExternalConfigData *deviceIdsConfigData;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSessionDeviceIdsController *sessionDeviceIdsController;
@property (nullable, readwrite, strong, nonatomic) ADJNonEmptyString *uuidKeychainCache;
@property (nullable, readwrite, strong, nonatomic) ADJRelativeTimestamp *backgroundTimestamp;

@end

@implementation ADJDeviceController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                        threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
                                        clock:(nonnull ADJClock *)clock
                             deviceIdsStorage:(nonnull ADJDeviceIdsStorage *)deviceIdsStorage
                              keychainStorage:(nonnull ADJKeychainStorage *)keychainStorage
                          deviceIdsConfigData:(nonnull ADJExternalConfigData *)deviceIdsConfigData {
    self = [super initWithLoggerFactory:loggerFactory source:@"DeviceController"];
    _clockWeak = clock;
    _deviceIdsStorageWeak = deviceIdsStorage;
    _deviceIdsConfigData = deviceIdsConfigData;

    _deviceInfoData = [[ADJDeviceInfoData alloc] initWithLogger:self.logger];

    _sessionDeviceIdsController =
        [[ADJSessionDeviceIdsController alloc]
         initWithLoggerFactory:loggerFactory
         threadExecutorFactory:threadExecutorFactory
         timeoutPerAttempt:deviceIdsConfigData.timeoutPerAttempt
         canCacheData:deviceIdsConfigData.cacheValidityPeriod != nil];

    _uuidKeychainCache =
    [ADJDeviceController syncUuidAndGetUuidKeychainWithLogger:self.logger
                                             deviceIdsStorage:deviceIdsStorage
                                              keychainStorage:keychainStorage];

    _backgroundTimestamp = nil;

    return self;
}

#pragma mark Public API
- (nullable ADJNonEmptyString *)keychainUuid {
    return self.uuidKeychainCache;
}

- (nullable ADJNonEmptyString *)nonKeychainUuid {
    ADJDeviceIdsStorage *_Nullable deviceIdsStorage = self.deviceIdsStorageWeak;
    if (deviceIdsStorage == nil) {
        return nil;
    }

    return [deviceIdsStorage readOnlyStoredDataValue].uuid;
}

- (nonnull ADJResultNN<ADJSessionDeviceIdsData *> *)getSessionDeviceIdsSync {
    return [self.sessionDeviceIdsController getSessionDeviceIdsSync];
}

#pragma mark - ADJLifecycleSubscriber
- (void)ccDidForeground {
    if (self.deviceIdsConfigData.cacheValidityPeriod == nil) {
        [self.logger debugDev:@"There is no cache lifecycle configured to handle at foreground"];

        return;
    }

    if ([self.deviceIdsConfigData.cacheValidityPeriod isZero]) {
        [self.logger debugDev:@"Cache is invalidated with 0 cached timeLength"];
        [self.sessionDeviceIdsController invalidateCache];
        return;
    }

    ADJRelativeTimestamp *backgroundTimestampLocal = self.backgroundTimestamp;
    self.backgroundTimestamp = nil;

    if (backgroundTimestampLocal == nil) {
        [self.logger debugDev:@"Cache cannot be invalidated without a background timestamp"];
        return;
    }

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger debugDev:@"Cache cannot be invalidated without a reference to clock"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJRelativeTimestamp *_Nullable foregroundTimestamp = [clock monotonicRelativeTimestamp];
    if (foregroundTimestamp == nil) {
        [self.logger debugDev:@"Cache cannot be invalidated without a current timestamp"
                    issueType:ADJIssueWeakReference];
        return;
    }

    BOOL hasBackgroundCachedTimeLimitExpired =
    [foregroundTimestamp
     hasEnoughTimePassedSince:backgroundTimestampLocal
     enoughTimeLength:self.deviceIdsConfigData.cacheValidityPeriod];

    if (hasBackgroundCachedTimeLimitExpired) {
        [self.logger debugDev:
         @"Cache will be invalidated when enough time has passed in the background"];
        [self.sessionDeviceIdsController invalidateCache];
    } else {
        [self.logger debugDev:
         @"Cache cannot be invalidated when not enough time has passed in the background"];
    }
}

- (void)ccDidBackground {
    if (self.deviceIdsConfigData.cacheValidityPeriod == nil) {
        [self.logger debugDev:@"There is no cache lifecycle configured to handle at background"];
        return;
    }

    if ([self.deviceIdsConfigData.cacheValidityPeriod isZero]) {
        [self.logger debugDev:
         @"Background timestamp does not need to be taken with 0 cached timeLength"];
        return;
    }

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger debugDev:
         @"Background timestamp cannot be taken without a reference to clock"
                    issueType:ADJIssueWeakReference];
        return;
    }

    self.backgroundTimestamp = [clock monotonicRelativeTimestamp];
}

#pragma mark Internal Methods
+ (nullable ADJNonEmptyString *)syncUuidAndGetUuidKeychainWithLogger:(nonnull ADJLogger *)logger
                                                    deviceIdsStorage:(nonnull ADJDeviceIdsStorage *)deviceIdsStorage
                                                     keychainStorage:(nonnull ADJKeychainStorage *)keychainStorage {
    ADJNonEmptyString *_Nullable uuidKeychain =
    [keychainStorage valueInGenericPasswordKeychainWithKey:kUuidKey
                                                   service:kKeychainServiceKey];

    ADJNonEmptyString *_Nullable currentStorageUuid =
    [deviceIdsStorage readOnlyStoredDataValue].uuid;

    if (uuidKeychain != nil && currentStorageUuid != nil) {
        if ([currentStorageUuid isEqual:uuidKeychain]) {
            [logger debugDev:@"Uuid already sync between keychain and device ids storage"];
        } else {
            [logger debugDev:
             @"Detected different uuid between keychain and device ids storage,"
             " will overwrite from keychain to device ids storage"];
            [deviceIdsStorage updateWithNewDataValue:
             [[ADJDeviceIdsData alloc] initWithUuid:uuidKeychain]];
        }
        return uuidKeychain;
    }

    if (uuidKeychain != nil && currentStorageUuid == nil) {
        [logger debugDev:
         @"Detected uuid in keychain but not device ids storage,"
         " will write from keychain to device ids storage"];
        [deviceIdsStorage updateWithNewDataValue:
         [[ADJDeviceIdsData alloc] initWithUuid:uuidKeychain]];
        return uuidKeychain;
    }

    if (uuidKeychain == nil && currentStorageUuid != nil) {
        [logger debugDev:
         @"Detected uuid in device ids storage but not keychain,"
         " will write from device ids storage to keychain"];

        return [self setAndGetSavedUuidKeychainWithStorage:keychainStorage
                                                 uuidValue:currentStorageUuid];
    }

    [logger debugDev:
     @"Detected no uuid either in keychain or device ids storage, will write new one to both"];

    ADJNonEmptyString *_Nonnull newUuid = [ADJUtilSys generateUuid];

    [deviceIdsStorage updateWithNewDataValue:
     [[ADJDeviceIdsData alloc] initWithUuid:newUuid]];

    return [self setAndGetSavedUuidKeychainWithStorage:keychainStorage
                                             uuidValue:newUuid];
}

+ (nullable ADJNonEmptyString *)setAndGetSavedUuidKeychainWithStorage:(nonnull ADJKeychainStorage *)keychainStorage
                                                            uuidValue:(nonnull ADJNonEmptyString *)uuidValue {
    BOOL uuidWasSet =
    [keychainStorage setGenericPasswordKeychainWithKey:kUuidKey
                                               service:kKeychainServiceKey
                                                 value:uuidValue];

    if (uuidWasSet) {
        return uuidValue;
    } else {
        return nil;
    }
}

@end


