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
#import "ADJConstants.h"

//#import "ADJResultFail.h"

@interface ADJSessionDeviceIdsController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *timeoutPerAttempt;
@property (readonly, assign, nonatomic) BOOL canCacheData;

#pragma mark - Internal variables
@property (nullable, readwrite, strong, nonatomic)
    ADJResult<ADJSessionDeviceIdsData *> *sessionDeviceIdsDataResultCached;
@property (nullable, readwrite, strong, nonatomic)
    ADJResult<ADJNonEmptyString *> *identifierForVendorResultCached;

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

    _sessionDeviceIdsDataResultCached = nil;
    _identifierForVendorResultCached = nil;

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

- (nonnull ADJResult<ADJSessionDeviceIdsData *> *)getSessionDeviceIdsSync {
    if (_canUseCacheData) {
        return self.sessionDeviceIdsDataResultCached;
    }

    if (self.timeoutPerAttempt == nil) {
        return [ADJResult failWithMessage:
                @"Cannot attempt to read session device ids without timeout per attempt"];
    }

    __block ADJResult<ADJNonEmptyString *> *_Nonnull identifierForVendorResult =
        [self getIdentifierForVendorWithTimeoutPerAttempt:self.timeoutPerAttempt];

    __block ADJResult<ADJNonEmptyString *> *_Nonnull advertisingIdentifierResult =
        [self getAdvertisingIdentifierWithTimeoutPerAttempt:self.timeoutPerAttempt];

    if (identifierForVendorResult.value == nil && advertisingIdentifierResult.value == nil) {
        return [ADJResult failWithMessage:
                @"Could not obtain either identifier for vendor or advertising identifier"
                              wasInputNil:NO
                               builderBlock:^(ADJResultFailBuilder * _Nonnull resultFailBuilder) {
            if (identifierForVendorResult.fail != nil) {
                [resultFailBuilder withKey:@"advertising identifier fail"
                                 otherFail:identifierForVendorResult.fail];
            }
            if (advertisingIdentifierResult.fail != nil) {
                [resultFailBuilder withKey:@"identifier for vendor fail"
                                     otherFail:advertisingIdentifierResult.fail];
            }
        }];
    }

    ADJResult<ADJSessionDeviceIdsData *> *_Nonnull sessionDeviceIdsDataResult =
        [ADJResult okWithValue:
         [[ADJSessionDeviceIdsData alloc]
          initWithAdvertisingIdentifier:advertisingIdentifierResult.value
          identifierForVendor:identifierForVendorResult.value]];

    if (self.canCacheData) {
        self.sessionDeviceIdsDataResultCached = sessionDeviceIdsDataResult;
        _canUseCacheData = YES;
    }

    return sessionDeviceIdsDataResult;
}

#pragma mark Internal Methods
- (nonnull ADJResult<ADJNonEmptyString *> *)
    getIdentifierForVendorWithTimeoutPerAttempt:(nonnull ADJTimeLengthMilli *)timeoutPerAttempt
{
    if (self.identifierForVendorResultCached != nil) {
        return self.identifierForVendorResultCached;
    }

    __block ADJValueWO<ADJResult<ADJNonEmptyString *> *> *_Nonnull identifierForVendorResultWO =
        [[ADJValueWO alloc] init];

    BOOL readIdentifierForVendorFinishedSuccessfully =
        [self.executor executeSynchronouslyWithTimeout:timeoutPerAttempt
                                        blockToExecute:
         ^{
            NSUUID *_Nullable identifierForVendor = UIDevice.currentDevice.identifierForVendor;
            // According to https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor?language=objc
            //  'If the value is nil, wait and get the value again later.
            //  This happens, for example, after the device has been restarted
            //   but before the user has unlocked the device.'
            // TODO: is it worth to consider retrying here?
            if (identifierForVendor == nil) {
                [identifierForVendorResultWO setNewValue:
                 [ADJResult nilInputWithMessage:
                  @"UIDevice currentDevice identifierForVendor was nil"]];
            } else {
                [identifierForVendorResultWO setNewValue:
                 [ADJNonEmptyString instanceFromString:
                  [UIDevice.currentDevice.identifierForVendor UUIDString]]];
            }
        } source:@"read system idfv with timeout"];

    if (! readIdentifierForVendorFinishedSuccessfully) {
        return [ADJResult failWithMessage:
                @"Could not read Advertising for Vendor synchronously within timeout"];
    }

    ADJResult<ADJNonEmptyString *> *_Nullable identifierForVendorResult =
        [identifierForVendorResultWO changedValue];

    if (identifierForVendorResult == nil) {
        return [ADJResult failWithMessage:
                @"Could not obtain Advertising for Vendor result"];
    }

    return identifierForVendorResult;
}

- (nonnull ADJResult<ADJNonEmptyString *> *)
    getAdvertisingIdentifierWithTimeoutPerAttempt:(nonnull ADJTimeLengthMilli *)timeoutPerAttempt
{
    __block ADJValueWO<ADJResult<ADJNonEmptyString *> *> *_Nonnull advertisingIdentifierResultWO =
        [[ADJValueWO alloc] init];

    BOOL readAdvertisingIdentifierFinishedSuccessfully =
        [self.executor executeSynchronouslyWithTimeout:timeoutPerAttempt
                                        blockToExecute:
         ^{
            ADJResult<ADJNonEmptyString *> *_Nonnull advertisingIdentifierResult =
                [ADJSessionDeviceIdsController readAdvertisingIdentifier];
            [advertisingIdentifierResultWO setNewValue:advertisingIdentifierResult];
        } source:@"read system idfa"];

    if (! readAdvertisingIdentifierFinishedSuccessfully) {
        return [ADJResult failWithMessage:
                @"Could not read Advertising Identifier synchronously within timeout"];
    }

    ADJResult<ADJNonEmptyString *> *_Nullable advertisingIdentifierResult =
        [advertisingIdentifierResultWO changedValue];

    if (advertisingIdentifierResult == nil) {
        return [ADJResult failWithMessage:
                @"Could not obtain Advertising Identifier result"];
    }

    return advertisingIdentifierResult;
}

// return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
+ (nonnull ADJResult<ADJNonEmptyString *> *)readAdvertisingIdentifier {
    NSString *_Nonnull className =
        [ADJUtilF joinString:@"A", @"S", @"identifier", @"manager", nil];

    Class _Nullable adSupportClass = NSClassFromString(className);
    if (adSupportClass == nil) {
        return [ADJResult failWithMessage:@"Cannot find indentifier manager class"];
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *_Nonnull keyManager = [ADJUtilF joinString:@"shared", @"manager", nil];
    SEL selManager = NSSelectorFromString(keyManager);
    if (![adSupportClass respondsToSelector:selManager]) {
        return [ADJResult failWithMessage:
                @"Cannot detected shared instance of indentifier manager"];
    }

    id _Nullable manager = [adSupportClass performSelector:selManager];
    if (manager == nil) {
        return [ADJResult failWithMessage:@"Invalid instance of indentifier manager"];
    }

    NSString *_Nonnull keyIdentifier = [ADJUtilF joinString:@"advertising", @"identifier", nil];
    SEL selIdentifier = NSSelectorFromString(keyIdentifier);
    if (! [manager respondsToSelector:selIdentifier]) {
        return [ADJResult failWithMessage:@"Cannot detected advertising identifier method"];
    }

    id _Nullable identifier = [manager performSelector:selIdentifier];
    if (identifier == nil) {
        return [ADJResult failWithMessage:@"Invalid instance of advertising identifier"];
    }
#pragma clang diagnostic pop
    if (! [identifier isKindOfClass:[NSUUID class]]) {
        return [ADJResult failWithMessage:@"Invalid type of advertising identifier"
                                      key:@"advertising identifier class"
                              stringValue:NSStringFromClass([identifier class])];
    }

    NSUUID *_Nonnull identifierUuid = (NSUUID *)identifier;

    // TODO: change when ADJNonEmptyString instanceFromOptionalString is replaced
    ADJResult<ADJNonEmptyString *> *_Nonnull idForAdvertisersResult =
        [ADJNonEmptyString instanceFromString:identifierUuid.UUIDString];

    if (idForAdvertisersResult.fail != nil) {
        return idForAdvertisersResult;
    }

    if ([idForAdvertisersResult.value.stringValue isEqualToString:ADJIdForAdvertisersZeros]) {
        return [ADJResult nilInputWithMessage:@"idForAdvertisersResult was equal to zeros"];
    }

    return idForAdvertisersResult;
}

@end
