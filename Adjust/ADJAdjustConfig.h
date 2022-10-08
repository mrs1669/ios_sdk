//
//  ADJAdjustConfig.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADJAdjustAttributionSubscriber;
@protocol ADJAdjustLogSubscriber;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJEnvironmentSandbox;
FOUNDATION_EXPORT NSString *const ADJEnvironmentProduction;
FOUNDATION_EXPORT NSString *const ADJUrlStategyChina;
FOUNDATION_EXPORT NSString *const ADJUrlStategyIndia;

NS_ASSUME_NONNULL_END

@interface ADJAdjustConfig : NSObject
// instantiation
- (nonnull instancetype)initWithAppToken:(nonnull NSString *)appToken
                             environment:(nonnull NSString *)environment
NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)setDefaultTracker:(nonnull NSString *)defaultTracker;
- (void)setLogLevel:(nonnull NSString *)logLevel;
- (void)setUrlStrategy:(nonnull NSString *)urlStrategy;
- (void)setCustomEndpointWithUrl:(nonnull NSString *)customEndpointUrl
        optionalPublicKeyKeyHash:(nullable NSString *)optionalPublicKeyKeyHash;
- (void)preventOpenDeferredDeeplink;
- (void)doNotReadAppleSearchAdsAttribution;
- (void)allowSendingFromBackground;
- (void)setEventIdDeduplicationMaxCapacity:(int)eventIdDeduplicationMaxCapacity;
- (void)setAdjustAttributionSubscriber:(nonnull id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber;
- (void)setAdjustLogSubscriber:(nonnull id<ADJAdjustLogSubscriber>)adjustLogSubscriber;

// public properties
@property (nullable, readonly, strong, nonatomic) NSString *appToken;
@property (nullable, readonly, strong, nonatomic) NSString *environment;
@property (nullable, readonly, strong, nonatomic) NSString *defaultTracker;
@property (nullable, readonly, strong, nonatomic) NSString *logLevel;
@property (nullable, readonly, strong, nonatomic) NSString *urlStrategy;
@property (nullable, readonly, strong, nonatomic) NSString *customEndpointUrl;
@property (nullable, readonly, strong, nonatomic) NSString *customEndpointPublicKeyHash;
@property (nullable, readonly, strong, nonatomic) NSNumber *doNotOpenDeferredDeeplinkNumberBool;
@property (nullable, readonly, strong, nonatomic) NSNumber *doNotReadAppleSearchAdsAttributionNumberBool;
@property (nullable, readonly, strong, nonatomic) NSNumber *canSendInBackgroundNumberBool;
@property (nullable, readonly, strong, nonatomic) NSNumber *eventIdDeduplicationMaxCapacityNumberInt;
@property (nullable, readonly, strong, nonatomic) id<ADJAdjustAttributionSubscriber> adjustAttributionSubscriber;
@property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> adjustLogSubscriber;

@end

