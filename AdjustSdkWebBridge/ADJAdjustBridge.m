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
/* Will be added in 'Refac: tps bridge' commit
        [ADJAdjustInternal trackThirdPartySharingForClientId:instanceIdString
                                     adjustThirdPartySharing:adjustThirdPartySharing
                                  granularOptionsByNameArray:granularOptionsByNameArray
                           partnerSharingSettingsByNameArray:partnerSharingSettingsByNameArray];
 */
        return;
    }


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
    } else if ([ADJWBTrackEventMethodName isEqualToString:methodName]) {
        ADJResultFail *_Nullable objectMatchFail =
            [ADJSdkApiHelper objectMatchesWithJsParameters:jsParameters
                                              expectedName:ADJWBAdjustEventName];
        if (objectMatchFail != nil) {
            [self.logger debugDev:@"Cannot track event with non Adjust Event parameter"
                       resultFail:objectMatchFail
                        issueType:ADJIssueNonNativeIntegration];
            return;
        }

        [adjustInstance trackEvent:[self.sdkApiHelper adjustEventWithJsParameters:jsParameters]];
    } else if ([ADJWBTrackLaunchedDeeplinkMethodName isEqualToString:methodName]) {
        [adjustInstance trackLaunchedDeeplink:
         [self.sdkApiHelper adjustLaunchedDeeplinkWithJsParameters:jsParameters]];
    } else if ([ADJWBTrackPushTokenMethodName isEqualToString:methodName]) {
        [adjustInstance trackPushToken:
         [self.sdkApiHelper adjustPushTokenWithJsParameters:jsParameters]];
    } else if ([ADJWBTrackAdRevenueMethodName isEqualToString:methodName]) {
        [adjustInstance trackAdRevenue:[self adRevenueWithJsParameters:jsParameters]];
    // TODO add trackBillingSubscription
    } else if ([ADJWBAddGlobalCallbackParameterMethodName isEqualToString:methodName]) {
        [adjustInstance
         addGlobalCallbackParameterWithKey:[self keyWithJsParameters:jsParameters]
         value:[self valueWithJsParameters:jsParameters]];
    } else if ([ADJWBRemoveGlobalCallbackParameterByKeyMethodName isEqualToString:methodName]) {
        [adjustInstance removeGlobalCallbackParameterByKey:
         [self keyWithJsParameters:jsParameters]];
    } else if ([ADJWBClearGlobalCallbackParametersMethodName isEqualToString:methodName]) {
        [adjustInstance clearGlobalCallbackParameters];
    } else if ([ADJWBAddGlobalPartnerParameterMethodName isEqualToString:methodName]) {
        [adjustInstance
         addGlobalPartnerParameterWithKey:[self keyWithJsParameters:jsParameters]
         value:[self valueWithJsParameters:jsParameters]];
    } else if ([ADJWBRemoveGlobalPartnerParameterByKeyMethodName isEqualToString:methodName]) {
        [adjustInstance removeGlobalPartnerParameterByKey:
         [self keyWithJsParameters:jsParameters]];
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


- (nonnull ADJAdjustAdRevenue *)adRevenueWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return nil;
}
- (nullable NSString *)keyWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return nil;
}
- (nullable NSString *)valueWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return nil;
}

/*
- (void)handleMessageFromWebview:(NSDictionary<NSString *,id> *)message {

    NSString *action = [message objectForKey:@"action"];
    NSString *instanceId = [message objectForKey:@"instanceId"];
    NSDictionary *data = [message objectForKey:@"data"];

    if ([action isEqual:ADJAdjustBridgeMessageInitSdk]) {

        [self sdkInitWithAdjustConfig:data forInstanceId:instanceId];

    }else if ([action isEqual:ADJAdjustBridgeMessageSdkVersion]) {

        // TODO: uncomment set prefix and "real" client sdk to send to test library
        //  when it's working correctly on the sdk
        //[ADJAdjustInternal setSdkPrefix:@"web-bridge5.0.0" fromInstanceWithClientId:instanceId];
        NSString *javaScript = [NSString stringWithFormat:@"TestLibraryBridge.getSdkVersion('%@')",
                                [ADJAdjustInternal sdkVersionWithSdkPrefix:nil]];//@"web-bridge5.0.0"]];
        [self.webView evaluateJavaScript:javaScript completionHandler:nil];

    } else  if ([action isEqual:ADJAdjustBridgeMessageTrackEvent]) {

        [self trackEvent:data forInstanceId:instanceId];

    } else if ([action isEqual:ADJAdjustBridgeMessageTrackAdRevenue]) {

        [self trackAdRevenue:data forInstanceId:instanceId];

    } else if ([action isEqual:ADJAdjustBridgeMessageTrackPushToken]) {

        if (![data isKindOfClass:[NSString class]]) {
            return;
        }

        ADJAdjustPushToken *pushToken = [[ADJAdjustPushToken alloc]
                                         initWithStringPushToken:(NSString *)data];

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] trackPushToken:pushToken];
        } else {
            [[ADJAdjust instance] trackPushToken:pushToken];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageTrackDeeplink]) {

        if (![data isKindOfClass:[NSString class]]) {
            return;
        }

        ADJAdjustLaunchedDeeplink *_Nonnull adjustLaunchedDeeplink =
        [[ADJAdjustLaunchedDeeplink alloc] initWithString:(NSString *)data];

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] trackLaunchedDeeplink:adjustLaunchedDeeplink];
        } else {
            [[ADJAdjust instance] trackLaunchedDeeplink:adjustLaunchedDeeplink];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageTrackThirdPartySharing]) {

        [self trackThirdPartySharing:data forInstanceId:instanceId];

    } else if ([action isEqual:ADJAdjustBridgeMessageOfflineMode]) {

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] switchToOfflineMode];
        } else {
            [[ADJAdjust instance] switchToOfflineMode];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageOnlineMode]) {

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] switchBackToOnlineMode];
        } else {
            [[ADJAdjust instance] switchBackToOnlineMode];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageInActivateSdk]) {

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] inactivateSdk];
        } else {
            [[ADJAdjust instance] inactivateSdk];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageReactiveSdk]) {

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] reactivateSdk];
        } else {
            [[ADJAdjust instance] reactivateSdk];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageAddGlobalCallbackParameter]) {

        NSString *key = [message objectForKey:@"key"];
        NSString *value = [message objectForKey:@"value"];

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] addGlobalCallbackParameterWithKey:key value:value];
        } else {
            [[ADJAdjust instance] addGlobalCallbackParameterWithKey:key value:value];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageRemoveGlobalCallbackParameterByKey]) {

        NSString *key = [message objectForKey:@"key"];
        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] removeGlobalCallbackParameterByKey:key];
        } else {
            [[ADJAdjust instance] removeGlobalCallbackParameterByKey:key];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageClearAllGlobalCallbackParameters]) {

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] clearAllGlobalCallbackParameters];
        } else {
            [[ADJAdjust instance] clearAllGlobalCallbackParameters];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageAddGlobalPartnerParameter]) {

        NSString *key = [message objectForKey:@"key"];
        NSString *value = [message objectForKey:@"value"];

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] addGlobalPartnerParameterWithKey:key value:value];
        } else {
            [[ADJAdjust instance] addGlobalPartnerParameterWithKey:key value:value];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageRemoveGlobalPartnerParameterByKey]) {

        NSString *key = [message objectForKey:@"key"];

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] removeGlobalPartnerParameterByKey:key];
        } else {
            [[ADJAdjust instance] removeGlobalPartnerParameterByKey:key];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageClearAllGlobalPartnerParameters]) {

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] clearAllGlobalPartnerParameters];
        } else {
            [[ADJAdjust instance] clearAllGlobalPartnerParameters];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageGdprForgetMe]) {

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] gdprForgetDevice];
        } else {
            [[ADJAdjust instance] gdprForgetDevice];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageAppWentToTheBackgroundManualCall]) {

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] appWentToTheBackgroundManualCall];
        } else {
            [[ADJAdjust instance] appWentToTheBackgroundManualCall];
        }

    } else if ([action isEqual:ADJAdjustBridgeMessageAppWentToTheForegroundManualCall]) {

        if ([self isInstanceIdValid:instanceId]) {
            [[ADJAdjust instanceForId:instanceId] appWentToTheForegroundManualCall];
        } else {
            [[ADJAdjust instance] appWentToTheForegroundManualCall];
        }

    } else if ([action isEqual:@"adjust_teardown"]) {
        // TODO: Do we need this?
    }
}
 */

- (void)sdkInitWithAdjustConfig:(NSDictionary *)data forInstanceId:(nullable NSString *)instanceId {

    NSString *appToken = [data objectForKey:@"appToken"];
    NSString *environment = [data objectForKey:@"environment"];
    NSString *customEndpointUrl = [data objectForKey:@"customEndpointUrl"];
    NSNumber *eventDeduplicationListLimit = [data objectForKey:@"eventDeduplicationListLimit"];
    NSString *customEndpointPublicKeyHash = [data objectForKey:@"customEndpointPublicKeyHash"];
    NSString *defaultTracker = [data objectForKey:@"defaultTracker"];
    NSNumber *sendInBackground = [data objectForKey:@"sendInBackground"];
    NSString *logLevel = [data objectForKey:@"logLevel"];
    NSNumber *openDeferredDeeplinkDeactivated = [data objectForKey:@"openDeferredDeeplinkDeactivated"];
    NSString *attributionCallback = [data objectForKey:@"attributionCallback"];
    NSNumber *allowAdServicesInfoReading = [data objectForKey:@"allowAdServicesInfoReading"];
    NSString *urlStrategy = [data objectForKey:@"urlStrategy"];
    //TODO: Features to be implemented.
    //    NSNumber *coppaCompliantEnabled = [data objectForKey:@"coppaCompliantEnabled"];
    //    NSNumber *linkMeEnabled = [data objectForKey:@"linkMeEnabled"];
    //    NSNumber *allowiAdInfoReading = [data objectForKey:@"allowiAdInfoReading"];
    //    NSNumber *allowIdfaReading = [data objectForKey:@"allowIdfaReading"];
    //    NSNumber *allowSkAdNetworkHandling = [data objectForKey:@"allowSkAdNetworkHandling"];

    ADJAdjustConfig *adjustConfig = [[ADJAdjustConfig alloc] initWithAppToken:appToken
                                                                  environment:environment];

    if ([logLevel isEqual:@"ALL"]) {
        [adjustConfig doLogAll];
    } else {
        [adjustConfig doNotLogAny];
    }

    [adjustConfig setUrlStrategyBaseDomain:urlStrategy];
    [adjustConfig setDefaultTracker:defaultTracker];
    [adjustConfig setCustomEndpointWithUrl:customEndpointUrl
                  optionalPublicKeyKeyHash:customEndpointPublicKeyHash];

    if (attributionCallback != nil) {
        [adjustConfig setAdjustAttributionSubscriber:self];
    }

    if ([self isFieldValid:allowAdServicesInfoReading]) {
        if ([allowAdServicesInfoReading boolValue] == NO) {
            [adjustConfig doNotReadAppleSearchAdsAttributionNumberBool];
        }
    }

    if ([self isFieldValid:openDeferredDeeplinkDeactivated]) {
        if ([openDeferredDeeplinkDeactivated boolValue] == NO) {
            [adjustConfig doNotOpenDeferredDeeplinkNumberBool];
        }
    }

    if ([self isFieldValid:sendInBackground]) {
        if ([sendInBackground boolValue]) {
            [adjustConfig allowSendingFromBackground];
        }
    }

    if ([self isFieldValid:eventDeduplicationListLimit]) {
        [adjustConfig setEventIdDeduplicationMaxCapacity:[eventDeduplicationListLimit intValue]];
    }

    if ([self isInstanceIdValid:instanceId]) {
        [[ADJAdjust instanceForId:instanceId] initSdkWithConfig:adjustConfig];
    } else {
        [[ADJAdjust instance] initSdkWithConfig:adjustConfig];
    }
}

- (void)trackEvent:(NSDictionary *)data forInstanceId:(nullable NSString *)instanceId {

    NSString *eventToken = [data objectForKey:@"eventId"];
    NSNumber *revenue = [data objectForKey:@"revenue"];
    NSString *currency = [data objectForKey:@"currency"];
    NSString *deduplicationId = [data objectForKey:@"deduplicationId"];
    NSArray *callbackParameters = [data objectForKey:@"callbackParameters"];
    NSArray *partnerParameters = [data objectForKey:@"partnerParameters"];

    ADJAdjustEvent *_Nonnull adjustEvent = [[ADJAdjustEvent alloc] initWithEventToken:eventToken];
    [adjustEvent setRevenueWithDoubleNumber:revenue currency:currency];
    [adjustEvent setDeduplicationId:deduplicationId];

    for (int i = 0; i < [callbackParameters count]; i += 2) {
        NSString *key = [callbackParameters objectAtIndex:i];
        NSString *value = [callbackParameters objectAtIndex:(i + 1)];
        [adjustEvent addCallbackParameterWithKey:key value:value];
    }

    for (int i = 0; i < [partnerParameters count]; i += 2) {
        NSString *key = [partnerParameters objectAtIndex:i];
        NSString *value = [partnerParameters objectAtIndex:(i + 1)];
        [adjustEvent addPartnerParameterWithKey:key value:value];
    }

    if ([self isInstanceIdValid:instanceId]) {
        [[ADJAdjust instanceForId:instanceId] trackEvent:adjustEvent];
    } else {
        [[ADJAdjust instance] trackEvent:adjustEvent];
    }
}

- (void)trackAdRevenue:(NSDictionary *)data forInstanceId:(nullable NSString *)instanceId {

    NSString *adRevenueSource = [data objectForKey:@"source"];
    NSNumber *revenue = [data objectForKey:@"revenue"];
    NSNumber *adImpressionsCount = [data objectForKey:@"adImpressionsCount"];
    NSString *currency = [data objectForKey:@"currency"];
    NSString *adRevenueNetwork = [data objectForKey:@"adRevenueNetwork"];
    NSString *adRevenueUnit = [data objectForKey:@"adRevenueUnit"];
    NSString *adRevenuePlacement = [data objectForKey:@"adRevenuePlacement"];
    NSArray *callbackParameters = [data objectForKey:@"callbackParameters"];
    NSArray *partnerParameters = [data objectForKey:@"partnerParameters"];

    ADJAdjustAdRevenue *_Nonnull adjustAdRevenue = [[ADJAdjustAdRevenue alloc]
                                                    initWithSource:adRevenueSource];
    [adjustAdRevenue setRevenueWithDoubleNumber:revenue currency:currency];
    [adjustAdRevenue setAdImpressionsCountWithIntegerNumber:adImpressionsCount];
    [adjustAdRevenue setNetwork:adRevenueNetwork];
    [adjustAdRevenue setUnit:adRevenueUnit];
    [adjustAdRevenue setPlacement:adRevenuePlacement];

    for (int i = 0; i < [callbackParameters count]; i += 2) {
        NSString *key = [callbackParameters objectAtIndex:i];
        NSString *value = [callbackParameters objectAtIndex:(i + 1)];
        [adjustAdRevenue addCallbackParameterWithKey:key value:value];
    }

    for (int i = 0; i < [partnerParameters count]; i += 2) {
        NSString *key = [partnerParameters objectAtIndex:i];
        NSString *value = [partnerParameters objectAtIndex:(i + 1)];
        [adjustAdRevenue addPartnerParameterWithKey:key value:value];
    }

    if ([self isInstanceIdValid:instanceId]) {
        [[ADJAdjust instanceForId:instanceId] trackAdRevenue:adjustAdRevenue];
    } else {
        [[ADJAdjust instance] trackAdRevenue:adjustAdRevenue];
    }
}

- (void)trackThirdPartySharing:(NSDictionary *)data forInstanceId:(nullable NSString *)instanceId {

    id isEnabledO = [data objectForKey:@"isEnabled"];
    NSArray *granularOptions = [data objectForKey:@"granularOptions"];
    NSArray *partnerSharingSettings = [data objectForKey:@"partnerSharingSettings"];

    NSNumber *isEnabled = nil;
    if ([isEnabledO isKindOfClass:[NSNumber class]]) {
        isEnabled = (NSNumber *)isEnabledO;
    }

    ADJAdjustThirdPartySharing *adjustThirdPartySharing = [[ADJAdjustThirdPartySharing alloc] init];

    if ([self isFieldValid:isEnabled]) {
        if ([isEnabled boolValue]) {
            [adjustThirdPartySharing enableThirdPartySharing];
        } else {
            [adjustThirdPartySharing disableThirdPartySharing];
        }
    }

    for (int i = 0; i < [granularOptions count]; i += 3) {
        NSString *partnerName = [granularOptions objectAtIndex:i];
        NSString *key = [granularOptions objectAtIndex:(i + 1)];
        NSString *value = [granularOptions objectAtIndex:(i + 2)];
        [adjustThirdPartySharing addGranularOptionWithPartnerName:partnerName key:key value:value];
    }

    for (int i = 0; i < [partnerSharingSettings count]; i += 3) {
        NSString *partnerName = [partnerSharingSettings objectAtIndex:i];
        NSString *key = [partnerSharingSettings objectAtIndex:(i + 1)];
        BOOL value = [[partnerSharingSettings objectAtIndex:(i + 2)] boolValue];
        [adjustThirdPartySharing addPartnerSharingSettingWithPartnerName:partnerName
                                                                     key:key value:value];
    }

    if ([self isInstanceIdValid:instanceId]) {
        [[ADJAdjust instanceForId:instanceId] trackThirdPartySharing:adjustThirdPartySharing];
    } else {
        [[ADJAdjust instance] trackThirdPartySharing:adjustThirdPartySharing];
    }
}

#pragma mark - Adjust Internal methods

#pragma mark - Helper methods
- (BOOL)isFieldValid:(NSObject *)field {
    if (field == nil) {
        return NO;
    }
    if ([field isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if ([[field description] length] == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)isInstanceIdValid:(NSObject *)field {
    if ([field isKindOfClass:[NSString class]]) {
        return YES;
    }
    return NO;
}

@end
