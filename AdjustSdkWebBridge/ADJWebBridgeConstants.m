//
//  ADJWebBridgeConstants.m
//  Adjust
//
//  Created by Pedro Silva on 05.04.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJWebBridgeConstants.h"

NSString *const ADJWBMethodNameKey = @"methodName";
NSString *const ADJWBInstanceIdKey = @"instanceId";
NSString *const ADJWBParametersKey = @"parameters";

NSString *const ADJWBInitSdkMethodName = @"initSdk";
NSString *const ADJWBInactivateSdkMethodName = @"inactivateSdk";
NSString *const ADJWBReactiveSdkMethodName = @"reactivateSdk";
NSString *const ADJWBGdprForgetDeviceMethodName = @"gdprForgetDevice";
NSString *const ADJWBAppWentToTheForegroundManualCallMethodName = @"appWentToTheForegroundManualCall";
NSString *const ADJWBAppWentToTheBackgroundManualCallMethodName = @"appWentToTheBackgroundManualCall";
NSString *const ADJWBOfflineModeMethodName = @"switchToOfflineMode";
NSString *const ADJWBOnlineModeMethodName = @"switchBackToOnlineMode";

NSString *const ADJWBGetAdjustAttributionAsyncMethodName = @"getAdjustAttributionAsync";
NSString *const ADJWBAdjustAttributionAsyncGetterCallbackKey =
    @"_adjustAttributionAsyncGetterCallback";

NSString *const ADJWBGetAdjustDeviceIdsAsyncMethodName = @"getAdjustDeviceIdsAsync";
NSString *const ADJWBAdjustDeviceIdsAsyncGetterCallbackKey =
    @"_adjustDeviceIdsAsyncGetterCallback";

NSString *const ADJWBTrackEventMethodName = @"trackEvent";
NSString *const ADJWBTrackLaunchedDeeplinkMethodName = @"trackLaunchedDeeplink";
NSString *const ADJWBTrackPushTokenMethodName = @"trackPushToken";
NSString *const ADJWBTrackThirdPartySharingMethodName = @"trackThirdPartySharing";
NSString *const ADJWBTrackAdRevenueMethodName = @"trackAdRevenue";

NSString *const ADJWBAddGlobalCallbackParameterMethodName = @"addGlobalCallbackParameter";
NSString *const ADJWBRemoveGlobalCallbackParameterByKeyMethodName = @"removeGlobalCallbackParameterByKey";
NSString *const ADJWBClearGlobalCallbackParametersMethodName = @"clearGlobalCallbackParameters";
NSString *const ADJWBAddGlobalPartnerParameterMethodName = @"addGlobalPartnerParameter";
NSString *const ADJWBRemoveGlobalPartnerParameterByKeyMethodName = @"removeGlobalPartnerParameterByKey";
NSString *const ADJWBClearGlobalPartnerParametersMethodName = @"clearGlobalPartnerParameters";

NSString *const ADJWBSdkVersionMethodName = @"getSdkVersion";

NSString *const ADJWBJsStringType = @"string";
NSString *const ADJWBJsNumberType = @"number";
NSString *const ADJWBJsBooleanType = @"boolean";
NSString *const ADJWBJsUndefinedType = @"undefined";
NSString *const ADJWBJsFunctionType = @"function";

NSString *const ADJWBAdjustConfigName = @"AdjustConfig";
NSString *const ADJWBAppTokenConfigKey = @"_appToken";
NSString *const ADJWBEnvironmentConfigKey = @"_environment";
NSString *const ADJWBDefaultTrackerConfigKey = @"_defaultTracker";
NSString *const ADJWBUrlStrategyConfigKey = @"_urlStrategy";
NSString *const ADJWBCustomEndpointUrlConfigKey = @"_customEndpointUrl";
NSString *const ADJWBCustomEndpointPublicKeyHashConfigKey = @"_customEndpointPublicKeyHash";
NSString *const ADJWBDoLogAllConfigKey = @"_doLogAll";
NSString *const ADJWBDoNotLogAnyConfigKey = @"_doNotLogAny";
NSString *const ADJWBCanSendInBackgroundConfigKey = @"_canSendInBackground";
NSString *const ADJWBDoNotOpenDeferredDeeplinkConfigKey = @"_doNotOpenDeferredDeeplink";
NSString *const ADJWBDoNotReadAppleSearchAdsAttributionConfigKey =
    @"_doNotReadAppleSearchAdsAttribution";
NSString *const ADJWBEventIdDeduplicationMaxCapacityConfigKey =
    @"_eventIdDeduplicationMaxCapacity";
NSString *const ADJWBAdjustAttributionSubscriberCallbackConfigKey =
    @"_adjustAttributionSubscriberCallback";
NSString *const ADJWBAdjustLogSubscriberCallbackConfigKey = @"_adjustLogSubscriberCallback";

NSString *const ADJWBAdjustEventName = @"AdjustEvent";
NSString *const ADJWBEventTokenEventKey = @"_eventToken";
NSString *const ADJWBRevenueAmountDoubleEventKey = @"_revenueAmountDouble";
NSString *const ADJWBCurrencyEventKey = @"_currency";
NSString *const ADJWBCallbackParametersEventKey = @"_callbackParameters";
NSString *const ADJWBPartnerParametersEventKey = @"_partnerParameters";
NSString *const ADJWBDeduplicationIdEventKey = @"_deduplicationId";


NSString *const ADJWBObjectNameKey = @"_objectName";

NSString *const ADJWBKvKeyKey = @"_key";
NSString *const ADJWBKvValueKey = @"_value";
