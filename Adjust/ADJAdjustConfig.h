//
//  ADJAdjustConfig.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADJAdjustIdentifierSubscriber;
@protocol ADJAdjustAttributionSubscriber;
@protocol ADJAdjustLogSubscriber;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJEnvironmentSandbox;
FOUNDATION_EXPORT NSString *const ADJEnvironmentProduction;

// TODO: Check the ObjC->Swift enum conversion naming capabilities (to use ADJ prefix).
typedef NSString *AdjustDataResidency NS_TYPED_ENUM;
FOUNDATION_EXPORT AdjustDataResidency const AdjustDataResidencyEU;
FOUNDATION_EXPORT AdjustDataResidency const AdjustDataResidencyTR;
FOUNDATION_EXPORT AdjustDataResidency const AdjustDataResidencyUS;

NS_ASSUME_NONNULL_END

@interface ADJAdjustConfig : NSObject
// instantiation
- (nonnull instancetype)initWithAppToken:(nonnull NSString *)appToken
                             environment:(nonnull NSString *)environment
NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)setDefaultTracker:(nonnull NSString *)defaultTracker;
- (void)enableCoppaCompliance;
- (void)doesNeedCost;
- (void)doLogAll;
- (void)doNotLogAny;
- (void)setUrlStrategyBaseDomain:(nonnull NSString *)urlStrategyBaseDomain;
- (void)setDataResidency:(nonnull AdjustDataResidency)dataResidency;
- (void)setCustomEndpointWithUrl:(nonnull NSString *)customEndpointUrl
        optionalPublicKeyKeyHash:(nullable NSString *)optionalPublicKeyKeyHash;
- (void)setExternalDeviceId:(nullable NSString *)externalDeviceId;
- (void)preventOpenDeferredDeeplink;
- (void)doNotReadAppleSearchAdsAttribution;
- (void)allowSendingFromBackground;
- (void)setEventIdDeduplicationMaxCapacity:(int)eventIdDeduplicationMaxCapacity;
- (void)setAdjustIdentifierSubscriber:
    (nonnull id<ADJAdjustIdentifierSubscriber>)adjustIdentifierSubscriber;
- (void)setAdjustAttributionSubscriber:
    (nonnull id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber;
- (void)setAdjustLogSubscriber:(nonnull id<ADJAdjustLogSubscriber>)adjustLogSubscriber;

// public properties
@property (nullable, readonly, strong, nonatomic) NSString *appToken;
@property (nullable, readonly, strong, nonatomic) NSString *environment;
@property (nullable, readonly, strong, nonatomic) NSString *defaultTracker;
@property (nullable, readonly, strong, nonatomic) NSString *urlStrategyDomain;
@property (nullable, readonly, strong, nonatomic) AdjustDataResidency dataResidency;
@property (nullable, readonly, strong, nonatomic) NSString *customEndpointUrl;
@property (nullable, readonly, strong, nonatomic) NSString *customEndpointPublicKeyHash;
@property (nullable, readonly, strong, nonatomic) NSString *externalDeviceId;
@property (readonly, assign, nonatomic) BOOL isCoppaComplianceEnabledFlag;
@property (readonly, assign, nonatomic) BOOL needsCostFlag;
@property (readonly, assign, nonatomic) BOOL doLogAllFlag;
@property (readonly, assign, nonatomic) BOOL doNotLogAnyFlag;
@property (readonly, assign, nonatomic) BOOL doNotOpenDeferredDeeplinkFlag;
@property (readonly, assign, nonatomic) BOOL doNotReadAppleSearchAdsAttributionFlag;
@property (readonly, assign, nonatomic) BOOL canSendInBackgroundFlag;
@property (nullable, readonly, strong, nonatomic)
    NSNumber *eventIdDeduplicationMaxCapacityNumberInt;
@property (nullable, readonly, strong, nonatomic)
    id<ADJAdjustIdentifierSubscriber> adjustIdentifierSubscriber;
@property (nullable, readonly, strong, nonatomic)
    id<ADJAdjustAttributionSubscriber> adjustAttributionSubscriber;
@property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> adjustLogSubscriber;

@end
