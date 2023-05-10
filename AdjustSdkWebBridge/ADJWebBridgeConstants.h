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

FOUNDATION_EXPORT NSString *const ADJWBGetAdjustAttributionAsyncMethodName;
FOUNDATION_EXPORT NSString *const ADJWBAdjustAttributionAsyncGetterCallbackKey;

FOUNDATION_EXPORT NSString *const ADJWBGetAdjustDeviceIdsAsyncMethodName;
FOUNDATION_EXPORT NSString *const ADJWBAdjustDeviceIdsAsyncGetterCallbackKey;

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

FOUNDATION_EXPORT NSString *const ADJWBAdjustConfigName;
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
FOUNDATION_EXPORT NSString *const ADJWBAdjustAttributionSubscriberCallbackConfigKey;
FOUNDATION_EXPORT NSString *const ADJWBAdjustLogSubscriberCallbackConfigKey;

FOUNDATION_EXPORT NSString *const ADJWBAdjustEventName;
FOUNDATION_EXPORT NSString *const ADJWBEventTokenEventKey;
FOUNDATION_EXPORT NSString *const ADJWBRevenueAmountDoubleEventKey;
FOUNDATION_EXPORT NSString *const ADJWBCurrencyEventKey;
FOUNDATION_EXPORT NSString *const ADJWBCallbackParametersEventKey;
FOUNDATION_EXPORT NSString *const ADJWBPartnerParametersEventKey;
FOUNDATION_EXPORT NSString *const ADJWBDeduplicationIdEventKey;

FOUNDATION_EXPORT NSString *const ADJWBUrlStringKey;

FOUNDATION_EXPORT NSString *const ADJWBPushTokenStringKey;

FOUNDATION_EXPORT NSString *const ADJWBAdjustThirdPartySharingName;
FOUNDATION_EXPORT NSString *const ADJWBEnabledOrElseDisabledSharingTPSKey;
FOUNDATION_EXPORT NSString *const ADJWBGranularOptionsByNameArrayTPSKey;
FOUNDATION_EXPORT NSString *const ADJWBPartnerSharingSettingsByNameArrayTPSKey;


FOUNDATION_EXPORT NSString *const ADJWBObjectNameKey;

FOUNDATION_EXPORT NSString *const ADJWBElementKey;

FOUNDATION_EXPORT NSString *const ADJWBKvPartnerNameKey;
FOUNDATION_EXPORT NSString *const ADJWBKvKeyKey;
FOUNDATION_EXPORT NSString *const ADJWBKvValueKey;

NS_ASSUME_NONNULL_END
