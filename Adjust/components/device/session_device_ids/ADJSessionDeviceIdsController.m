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
@property (nullable, readonly, weak, nonatomic) id<ADJThreadPool> threadPoolWeak;
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
                                   threadPool:(nonnull id<ADJThreadPool>)threadPool
                            timeoutPerAttempt:(nullable ADJTimeLengthMilli *)timeoutPerAttempt
                                 canCacheData:(BOOL)canCacheData {
    self = [super initWithLoggerFactory:loggerFactory source:@"SessionDeviceIdsController"];
    _threadPoolWeak = threadPool;
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
        return [self returnFailed:@"without timeout per attempt"];
    }
    
    id<ADJThreadPool> _Nullable threadPool = self.threadPoolWeak;
    if (threadPool == nil) {
        return [self returnFailed:@"without reference to thread pool"];
    }
    
    ADJNonEmptyString *_Nullable identifierForVendor =
    [self getIdentifierForVendorWithThreadPool:threadPool
                             timeoutPerAttempt:self.timeoutPerAttempt];
    
    ADJNonEmptyString *_Nullable advertisingIdentifier =
    [self getAdvertisingIdentifierWithThreadPool:threadPool
                               timeoutPerAttempt:self.timeoutPerAttempt];
    
    if (identifierForVendor == nil && advertisingIdentifier == nil) {
        return [self returnFailed:@"either session device ids"];
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
- (nonnull ADJSessionDeviceIdsData *)returnFailed:(nonnull NSString *)failReason {
    [self.logger debug:@"Cannot get session device ids %@", failReason];
    return [[ADJSessionDeviceIdsData alloc] initWithFailMessage:failReason];
}

- (nullable ADJNonEmptyString *)getIdentifierForVendorWithThreadPool:(nonnull id<ADJThreadPool>)threadPool
                                                   timeoutPerAttempt:(nonnull ADJTimeLengthMilli *)timeoutPerAttempt {
    if (self.identifierForVendorCached != nil) {
        return self.identifierForVendorCached;
    }
    
    __typeof(self) __weak weakSelf = self;
    
    __block ADJValueWO<ADJNonEmptyString *> *_Nonnull identifierForVendorWO =
    [[ADJValueWO alloc] init];
    
    BOOL readIdentifierForVendorFinishedSuccessfully =
    [threadPool executeSynchronouslyWithTimeout:timeoutPerAttempt
                                 blockToExecute:
     ^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        UIDevice *_Nonnull currentDevice = UIDevice.currentDevice;
        
        ADJNonEmptyString *_Nullable identifierForVendor =
        [self readIdentifierForVendorWithCurrentDevice:currentDevice];
        [identifierForVendorWO setNewValue:identifierForVendor];
    }];
    
    if (! readIdentifierForVendorFinishedSuccessfully) {
        return nil;
    }
    
    return [identifierForVendorWO changedValue];
}

- (nullable ADJNonEmptyString *)getAdvertisingIdentifierWithThreadPool:(nonnull id<ADJThreadPool>)threadPool
                                                     timeoutPerAttempt:(nonnull ADJTimeLengthMilli *)timeoutPerAttempt {
    __typeof(self) __weak weakSelf = self;
    
    __block ADJValueWO<ADJNonEmptyString *> *_Nonnull advertisingIdentifierWO =
    [[ADJValueWO alloc] init];
    
    BOOL readAdvertisingIdentifierFinishedSuccessfully =
    [threadPool executeSynchronouslyWithTimeout:timeoutPerAttempt
                                 blockToExecute:
     ^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        ADJNonEmptyString *_Nullable advertisingIdentifier =
        [strongSelf readAdvertisingIdentifier];
        [advertisingIdentifierWO setNewValue:advertisingIdentifier];
    }];
    
    if (! readAdvertisingIdentifierFinishedSuccessfully) {
        return  nil;
    }
    
    // TODO add idfa zeros check
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
    if (idForAdvertisersString == nil
        || ! [idForAdvertisersString isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    return [ADJNonEmptyString instanceFromOptionalString:(NSString *)idForAdvertisersString
                                       sourceDescription:@"Advertising Identifier"
                                                  logger:self.logger];
}

- (nullable ADJNonEmptyString *)readIdentifierForVendorWithCurrentDevice:(nonnull UIDevice *)currentDevice {
    return [ADJNonEmptyString
            instanceFromOptionalString:[UIDevice.currentDevice.identifierForVendor UUIDString]
            sourceDescription:@"Identifier For Vendor"
            logger:self.logger];
}

@end
