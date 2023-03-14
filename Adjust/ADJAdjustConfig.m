//
//  ADJAdjustConfig.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustConfig.h"

#import "ADJAdjustAttributionSubscriber.h"
#import "ADJAdjustLogSubscriber.h"

#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSString *appToken;
 @property (nullable, readonly, strong, nonatomic) NSString *environment;
 @property (nullable, readonly, strong, nonatomic) NSString *defaultTracker;
 @property (nullable, readonly, strong, nonatomic) NSString *urlStrategyDomain;
 @property (nullable, readonly, strong, nonatomic) AdjustDataResidency dataResidency;
 @property (nullable, readonly, strong, nonatomic) NSString *customEndpointUrl;
 @property (nullable, readonly, strong, nonatomic) NSString *customEndpointPublicKeyHash;
 @property (nullable, readonly, strong, nonatomic) NSNumber *doLogAllNumberBool;
 @property (nullable, readonly, strong, nonatomic) NSNumber *doNotLogAnyNumberBool;
 @property (nullable, readonly, strong, nonatomic) NSNumber *canSendInBackgroundNumberBool;
 @property (nullable, readonly, strong, nonatomic) NSNumber *doNotOpenDeferredDeeplinkNumberBool;
 @property (nullable, readonly, strong, nonatomic) NSNumber *doNotReadAppleSearchAdsAttributionNumberBool;
 @property (nullable, readonly, strong, nonatomic) NSNumber *eventIdDeduplicationMaxCapacityNumberInt;
 @property (nullable, readonly, strong, nonatomic) id<ADJAdjustAttributionSubscriber> adjustAttributionSubscriber;
 @property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> adjustLogSubscriber;
 */

#pragma mark - Public constants
NSString *const ADJEnvironmentSandbox = @"sandbox";
NSString *const ADJEnvironmentProduction = @"production";
AdjustDataResidency const AdjustDataResidencyEU = @"DataResidencyEU";
AdjustDataResidency const AdjustDataResidencyTR = @"DataResidencyTR";
AdjustDataResidency const AdjustDataResidencyUS = @"DataResidencyUS";

@implementation ADJAdjustConfig

#pragma mark Instantiation
- (nonnull instancetype)initWithAppToken:(nonnull NSString *)appToken
                             environment:(nonnull NSString *)environment {
    self = [super init];
    _appToken = [ADJUtilObj copyStringWithInput:appToken];
    _environment = [ADJUtilObj copyStringWithInput:environment];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (void)setDefaultTracker:(nonnull NSString *)defaultTracker {
    _defaultTracker = [ADJUtilObj copyStringWithInput:defaultTracker];
}

- (void)doLogAll {
    _doLogAllNumberBool = @(YES);
}
- (void)doNotLogAny {
    _doNotLogAnyNumberBool = @(YES);
}

- (void)setUrlStrategyBaseDomain:(nonnull NSString *)urlStrategyBaseDomain {
    _urlStrategyDomain = [ADJUtilObj copyStringWithInput:urlStrategyBaseDomain];
}

- (void)setDataResidency:(nonnull AdjustDataResidency)dataResidency {
    _dataResidency = [ADJUtilObj copyStringWithInput:dataResidency];
}

- (void)setCustomEndpointWithUrl:(nonnull NSString *)customEndpointUrl
        optionalPublicKeyKeyHash:(nullable NSString *)optionalPublicKeyKeyHash {
    _customEndpointUrl = [ADJUtilObj copyStringWithInput:customEndpointUrl];
    _customEndpointPublicKeyHash = [ADJUtilObj copyStringWithInput:optionalPublicKeyKeyHash];
}

- (void)setExternalDeviceId:(NSString * _Nullable)externalDeviceId {
    _externalDeviceId = [ADJUtilObj copyStringWithInput:externalDeviceId];
}

- (void)preventOpenDeferredDeeplink {
    _doNotOpenDeferredDeeplinkNumberBool = @(YES);
}

- (void)doNotReadAppleSearchAdsAttribution {
    _doNotReadAppleSearchAdsAttributionNumberBool = @(YES);
}

- (void)allowSendingFromBackground {
    _canSendInBackgroundNumberBool = @(YES);
}

- (void)setEventIdDeduplicationMaxCapacity:(int)eventIdDeduplicationMaxCapacity {
    _eventIdDeduplicationMaxCapacityNumberInt = @(eventIdDeduplicationMaxCapacity);
}

- (void)setAdjustAttributionSubscriber:(nonnull id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber {
    _adjustAttributionSubscriber = adjustAttributionSubscriber;
}

- (void)setAdjustLogSubscriber:(nonnull id<ADJAdjustLogSubscriber>)adjustLogSubscriber {
    _adjustLogSubscriber = adjustLogSubscriber;
}

@end

