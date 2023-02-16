//
//  ADJSessionDeviceIdsController.m
//  Adjust
//
//  Created by Pedro S. on 26.07.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJSessionDeviceIdsController.h"

#import <UIKit/UIKit.h>
#import "ADJValueWO.h"
#import "ADJUtilF.h"

@interface ADJSessionDeviceIdsController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *timeoutPerAttempt;
@property (readonly, assign, nonatomic) BOOL canCacheData;

#pragma mark - Internal variables
@property (nullable, readwrite, strong, nonatomic) ADJSessionDeviceIdsData *sessionDeviceIdsDataCached;
@property (nullable, readwrite, strong, nonatomic) ADJNonEmptyString *identifierForVendorCached;

@end

@implementation ADJSessionDeviceIdsController {
#pragma mark - Unmanaged variables
    volatile BOOL _canUseCacheData;
}

- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                        threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
                            timeoutPerAttempt:(nullable ADJTimeLengthMilli *)timeoutPerAttempt
                                 canCacheData:(BOOL)canCacheData {
    self = [super initWithLoggerFactory:loggerFactory source:@"SessionDeviceIdsController"];
    _executor = [threadExecutorFactory createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                                 sourceDescription:self.source];
    _timeoutPerAttempt = timeoutPerAttempt;
    _canCacheData = canCacheData;

    _sessionDeviceIdsDataCached = nil;
    _identifierForVendorCached = nil;

    _canUseCacheData = NO;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (void)invalidateCache {
    _canUseCacheData = NO;
}

- (nonnull ADJSessionDeviceIdsData *)getSessionDeviceIdsSync {
    if (_canUseCacheData) {
        return self.sessionDeviceIdsDataCached;
    }

    if (self.timeoutPerAttempt == nil) {
        return [[ADJSessionDeviceIdsData alloc]
                initWithFailMessage:@"without timeout per attempt"];
    }

    ADJNonEmptyString *_Nullable identifierForVendor =
    [self getIdentifierForVendorWithTimeoutPerAttempt:self.timeoutPerAttempt];

    ADJNonEmptyString *_Nullable advertisingIdentifier =
    [self getAdvertisingIdentifierWithTimeoutPerAttempt:self.timeoutPerAttempt];

    if (identifierForVendor == nil && advertisingIdentifier == nil) {
        return [[ADJSessionDeviceIdsData alloc]
                initWithFailMessage:@"either session device ids"];
    }

    ADJSessionDeviceIdsData *_Nonnull sessionDeviceIdsData =
    [[ADJSessionDeviceIdsData alloc]
     initWithAdvertisingIdentifier:advertisingIdentifier
     identifierForVendor:identifierForVendor];

    if (self.canCacheData) {
        self.sessionDeviceIdsDataCached = sessionDeviceIdsData;
        _canUseCacheData = YES;
    }

    return sessionDeviceIdsData;
}

#pragma mark Internal Methods
- (nullable ADJNonEmptyString *)
    getIdentifierForVendorWithTimeoutPerAttempt:(nonnull ADJTimeLengthMilli *)timeoutPerAttempt
{
    if (self.identifierForVendorCached != nil) {
        return self.identifierForVendorCached;
    }

    __typeof(self) __weak weakSelf = self;

    __block ADJValueWO<ADJNonEmptyString *> *_Nonnull identifierForVendorWO =
        [[ADJValueWO alloc] init];

    BOOL readIdentifierForVendorFinishedSuccessfully =
        [self.executor executeSynchronouslyWithTimeout:timeoutPerAttempt
                                        blockToExecute:
         ^{
            __typeof(weakSelf) __strong strongSelf = weakSelf;
            if (strongSelf == nil) { return; }

            UIDevice *_Nonnull currentDevice = UIDevice.currentDevice;

            ADJResultNL<ADJNonEmptyString *> *_Nonnull identifierForVendorResult =
                [ADJNonEmptyString instanceFromOptionalString:
                 [UIDevice.currentDevice.identifierForVendor UUIDString]];

            [identifierForVendorWO setNewValue:identifierForVendorResult.value];
        } source:@"read system idfv with timeout"];

    if (! readIdentifierForVendorFinishedSuccessfully) {
        return nil;
    }

    return [identifierForVendorWO changedValue];
}

- (nullable ADJNonEmptyString *)
    getAdvertisingIdentifierWithTimeoutPerAttempt:(nonnull ADJTimeLengthMilli *)timeoutPerAttempt
{
    __typeof(self) __weak weakSelf = self;

    __block ADJValueWO<ADJNonEmptyString *> *_Nonnull advertisingIdentifierWO =
        [[ADJValueWO alloc] init];

    BOOL readAdvertisingIdentifierFinishedSuccessfully =
        [self.executor executeSynchronouslyWithTimeout:timeoutPerAttempt
                                        blockToExecute:
         ^{
            __typeof(weakSelf) __strong strongSelf = weakSelf;
            if (strongSelf == nil) { return; }

            ADJNonEmptyString *_Nullable advertisingIdentifier =
                [strongSelf readAdvertisingIdentifier];
            [advertisingIdentifierWO setNewValue:advertisingIdentifier];
        } source:@"read system idfa"];

    if (! readAdvertisingIdentifierFinishedSuccessfully) {
        return  nil;
    }

    // TODO: add idfa zeros check
    return [advertisingIdentifierWO changedValue];
}

// return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
- (nullable ADJNonEmptyString *)readAdvertisingIdentifier {
    NSString *_Nonnull className =
    [ADJUtilF joinString:@"A", @"S", @"identifier", @"manager", nil];

    Class _Nullable adSupportClass = NSClassFromString(className);
    if (adSupportClass == nil) {
        return nil;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *_Nonnull keyManager = [ADJUtilF joinString:@"shared", @"manager", nil];
    SEL selManager = NSSelectorFromString(keyManager);
    if (![adSupportClass respondsToSelector:selManager]) {
        return nil;
    }

    id _Nullable manager = [adSupportClass performSelector:selManager];
    if (manager == nil) {
        return nil;
    }

    NSString *_Nonnull keyIdentifier = [ADJUtilF joinString:@"advertising", @"identifier", nil];
    SEL selIdentifier = NSSelectorFromString(keyIdentifier);
    if (![manager respondsToSelector:selIdentifier]) {
        return nil;
    }

    id _Nullable identifier = [manager performSelector:selIdentifier];
    if (identifier == nil) {
        return nil;
    }

    NSString *_Nonnull keyString = [ADJUtilF joinString:@"UUID", @"string", nil];
    SEL selString = NSSelectorFromString(keyString);
    if (![identifier respondsToSelector:selString]) {
        return nil;
    }

    id _Nullable idForAdvertisersString = [identifier performSelector:selString];
#pragma clang diagnostic pop

    ADJResultNN<ADJNonEmptyString *> *_Nonnull idForAdvertisersResult =
        [ADJNonEmptyString instanceFromObject:idForAdvertisersString];

    if (idForAdvertisersResult.failMessage != nil) {
        return nil;
    }

    return idForAdvertisersResult.value;
}

@end
