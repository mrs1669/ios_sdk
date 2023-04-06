//
//  ADJWebBridgeConstants.h
//  Adjust
//
//  Created by Pedro Silva on 05.04.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJWBMethodNameKey;
FOUNDATION_EXPORT NSString *const ADJWBInstanceIdKey;
FOUNDATION_EXPORT NSString *const ADJWBParametersKey;

FOUNDATION_EXPORT NSString *const ADJWBInitSdkMethodName;
FOUNDATION_EXPORT NSString *const ADJWBInactivateSdkMethodName;
FOUNDATION_EXPORT NSString *const ADJWBReactiveSdkMethodName;
FOUNDATION_EXPORT NSString *const ADJWBGdprForgetDeviceMethodName;
FOUNDATION_EXPORT NSString *const ADJWBAppWentToTheForegroundManualCallMethodName;
FOUNDATION_EXPORT NSString *const ADJWBAppWentToTheBackgroundManualCallMethodName;
FOUNDATION_EXPORT NSString *const ADJWBOfflineModeMethodName;
FOUNDATION_EXPORT NSString *const ADJWBOnlineModeMethodName;

FOUNDATION_EXPORT NSString *const ADJWBTrackEventMethodName;
FOUNDATION_EXPORT NSString *const ADJWBTrackLaunchedDeeplinkMethodName;
FOUNDATION_EXPORT NSString *const ADJWBTrackPushTokenMethodName;
FOUNDATION_EXPORT NSString *const ADJWBTrackThirdPartySharingMethodName;
FOUNDATION_EXPORT NSString *const ADJWBTrackAdRevenueMethodName;

FOUNDATION_EXPORT NSString *const ADJWBAddGlobalCallbackParameterMethodName;
FOUNDATION_EXPORT NSString *const ADJWBRemoveGlobalCallbackParameterByKeyMethodName;
FOUNDATION_EXPORT NSString *const ADJWBClearGlobalCallbackParametersMethodName;
FOUNDATION_EXPORT NSString *const ADJWBAddGlobalPartnerParameterMethodName;
FOUNDATION_EXPORT NSString *const ADJWBRemoveGlobalPartnerParameterByKeyMethodName;
FOUNDATION_EXPORT NSString *const ADJWBClearGlobalPartnerParametersMethodName;

FOUNDATION_EXPORT NSString *const ADJWBSdkVersionMethodName;

FOUNDATION_EXPORT NSString *const ADJWBJsStringType;
FOUNDATION_EXPORT NSString *const ADJWBJsNumberType;
FOUNDATION_EXPORT NSString *const ADJWBJsBooleanType;
FOUNDATION_EXPORT NSString *const ADJWBJsUndefinedType;
FOUNDATION_EXPORT NSString *const ADJWBJsFunctionType;

FOUNDATION_EXPORT NSString *const ADJWBAppTokenConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBEnvironmentConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBDefaultTrackerConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBUrlStrategyConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBCustomEndpointUrlConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBCustomEndpointPublicKeyHashConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBDoLogAllConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBDoNotLogAnyConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBCanSendInBackgroundConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBDoNotOpenDeferredDeeplinkConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBDoNotReadAppleSearchAdsAttributionConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBEventIdDeduplicationMaxCapacityConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBAdjustAttributionSubscriberCallbackIdConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBAdjustLogSubscriberCallbackIdConfigKey;

NS_ASSUME_NONNULL_END
