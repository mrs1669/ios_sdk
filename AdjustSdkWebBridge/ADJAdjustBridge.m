//
//  ADJAdjustBridge.m
//  AdjustSdkWebBridge
//
//  Created by Aditi Agrawal on 26/10/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjust.h"

#import "ADJAdjustBridge.h"
#import "ADJAdjustEvent.h"
#import "ADJAdjustConfig.h"
#import "ADJAdjustInternal.h"
#import "ADJAdjustInstance.h"
#import "ADJAdjustAdRevenue.h"
#import "ADJAdjustPushToken.h"
#import "ADJAdjustAttribution.h"
#import "ADJAdjustLaunchedDeeplink.h"
#import "ADJAdjustThirdPartySharing.h"
#import "ADJAdjustAttributionSubscriber.h"

#import "ADJAdjust.h"
#import "ADJWebBridgeConstants.h"
#import "ADJWebViewCallback.h"
#import "ADJSdkApiHelper.h"

#import "ADJConstants.h"
#import "ADJResult.h"
#import "ADJInputLogMessageData.h"
#import "ADJConsoleLogger.h"
#import "ADJUtilConv.h"
#import "ADJBooleanWrapper.h"
#import "ADJInstanceRoot.h"
#import "ADJUtilF.h"
#import "ADJOptionalFailsNL.h"

#pragma mark Fields
@interface ADJAdjustBridge() <
    ADJAdjustAttributionSubscriber,
    ADJLogCollector,
    WKScriptMessageHandler>

@property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> logSubscriber;
@property (nonnull, readonly, strong, nonatomic) ADJLogger *logger;
@property (nonnull, readonly, strong, nonatomic) ADJWebViewCallback *webViewCallback;
@property (nonnull, readonly, strong, nonatomic) ADJSdkApiHelper *sdkApiHelper;

@end

@implementation ADJAdjustBridge
#pragma mark - Init Web View
+ (nullable ADJAdjustBridge *)instanceWithWKWebView:(nonnull WKWebView *)webView {
    return [ADJAdjustBridge instanceWithWKWebView:webView adjustJsLogSubscriber:nil];
}
+ (nullable ADJAdjustBridge *)
    instanceWithWKWebView:(nonnull WKWebView *)webView
    adjustJsLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustJsLogSubscriber
{
    if (! [webView isKindOfClass:WKWebView.class]) {
        return nil;
    }

    ADJResult<NSString *> *_Nonnull scriptSourceResult =
        [ADJAdjustBridge getAdjustWebBridgeScript];
    if (scriptSourceResult.fail != nil) {
        if (adjustJsLogSubscriber != nil) {
            [adjustJsLogSubscriber
             didLogWithMessage:
                 [ADJConsoleLogger clientCallbackFormatMessageWithLog:
                  [[ADJInputLogMessageData alloc]
                   initWithMessage:@"Cannot generate script for web bridge"
                   level:ADJAdjustLogLevelError
                   issueType:nil
                   resultFail:scriptSourceResult.fail
                   messageParams:nil]]
             logLevel:ADJAdjustLogLevelError];
        }
        return nil;
    }

    ADJAdjustBridge *_Nonnull bridge = [[ADJAdjustBridge alloc]
                                        initWithWithWKWebView:webView
                                        adjustLogSubscriber:adjustJsLogSubscriber];
    WKUserContentController *controller = webView.configuration.userContentController;
    [controller addUserScript:[[WKUserScript.class alloc]
                               initWithSource:scriptSourceResult.value
                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                               forMainFrameOnly:NO]];
    [controller addScriptMessageHandler:bridge name:@"adjust"];

    return bridge;
}

+ (nonnull ADJInputLogMessageData *)logWithMessage:(nonnull NSString *)message
                                        resultFail:(nullable ADJResultFail *)resultFail
{
    return  [[ADJInputLogMessageData alloc]
             initWithMessage:message
             level:ADJAdjustLogLevelDebug
             issueType:nil
             resultFail:resultFail
             messageParams:nil];
}

- (nonnull instancetype)
    initWithWithWKWebView:(nonnull WKWebView *)webView
    adjustLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustLogSubscriber
{
    self = [super init];
    ADJLogger *_Nonnull logger =
        [[ADJLogger alloc] initWithName:@"AdjustBridge"
                           logCollector:self
                             instanceId:[[ADJInstanceIdData alloc] initNonFirstWithClientId:nil]];

    _logSubscriber = adjustLogSubscriber;
    _logger = logger;
    _webViewCallback = [[ADJWebViewCallback alloc] initWithWebView:webView
                                                            logger:logger];
    _sdkApiHelper = [[ADJSdkApiHelper alloc] initWithLogger:logger
                                            webViewCallback:_webViewCallback];

    return self;
}
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (nonnull WKWebView *)webView {
    return self.webViewCallback.webView;
}

+ (nonnull ADJResult<NSString *> *)getAdjustWebBridgeScript {
    NSBundle *_Nonnull sourceBundle = [NSBundle bundleForClass:self.class];
    // requires that the file 'adjust.js' is in the same location/folder
    NSString *_Nullable adjustScriptPath = [sourceBundle pathForResource:@"adjust" ofType:@"js"];
    if  (adjustScriptPath == nil) {
        return [ADJResult failWithMessage:@"Cannot obtain adjust js path from bundle"];
    }

    NSError *_Nullable error;
    NSString *_Nullable adjustScript = [NSString stringWithContentsOfFile:adjustScriptPath
                                                                 encoding:NSUTF8StringEncoding
                                                                    error:nil];
    if (adjustScript == nil) {
        return [ADJResult failWithMessage:@"Cannot read adjust js file"
                              wasInputNil:NO
                             builderBlock:
                ^(ADJResultFailBuilder * _Nonnull resultFailBuilder) {
            [resultFailBuilder withError:error];
            [resultFailBuilder withKey:@"adjust js path"
                           stringValue:adjustScriptPath];
        }];
    }

    return [ADJResult okWithValue:adjustScript];
}

#pragma mark - ADJAdjustAttributionSubscriber
- (void)didReadWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    NSString *adjustAttributionString = adjustAttribution.description;
    NSString *javaScript = [NSString stringWithFormat:@"didReadWithAdjustAttribution('%@')",
                            adjustAttributionString];
    [self.webView evaluateJavaScript:javaScript completionHandler:nil];
}

- (void)didChangeWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    NSString *adjustAttributionString = adjustAttribution.description;
    NSString *javaScript = [NSString stringWithFormat:@"didChangeWithAdjustAttribution('%@')",
                            adjustAttributionString];
    [self.webView evaluateJavaScript:javaScript completionHandler:nil];
}

#pragma mark - ADJLogCollector
- (void)collectLogMessage:(nonnull ADJLogMessageData *)logMessageData {
    if (self.logSubscriber == nil) {
        NSLog(@"TORMV bridge logSubscriber = nil");
        return;
    }

    [self.logSubscriber didLogWithMessage:
     [ADJConsoleLogger clientCallbackFormatMessageWithLog:logMessageData.inputData]
                                 logLevel:logMessageData.inputData.level];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(nonnull WKUserContentController *)userContentController
      didReceiveScriptMessage:(nonnull WKScriptMessage *)message
{
    if (! [message.body isKindOfClass:[NSDictionary class]]) {
        [self.logger debugDev:@"Cannot handle script message with non-dictionary body"
                    issueType:ADJIssueNonNativeIntegration];
        return;
    }

    NSDictionary<NSString *, id> *_Nonnull body =
        (NSDictionary<NSString *, id> *)message.body;

    [self.logger debugDev:@"TORMV userContentController"
                      key:@"js body"
              stringValue:[[ADJUtilJson toStringFromDictionary:body] value]];

    ADJResult<ADJNonEmptyString *> *_Nonnull methodNameResult =
        [ADJNonEmptyString instanceFromObject:[body objectForKey:ADJWBMethodNameKey]];
    if (methodNameResult.fail != nil) {
        [self.logger debugDev:@"Cannot obtain methodName field from script body"
                      resultFail:methodNameResult.fail
                    issueType:ADJIssueNonNativeIntegration];
        return;
    }
    NSString *_Nonnull methodName = methodNameResult.value.stringValue;

    id _Nullable instanceIdObject = [body objectForKey:ADJWBInstanceIdKey];
    if (instanceIdObject == nil) {
        [self.logger debugDev:@"Cannot obtain instanceId field from script body"
                          key:@"method name"
                  stringValue:methodName
                    issueType:ADJIssueNonNativeIntegration];
        return;
    }
    if (! [instanceIdObject isKindOfClass:[NSString class]]) {
        [self.logger debugDev:@"Cannot use non-string instanceId field from script body"
                         key1:@"method name"
                 stringValue1:methodName
                         key2:ADJLogActualKey
                 stringValue2:NSStringFromClass([instanceIdObject class])
                    issueType:ADJIssueNonNativeIntegration];
        return;
    }
    NSString *_Nonnull instanceIdString = (NSString *)instanceIdObject;

    ADJResult<ADJNonEmptyString *> *_Nonnull parametersJsonStringResult =
        [ADJNonEmptyString instanceFromObject:[body objectForKey:ADJWBParametersKey]];
    if (parametersJsonStringResult.fail != nil) {
        [self.logger debugDev:@"Cannot obtain parameters field from script body"
                          key:@"method name"
                  stringValue:methodName
                   resultFail:parametersJsonStringResult.fail
                    issueType:ADJIssueNonNativeIntegration];
        return;
    }

    ADJResult<NSDictionary<NSString *, id> *> *_Nonnull parametersJsonDictionaryResult =
        [ADJUtilJson toDictionaryFromString:parametersJsonStringResult.value.stringValue];
    if (parametersJsonDictionaryResult.fail != nil) {
         [self.logger debugWithMessage:
          @"Cannot convert json string from parameters field to dictionary"
                          builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
             [logBuilder withKey:@"method name" stringValue:methodName];
             [logBuilder withKey:@"json string"
                     stringValue:parametersJsonStringResult.value.stringValue];
             [logBuilder withFail:parametersJsonDictionaryResult.fail
                            issue:ADJIssueNonNativeIntegration];
         }];
        return;
    }

    NSDictionary<NSString *, id> *_Nonnull jsParameters =
        parametersJsonDictionaryResult.value;

    if ([ADJWBInitSdkMethodName isEqualToString:methodName]) {
        ADJResultFail *_Nullable objectMatchFail =
            [ADJSdkApiHelper objectMatchesWithJsParameters:jsParameters
                                              expectedName:ADJWBAdjustConfigName];
        if (objectMatchFail != nil) {
            [self.logger debugDev:@"Cannot init sdk with non Adjust Config parameter"
                       resultFail:objectMatchFail
                        issueType:ADJIssueNonNativeIntegration];
            return;
        }

        ADJAdjustConfig *_Nonnull adjustConfig =
            [self.sdkApiHelper adjustConfigWithParametersJsonDictionary:jsParameters];

        NSDictionary<NSString *, id<ADJInternalCallback>> *_Nullable internalConfigSubscriptions =
            [self.sdkApiHelper
             extractInternalConfigSubscriptionsWithJsParameters:jsParameters
             instanceIdString:instanceIdString];

        [ADJAdjustInternal initSdkForClientId:instanceIdString
                                 adjustConfig:adjustConfig
                  internalConfigSubscriptions:internalConfigSubscriptions];

        return;
    }
    if ([ADJWBGetAdjustAttributionAsyncMethodName isEqualToString:methodName]) {
        id<ADJInternalCallback> _Nullable attributionGetterInternalCallback =
            [self.sdkApiHelper attributionGetterInternalCallbackWithJsParameters:jsParameters
                                                                instanceIdString:instanceIdString];
        if (attributionGetterInternalCallback != nil) {
            [ADJAdjustInternal adjustAttributionWithClientId:instanceIdString
                                            internalCallback:attributionGetterInternalCallback];
        }
        return;
    }
    if ([ADJWBGetAdjustDeviceIdsAsyncMethodName isEqualToString:methodName]) {
        id<ADJInternalCallback> _Nullable deviceIdsGetterInternalCallback =
            [self.sdkApiHelper deviceIdsGetterInternalCallbackWithJsParameters:jsParameters
                                                              instanceIdString:instanceIdString];
        if (deviceIdsGetterInternalCallback != nil) {
            [ADJAdjustInternal adjustDeviceIdsWithClientId:instanceIdString
                                          internalCallback:deviceIdsGetterInternalCallback];
        }
        return;
    }
    if ([ADJWBTrackEventMethodName isEqualToString:methodName]) {
        ADJResultFail *_Nullable objectMatchFail =
            [ADJSdkApiHelper objectMatchesWithJsParameters:jsParameters
                                              expectedName:ADJWBAdjustEventName];
        if (objectMatchFail != nil) {
            [self.logger debugDev:@"Cannot track event with non Adjust Event parameter"
                       resultFail:objectMatchFail
                        issueType:ADJIssueNonNativeIntegration];
            return;
        }

        ADJAdjustEvent *_Nonnull adjustEvent =
            [self.sdkApiHelper adjustEventWithJsParameters:jsParameters];
        NSArray *_Nullable callbackParameterKeyValueArray =
            [self.sdkApiHelper eventCallbackParameterKeyValueArrayWithJsParameters:jsParameters];
        NSArray *_Nullable partnerParameterKeyValueArray =
            [self.sdkApiHelper eventPartnerParameterKeyValueArrayWithJsParameters:jsParameters];

        [ADJAdjustInternal trackEventForClientId:instanceIdString
                                     adjustEvent:adjustEvent
                 callbackParameterKeyValueArray:callbackParameterKeyValueArray
                   partnerParameterKeyValueArray:partnerParameterKeyValueArray];
        return;
    }

    if ([ADJWBTrackThirdPartySharingMethodName isEqualToString:methodName]) {
        ADJResultFail *_Nullable objectMatchFail =
            [ADJSdkApiHelper objectMatchesWithJsParameters:jsParameters
                                              expectedName:ADJWBAdjustThirdPartySharingName];
        if (objectMatchFail != nil) {
            [self.logger debugDev:
             @"Cannot track third party sharing with non Adjust Third Party Sharing parameter"
                       resultFail:objectMatchFail
                        issueType:ADJIssueNonNativeIntegration];
            return;
        }

        ADJAdjustThirdPartySharing *_Nonnull adjustThirdPartySharing =
            [self.sdkApiHelper adjustThirdPartySharingWithJsParameters:jsParameters];
        NSArray *_Nullable granularOptionsByNameArray =
            [self.sdkApiHelper tpsGranulaOptionsByNameArrayWithJsParameters:jsParameters];
        NSArray *_Nullable partnerSharingSettingsByNameArray =
            [self.sdkApiHelper tpsPartnerSharingSettingsByNameArrayWithJsParameters:jsParameters];

        [ADJAdjustInternal trackThirdPartySharingForClientId:instanceIdString
                                     adjustThirdPartySharing:adjustThirdPartySharing
                                  granularOptionsByNameArray:granularOptionsByNameArray
                           partnerSharingSettingsByNameArray:partnerSharingSettingsByNameArray];
        return;
    }

    if ([ADJWBTrackAdRevenueMethodName isEqualToString:methodName]) {
        ADJResultFail *_Nullable objectMatchFail =
            [ADJSdkApiHelper objectMatchesWithJsParameters:jsParameters
                                              expectedName:ADJWBAdjustAdRevenueName];
        if (objectMatchFail != nil) {
            [self.logger debugDev:
             @"Cannot track ad revenue with non Adjust Ad Revenue parameter"
                       resultFail:objectMatchFail
                        issueType:ADJIssueNonNativeIntegration];
            return;
        }

        ADJAdjustAdRevenue *_Nonnull adjustAdRevenue =
            [self.sdkApiHelper adjustAdRevenueWithJsParameters:jsParameters];
        NSArray *_Nullable callbackParameterKeyValueArray =
            [self.sdkApiHelper adRevenueCallbackParameterKeyValueArrayWithJsParameters:jsParameters];
        NSArray *_Nullable partnerParameterKeyValueArray =
            [self.sdkApiHelper adRevenuePartnerParameterKeyValueArrayWithJsParameters:jsParameters];

        [ADJAdjustInternal trackAdRevenueForClientId:instanceIdString
                                     adjustAdRevenue:adjustAdRevenue
                      callbackParameterKeyValueArray:callbackParameterKeyValueArray
                       partnerParameterKeyValueArray:partnerParameterKeyValueArray];
        return;

    }
    /**
     TODO: check what makes sense (if anything) for web view billing subscriptions
        will it be using Apple Pay JS API https://developer.apple.com/documentation/apple_pay_on_the_web/apple_pay_js_api
        witth string amount https://developer.apple.com/documentation/apple_pay_on_the_web/applepaylineitem/1916086-amount
        that follows W3C valid decimal monetary value  https://www.w3.org/TR/payment-request/#dfn-valid-decimal-monetary-value
            if so -> a new MoneyStringAmount should be added
        or still using double or somehow the native decimal?
     */

    id<ADJAdjustInstance> _Nonnull adjustInstance = [ADJAdjust instanceForId:instanceIdString];

    if ([ADJWBInactivateSdkMethodName isEqualToString:methodName]) {
        [adjustInstance inactivateSdk];
    } else if ([ADJWBReactiveSdkMethodName isEqualToString:methodName]) {
        [adjustInstance reactivateSdk];
    } else if ([ADJWBGdprForgetDeviceMethodName isEqualToString:methodName]) {
        [adjustInstance gdprForgetDevice];
    } else if ([ADJWBAppWentToTheForegroundManualCallMethodName isEqualToString:methodName]) {
        [adjustInstance appWentToTheForegroundManualCall];
    } else if ([ADJWBAppWentToTheBackgroundManualCallMethodName isEqualToString:methodName]) {
        [adjustInstance appWentToTheBackgroundManualCall];
    } else if ([ADJWBOfflineModeMethodName isEqualToString:methodName]) {
        [adjustInstance switchToOfflineMode];
    } else if ([ADJWBOnlineModeMethodName isEqualToString:methodName]) {
        [adjustInstance switchBackToOnlineMode];
    // TODO add activateMeasurementConsent and inactivateMeasurementConsent
    // TODO add deviceIdsWithCallback and adjustAttributionWithCallback
    } else if ([ADJWBTrackLaunchedDeeplinkMethodName isEqualToString:methodName]) {
        [adjustInstance trackLaunchedDeeplink:
         [self.sdkApiHelper adjustLaunchedDeeplinkWithJsParameters:jsParameters]];
    } else if ([ADJWBTrackPushTokenMethodName isEqualToString:methodName]) {
        [adjustInstance trackPushToken:
         [self.sdkApiHelper adjustPushTokenWithJsParameters:jsParameters]];
    } else if ([ADJWBAddGlobalCallbackParameterMethodName isEqualToString:methodName]) {
        [adjustInstance
         addGlobalCallbackParameterWithKey:[self.sdkApiHelper
                                            stringLoggedWithJsParameters:jsParameters
                                            key:ADJWBKvKeyKey
                                            from:ADJWBAddGlobalCallbackParameterMethodName]
         value:[self.sdkApiHelper
                stringLoggedWithJsParameters:jsParameters
                key:ADJWBKvValueKey
                from:ADJWBAddGlobalCallbackParameterMethodName]];
    } else if ([ADJWBRemoveGlobalCallbackParameterByKeyMethodName isEqualToString:methodName]) {
        [adjustInstance removeGlobalCallbackParameterByKey:
         [self.sdkApiHelper
          stringLoggedWithJsParameters:jsParameters
          key:ADJWBKvKeyKey
          from:ADJWBRemoveGlobalCallbackParameterByKeyMethodName]];
    } else if ([ADJWBClearGlobalCallbackParametersMethodName isEqualToString:methodName]) {
        [adjustInstance clearGlobalCallbackParameters];
    } else if ([ADJWBAddGlobalPartnerParameterMethodName isEqualToString:methodName]) {
        [adjustInstance
         addGlobalPartnerParameterWithKey:[self.sdkApiHelper
                                           stringLoggedWithJsParameters:jsParameters
                                           key:ADJWBKvKeyKey
                                           from:ADJWBAddGlobalPartnerParameterMethodName]
         value:[self.sdkApiHelper
                stringLoggedWithJsParameters:jsParameters
                key:ADJWBKvValueKey
                from:ADJWBAddGlobalPartnerParameterMethodName]];
    } else if ([ADJWBRemoveGlobalPartnerParameterByKeyMethodName isEqualToString:methodName]) {
        [adjustInstance removeGlobalCallbackParameterByKey:
         [self.sdkApiHelper
          stringLoggedWithJsParameters:jsParameters
          key:ADJWBKvKeyKey
          from:ADJWBRemoveGlobalPartnerParameterByKeyMethodName]];
    } else if ([ADJWBClearGlobalPartnerParametersMethodName isEqualToString:methodName]) {
        [adjustInstance clearGlobalPartnerParameters];
    } else {
        [self.logger debugDev:@"Could not map method name with any of the possible values"
                         key1:@"method name"
                 stringValue1:methodName
                         key2:@"js parameters"
                 stringValue2:parametersJsonStringResult.value.stringValue];
    }
}

@end
