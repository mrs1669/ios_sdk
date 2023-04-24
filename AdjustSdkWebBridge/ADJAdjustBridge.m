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
#import "ADJResult.h"
#import "ADJConstants.h"
#import "ADJWebBridgeConstants.h"
#import "ADJInputLogMessageData.h"
#import "ADJConsoleLogger.h"
#import "ADJUtilConv.h"
#import "ADJBooleanWrapper.h"

#pragma mark Fields
@interface ADJAdjustBridge() <ADJAdjustAttributionSubscriber, WKScriptMessageHandler>

@property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> logSubscriber;
@property (nullable, readonly, strong, nonatomic) ADJLogger *logger;

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

    ADJLogger *_Nonnull logger = [[ADJLogger alloc] initWithName:@"AdjustBridge"
                                                    logCollector:nil
                                                      instanceId:[[ADJInstanceIdData alloc]
                                                                  initNonFirstWithClientId:nil]];

    ADJResult<NSString *> *_Nonnull scriptSourceResult =
        [ADJAdjustBridge getAdjustWebBridgeScript];
    if (scriptSourceResult.fail != nil) {
        if (adjustJsLogSubscriber != nil) {
            [adjustJsLogSubscriber
             didLogWithMessage:
                 [ADJConsoleLogger clientCallbackFormatMessageWithLog:
                 [logger errorClient:@"Cannot generate script for web bridge"
                          resultFail:scriptSourceResult.fail]]
             logLevel:ADJAdjustLogLevelError];
        }
        return nil;
    }

    ADJAdjustBridge *_Nonnull bridge = [[ADJAdjustBridge alloc]
                                        initWithWithWKWebView:webView
                                        adjustLogSubscriber:adjustJsLogSubscriber
                                        logger:logger];
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
    logger:(nonnull ADJLogger *)logger
{
    self = [super init];
    _webView = webView;
    _logSubscriber = adjustLogSubscriber;
    _logger = logger;

    return self;
}
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
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

- (void)errorWithLogData:(nonnull ADJInputLogMessageData *)logData {
    [self logWithData:logData logLevel:ADJAdjustLogLevelError];
}

- (void)logWithData:(nonnull ADJInputLogMessageData *)logData
           logLevel:(nonnull ADJAdjustLogLevel)logLevel
{
    if (self.logSubscriber == nil) {
        return;
    }

    [self.logSubscriber
     didLogWithMessage:[ADJConsoleLogger clientCallbackFormatMessageWithLog:logData]
     logLevel:logLevel];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(nonnull WKUserContentController *)userContentController
      didReceiveScriptMessage:(nonnull WKScriptMessage *)message
{
    if (! [message.body isKindOfClass:[NSDictionary class]]) {
        [self errorWithLogData:
         [self.logger errorClient:@"Cannot handle script message with non-dictionary body"]];
        return;
    }

    NSDictionary<NSString *, NSString *> *_Nonnull body =
    (NSDictionary<NSString *, id> *)message.body;

    ADJResult<ADJNonEmptyString *> *_Nonnull methodNameResult =
        [ADJNonEmptyString instanceFromObject:[body objectForKey:ADJWBMethodNameKey]];
    if (methodNameResult.fail != nil) {
        [self errorWithLogData:
         [self.logger errorClient:@"Cannot obtain methodName field from script body"
                       resultFail:methodNameResult.fail]];
        return;
    }
    NSString *_Nonnull methodName = methodNameResult.value.stringValue;

    ADJResult<ADJNonEmptyString *> *_Nonnull instanceIdResult =
        [ADJNonEmptyString instanceFromObject:[body objectForKey:ADJWBInstanceIdKey]];
    if (instanceIdResult.fail != nil) {
        [self errorWithLogData:
         [self.logger debugDev:@"Cannot obtain instanceId field from script body"
                           key:@"method name"
                         value:methodName
                    resultFail:instanceIdResult.fail
                     issueType:nil]];
        return;
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull jsParametersResult =
        [ADJNonEmptyString instanceFromObject:[body objectForKey:ADJWBParametersKey]];
    if (jsParametersResult.fail != nil) {
        [self errorWithLogData:
         [self.logger debugDev:@"Cannot obtain parameters field from script body"
                           key:@"method name"
                         value:methodName
                    resultFail:jsParametersResult.fail
                     issueType:nil]];
        return;
    }

    ADJResult<NSDictionary<NSString *, id> *> *_Nonnull jsParametersDictionaryResult =
        [ADJUtilJson toDictionaryFromString:jsParametersResult.value.stringValue];
    if (jsParametersDictionaryResult.fail != nil) {
        [self errorWithLogData:
         [self.logger debugDev:@"Cannot convert JSON string from parameters field"
                           key:@"method name"
                         value:methodName
                    resultFail:jsParametersDictionaryResult.fail
                     issueType:nil]];
        return;
    }

    NSDictionary<NSString *, id> *_Nonnull jsParameters = jsParametersDictionaryResult.value;

    id<ADJAdjustInstance> _Nonnull adjustInstance =
        [ADJAdjust instanceForId:instanceIdResult.value.stringValue];

    if ([ADJWBInitSdkMethodName isEqualToString:methodName]) {
        [adjustInstance initSdkWithConfig:[self adjustConfigWithJsParameters:jsParameters]];
    } else if ([ADJWBInactivateSdkMethodName isEqualToString:methodName]) {
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
        [adjustInstance trackEvent:[self adjustEventWithJsParameters:jsParameters]];
    } else if ([ADJWBTrackLaunchedDeeplinkMethodName isEqualToString:methodName]) {
        [adjustInstance trackLaunchedDeeplink:
         [self adjustLaunchedDeeplinkWithJsParameters:jsParameters]];
    } else if ([ADJWBTrackPushTokenMethodName isEqualToString:methodName]) {
        [adjustInstance trackPushToken:[self adjustPushTokenWithJsParameters:jsParameters]];
    } else if ([ADJWBTrackThirdPartySharingMethodName isEqualToString:methodName]) {
        [adjustInstance trackThirdPartySharing:
         [self adjustThirdPartySharingWithJsParameters:jsParameters]];
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
        [self errorWithLogData:
         [self.logger debugDev:@"Could not map method name with any of the possible values"
                          key1:@"method name"
                        value1:methodName
                          key2:@"Js parameters"
                        value2:jsParametersResult.value.stringValue]];
    }
}

- (nonnull ADJAdjustConfig *)adjustConfigWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    NSString *_Nullable appTokenResult =
        [self stringConfigWithJsParameters:jsParameters key:ADJWBAppTokenConfigKey];

    NSString *_Nullable environmentResult =
        [self stringConfigWithJsParameters:jsParameters key:ADJWBEnvironmentConfigKey];


    ADJAdjustConfig *_Nonnull adjustConfig = [[ADJAdjustConfig alloc]
                                              initWithAppToken:appTokenResult
                                              environment:environmentResult];

    NSString *_Nullable defaultTracker =
        [self stringConfigWithJsParameters:jsParameters key:ADJWBDefaultTrackerConfigKey];
    if (defaultTracker != nil) {
        [adjustConfig setDefaultTracker:defaultTracker];
    }

    if ([self trueConfigWithJsParameters:jsParameters key:ADJWBDoLogAllConfigKey]) {
        [adjustConfig doLogAll];
    }

    if ([self trueConfigWithJsParameters:jsParameters key:ADJWBDoNotLogAnyConfigKey]) {
        [adjustConfig doNotLogAny];
    }

    NSString *_Nullable urlStrategy =
        [self stringConfigWithJsParameters:jsParameters key:ADJWBUrlStrategyConfigKey];
    if (urlStrategy != nil) {
        [adjustConfig setDefaultTracker:urlStrategy];
    }

    NSString *_Nullable customEndpoint =
        [self stringConfigWithJsParameters:jsParameters key:ADJWBCustomEndpointUrlConfigKey];
    NSString *_Nullable customEndpointPublicKeyHash =
        [self stringConfigWithJsParameters:jsParameters
                                       key:ADJWBCustomEndpointPublicKeyHashConfigKey];
    if (customEndpoint != nil || customEndpointPublicKeyHash != nil) {
        [adjustConfig setCustomEndpointWithUrl:customEndpoint
                      optionalPublicKeyKeyHash:customEndpointPublicKeyHash];
    }

    if ([self trueConfigWithJsParameters:jsParameters
                                     key:ADJWBDoNotOpenDeferredDeeplinkConfigKey])
    {
        [adjustConfig preventOpenDeferredDeeplink];
    }

    if ([self trueConfigWithJsParameters:jsParameters
                                     key:ADJWBDoNotReadAppleSearchAdsAttributionConfigKey])
    {
        [adjustConfig doNotReadAppleSearchAdsAttribution];
    }

    if ([self trueConfigWithJsParameters:jsParameters
                                     key:ADJWBCanSendInBackgroundConfigKey])
    {
        [adjustConfig allowSendingFromBackground];
    }

    ADJResult<NSNumber *> *_Nonnull eventIdDeduplicationMaxCapacityResult =
        [self intWithJsParameters:jsParameters key:ADJWBEventIdDeduplicationMaxCapacityConfigKey];
    if (eventIdDeduplicationMaxCapacityResult.failNonNilInput != nil) {
        [self errorWithLogData:
         [self.logger debugDev:@"Could not parse JS field for adjust config"
                           key:@"field name"
                         value:ADJWBEventIdDeduplicationMaxCapacityConfigKey
                    resultFail:eventIdDeduplicationMaxCapacityResult.fail
                     issueType:nil]];
    } else {
        [adjustConfig setEventIdDeduplicationMaxCapacity:
         eventIdDeduplicationMaxCapacityResult.value.intValue];
    }

    // TODO: set subscriptions

    return adjustConfig;
}
- (nullable NSString *)
    stringConfigWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
{
    ADJResult<NSString *> *_Nonnull stringResult =
        [self stringWithJsParameters:jsParameters key:key];
    if (stringResult.failNonNilInput != nil) {
        [self errorWithLogData:
         [self.logger debugDev:@"Could not parse JS field for adjust config"
                           key:@"field name"
                         value:key
                    resultFail:stringResult.fail
                     issueType:nil]];
    }

    return stringResult.value;
}
- (BOOL)trueConfigWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
                               key:(nonnull NSString *)key
{
    ADJResult<ADJBooleanWrapper *> *_Nonnull trueResult =
        [self trueWithJsParameters:jsParameters key:key];
    if (trueResult.failNonNilInput != nil) {
        [self errorWithLogData:
         [self.logger debugDev:@"Could not parse boolean JS field for adjust config"
                           key:@"boolean field name"
                         value:key
                    resultFail:trueResult.fail
                     issueType:nil]];
    }

    return trueResult.value != nil;
}


- (nonnull ADJAdjustEvent *)adjustEventWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return nil;
}
- (nonnull ADJAdjustLaunchedDeeplink *)adjustLaunchedDeeplinkWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return nil;
}
- (nonnull ADJAdjustPushToken *)adjustPushTokenWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return nil;
}
- (nonnull ADJAdjustThirdPartySharing *)adjustThirdPartySharingWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return nil;
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

#pragma mark - Private & helper methods

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

- (nonnull ADJResult<NSString *> *)
    stringWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
{
    id _Nullable typeObject =
        [jsParameters objectForKey:[NSString stringWithFormat:@"%@Type", key]];

    ADJResult<ADJNonEmptyString *> *_Nonnull typeResult =
        [ADJNonEmptyString instanceFromObject:typeObject];

    if (typeResult.wasInputNil) {
        return [ADJResult nilInputWithMessage:
                @"Cannot convert nil type object to string"];
    }

    if (typeResult.fail != nil) {
        return [ADJResult failWithMessage:@"Invalid JS type"
                                      key:@"js type fail"
                                otherFail:typeResult.fail];
    }

    if (! [typeResult.value.stringValue isEqualToString:ADJWBJsStringType]) {
        return [ADJResult failWithMessage:@"Expected string JS type"
                                      key:ADJLogActualKey
                              stringValue:typeResult.value.stringValue];
    }

    id _Nullable valueObject = [jsParameters objectForKey:key];

    ADJResult<ADJNonEmptyString *> *_Nonnull valueResult =
        [ADJNonEmptyString instanceFromObject:valueObject];
    if (valueResult.fail != nil) {
        return [ADJResult failWithMessage:@"Invalid JS string value"
                                      key:@"js string fail"
                                otherFail:valueResult.fail];
    }

    return [ADJResult okWithValue:valueResult.value.stringValue];
}

- (nonnull ADJResult<NSNumber *> *)
    intWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
{
    id _Nullable typeObject =
        [jsParameters objectForKey:[NSString stringWithFormat:@"%@Type", key]];

    ADJResult<ADJNonEmptyString *> *_Nonnull typeResult =
        [ADJNonEmptyString instanceFromObject:typeObject];

    if (typeResult.wasInputNil) {
        return [ADJResult nilInputWithMessage:
                @"Cannot convert nil type object to string"];
    }

    if (typeResult.fail != nil) {
        return [ADJResult failWithMessage:@"Invalid JS type"
                                      key:@"js type fail"
                                otherFail:typeResult.fail];
    }

    if (! [typeResult.value.stringValue isEqualToString:ADJWBJsNumberType]) {
        return [ADJResult failWithMessage:@"Expected number JS type"
                                      key:ADJLogActualKey
                              stringValue:typeResult.value.stringValue];
    }

    id _Nullable valueObject = [jsParameters objectForKey:key];

    ADJResult<ADJNonNegativeInt *> *_Nonnull valueResult =
        [ADJNonNegativeInt instanceFromObject:valueObject];
    if (valueResult.fail != nil) {
        return [ADJResult failWithMessage:@"Invalid JS int value"
                                      key:@"js int fail"
                                otherFail:valueResult.fail];
    }

    return [ADJResult okWithValue:@(valueResult.value.uIntegerValue)];
}

/*
 NSNumber *_Nonnull eventIdDeduplicationMaxCapacity =
     [self intConfigWithJsParameters:jsParameters
                                 key:ADJWBEventIdDeduplicationMaxCapacityConfigKey];

 */

- (nonnull ADJResult<ADJBooleanWrapper *> *)
    trueWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
 {
     /*
     id _Nullable typeObject =
        [jsParameters objectForKey:[NSString stringWithFormat:@"%@Type", key]];

     ADJResultNL<ADJNonEmptyString *> *_Nonnull typeResult =
         [ADJNonEmptyString instanceFromOptionalObject:typeObject];
     if (typeResult != nil) {
         return [ADJResultNL failWithMessage:@"Invalid JS type"
                                         key:@"js type fail"
                                   otherFail:typeResult.fail];
     }
     if (typeResult.value == nil) {
         return [ADJResultNL okWithoutValue];
     }

     if (! [typeResult.value.stringValue isEqualToString:ADJWBJsBooleanType]) {
         return [ADJResultNL failWithMessage:@"Expected boolean JS type"
                                         key:ADJLogActualKey
                                 stringValue:typeResult.value.stringValue];
     }

     id _Nullable valueObject = [jsParameters objectForKey:key];
     ADJResultNN<ADJBooleanWrapper *> *_Nonnull valueResult =
        [ADJBooleanWrapper instanceFromObject:valueObject];
     if (valueResult.fail != nil) {
         return [ADJResultNL failWithMessage:@"Invalid JS boolean value"
                                         key:@"js boolean fail"
                                   otherFail:valueResult.fail];
     }

     if (valueResult.value.boolValue) {
         return [ADJResultNL okWithValue:valueResult.value];
     } else {
         return [ADJResultNL okWithoutValue];
     }
      */

     id _Nullable valueObject = [jsParameters objectForKey:key];
     ADJResult<ADJBooleanWrapper *> *_Nonnull valueResult =
        [ADJBooleanWrapper instanceFromObject:valueObject];
     if (valueResult.failNonNilInput != nil) {
         return [ADJResult failWithMessage:@"Invalid JS boolean value"
                                       key:@"js boolean fail"
                                 otherFail:valueResult.fail];
     }

     if (! valueResult.value.boolValue) {
         return [ADJResult failWithMessage:@"JS boolean field was not expected to be false"];
     }

     return valueResult;
}

@end
