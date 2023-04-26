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
@protocol ADJAdjustInstance;

@protocol ADJInternalCallback <NSObject>

- (void)didInternalCallbackWithData:(nonnull NSDictionary<NSString *, id> *)data;

@end

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJInternalAttributionSubscriberV5000Key;
FOUNDATION_EXPORT NSString *const ADJInternalLogSubscriberV5000Key;

FOUNDATION_EXPORT NSString *const ADJDidReadAttributionMethodName;
FOUNDATION_EXPORT NSString *const ADJDidChangeAttributionMethodName;

FOUNDATION_EXPORT NSString *const ADJDidLogMessageMethodName;
FOUNDATION_EXPORT NSString *const ADJDidLogMessagesPreInitMethodName;

FOUNDATION_EXPORT NSString *const ADJDidFailMethodName;

FOUNDATION_EXPORT NSString *const ADJInternalCallbackStringSuffix;
FOUNDATION_EXPORT NSString *const ADJInternalCallbackAdjustDataSuffix;
FOUNDATION_EXPORT NSString *const ADJInternalCallbackNsDictionarySuffix;
FOUNDATION_EXPORT NSString *const ADJInternalCallbackJsonStringSuffix;

NS_ASSUME_NONNULL_END

@interface ADJAdjustInternal : NSObject

+ (nonnull id<ADJAdjustInstance>)sdkInstanceForClientId:(nullable NSString *)clientId;

+ (void)
    initSdkInternalForClientId:(nullable NSString *)clientId
    adjustConfig:(nonnull ADJAdjustConfig *)adjustConfig
    internalConfigSubscriptions:
        (nullable NSDictionary<NSString *, id<ADJInternalCallback>> *)internalConfigSubscriptions;

+ (nonnull NSString *)teardownWithSdkConfigData:(nullable ADJSdkConfigData *)sdkConfigData
                             shouldClearStorage:(BOOL)shouldClearStorage;

+ (nonnull NSString *)sdkVersion;

+ (nonnull NSString *)sdkVersionWithSdkPrefix:(nullable NSString *)sdkPrefix;

+ (void)
    setSdkPrefix:(nullable NSString *)sdkPrefix
    fromInstanceWithClientId:(nullable NSString *)clientId;

@end
