//
//  ADJAdjustConfig.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustConfig.h"

#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSString *appToken;
 @property (nullable, readonly, strong, nonatomic) NSString *environment;
 @property (nullable, readonly, strong, nonatomic) NSString *defaultTracker;
 @property (nullable, readonly, strong, nonatomic) NSString *logLevel;
 @property (nullable, readonly, strong, nonatomic) NSString *urlStrategy;
 @property (nullable, readonly, strong, nonatomic) NSString *customEndpointUrl;
 @property (nullable, readonly, strong, nonatomic) NSString *customEndpointPublicKeyHash;
 @property (nullable, readonly, strong, nonatomic) NSNumber *canSendInBackgroundNumberBool;
 @property (nullable, readonly, strong, nonatomic) NSNumber *doNotOpenDeferredDeeplinkNumberBool;
 @property (nullable, readonly, strong, nonatomic)
     NSNumber *doNotReadAppleSearchAdsAttributionNumberBool;
 @property (nullable, readonly, strong, nonatomic)
     NSNumber *eventIdDeduplicationMaxCapacityNumberInt;
 @property (nullable, readonly, strong, nonatomic)
     id<ADJAdjustAttributionSubscriber> adjustAttributionSubscriber;
 @property (nullable, readonly, strong, nonatomic)
     id<ADJAdjustLogSubscriber> adjustLogSubscriber;
 */

#pragma mark - Public constants
NSString *const ADJEnvironmentSandbox = @"sandbox";
NSString *const ADJEnvironmentProduction = @"production";
NSString *const ADJUrlStategyChina = @"CHINA";
NSString *const ADJUrlStategyIndia = @"INDIA";

@implementation ADJAdjustConfig
#pragma mark Instantiation
- (nonnull instancetype)initWithAppToken:(nonnull NSString *)appToken
                             environment:(nonnull NSString *)environment
{
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

- (void)setLogLevel:(nonnull NSString *)logLevel {
    _logLevel = [ADJUtilObj copyStringWithInput:logLevel];
}

- (void)setUrlStrategy:(nonnull NSString *)urlStrategy {
    _urlStrategy = [ADJUtilObj copyStringWithInput:urlStrategy];
}

- (void)setCustomEndpointWithUrl:(nonnull NSString *)customEndpointUrl
        optionalPublicKeyKeyHash:(nullable NSString *)optionalPublicKeyKeyHash
{
    _customEndpointUrl = [ADJUtilObj copyStringWithInput:customEndpointUrl];
    _customEndpointPublicKeyHash = [ADJUtilObj copyStringWithInput:optionalPublicKeyKeyHash];
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

- (void)setAdjustAttributionSubscriber:
    (nonnull id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber
{
    _adjustAttributionSubscriber = adjustAttributionSubscriber;
}

- (void)setAdjustLogSubscriber:(nonnull id<ADJAdjustLogSubscriber>)adjustLogSubscriber {
    _adjustLogSubscriber = adjustLogSubscriber;
}

@end

