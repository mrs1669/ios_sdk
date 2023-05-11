//
//  ADJAdjustInternal.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADJSdkConfigData;
@class ADJAdjustConfig;
@class ADJAdjustEvent;
@class ADJAdjustThirdPartySharing;
@class ADJAdjustAdRevenue;
@protocol ADJAdjustInstance;

@protocol ADJInternalCallback <NSObject>

- (void)didInternalCallbackWithData:(nonnull NSDictionary<NSString *, id> *)data;

@end

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJInternalAttributionSubscriberV5000Key;
FOUNDATION_EXPORT NSString *const ADJInternalLogSubscriberV5000Key;

FOUNDATION_EXPORT NSString *const ADJReadAttributionMethodName;
FOUNDATION_EXPORT NSString *const ADJChangedAttributionMethodName;

FOUNDATION_EXPORT NSString *const ADJLoggedMessageMethodName;
FOUNDATION_EXPORT NSString *const ADJLoggedMessagesPreInitMethodName;

FOUNDATION_EXPORT NSString *const ADJFailedMethodName;

FOUNDATION_EXPORT NSString *const ADJAttributionGetterReadMethodName;
FOUNDATION_EXPORT NSString *const ADJAttributionGetterFailedMethodName;

FOUNDATION_EXPORT NSString *const ADJDeviceIdsGetterReadMethodName;
FOUNDATION_EXPORT NSString *const ADJDeviceIdsGetterFailedMethodName;

FOUNDATION_EXPORT NSString *const ADJInternalCallbackStringSuffix;
FOUNDATION_EXPORT NSString *const ADJInternalCallbackAdjustDataSuffix;
FOUNDATION_EXPORT NSString *const ADJInternalCallbackNsDictionarySuffix;
FOUNDATION_EXPORT NSString *const ADJInternalCallbackJsonStringSuffix;

NS_ASSUME_NONNULL_END

@interface ADJAdjustInternal : NSObject

+ (nonnull id<ADJAdjustInstance>)sdkInstanceForClientId:(nullable NSString *)clientId;

+ (void)
    initSdkForClientId:(nullable NSString *)clientId
    adjustConfig:(nonnull ADJAdjustConfig *)adjustConfig
    internalConfigSubscriptions:
        (nullable NSDictionary<NSString *, id<ADJInternalCallback>> *)internalConfigSubscriptions;

+ (void)adjustAttributionWithClientId:(nullable NSString *)clientId
                     internalCallback:(nonnull id<ADJInternalCallback>)internalCallback;
+ (void)adjustDeviceIdsWithClientId:(nullable NSString *)clientId
                   internalCallback:(nonnull id<ADJInternalCallback>)internalCallback;

+ (void)
    trackEventForClientId:(nullable NSString *)clientId
    adjustEvent:(nonnull ADJAdjustEvent *)adjustEvent
    callbackParameterKeyValueArray:(nullable NSArray *)callbackParameterKeyValueArray
    partnerParameterKeyValueArray:(nullable NSArray *)partnerParameterKeyValueArray;

+ (void)
    trackThirdPartySharingForClientId:(nullable NSString *)clientId
    adjustThirdPartySharing:(nonnull ADJAdjustThirdPartySharing *)adjustThirdPartySharing
    granularOptionsByNameArray:(nullable NSArray *)granularOptionsByNameArray
    partnerSharingSettingsByNameArray:(nullable NSArray *)partnerSharingSettingsByNameArray;

+ (void)
    trackAdRevenuetForClientId:(nullable NSString *)clientId
    adjustAdRevenue:(nonnull ADJAdjustAdRevenue *)adjustAdRevenue
    callbackParameterKeyValueArray:(nullable NSArray *)callbackParameterKeyValueArray
    partnerParameterKeyValueArray:(nullable NSArray *)partnerParameterKeyValueArray;

+ (nonnull NSString *)sdkVersion;

+ (nonnull NSString *)sdkVersionWithSdkPrefix:(nullable NSString *)sdkPrefix;

+ (void)
    setSdkPrefix:(nullable NSString *)sdkPrefix
    fromInstanceWithClientId:(nullable NSString *)clientId;

+ (nonnull NSString *)teardownWithSdkConfigData:(nullable ADJSdkConfigData *)sdkConfigData
                             shouldClearStorage:(BOOL)shouldClearStorage;

@end
