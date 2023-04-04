//
//  ADJAdjustBridge.m
//  AdjustSdkWebBridge
//
//  Created by Aditi Agrawal on 26/10/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

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

NS_ASSUME_NONNULL_BEGIN

NSString *const ADJAdjustBridgeMessageInitSdk = @"adjust_initSdk";
NSString *const ADJAdjustBridgeMessageSdkVersion = @"adjust_getSdkVersion";
NSString *const ADJAdjustBridgeMessageTrackEvent = @"adjust_trackEvent";
NSString *const ADJAdjustBridgeMessageTrackAdRevenue = @"adjust_trackAdRevenue";
NSString *const ADJAdjustBridgeMessageTrackPushToken = @"adjust_trackPushToken";
NSString *const ADJAdjustBridgeMessageTrackDeeplink = @"adjust_trackDeeplink";
NSString *const ADJAdjustBridgeMessageTrackThirdPartySharing = @"adjust_trackThirdPartySharing";
NSString *const ADJAdjustBridgeMessageInActivateSdk = @"adjust_inactivateSdk";
NSString *const ADJAdjustBridgeMessageReactiveSdk = @"adjust_reactivateSdk";
NSString *const ADJAdjustBridgeMessageOfflineMode = @"adjust_switchToOfflineMode";
NSString *const ADJAdjustBridgeMessageOnlineMode = @"adjust_switchBackToOnlineMode";
NSString *const ADJAdjustBridgeMessageGdprForgetMe = @"adjust_gdprForgetMe";
NSString *const ADJAdjustBridgeMessageAddGlobalCallbackParameter = @"adjust_addGlobalCallbackParameter";
NSString *const ADJAdjustBridgeMessageRemoveGlobalCallbackParameterByKey = @"adjust_removeGlobalCallbackParameterByKey";
NSString *const ADJAdjustBridgeMessageClearAllGlobalCallbackParameters = @"adjust_clearAllGlobalCallbackParameters";
NSString *const ADJAdjustBridgeMessageAddGlobalPartnerParameter = @"adjust_addGlobalPartnerParameter";
NSString *const ADJAdjustBridgeMessageRemoveGlobalPartnerParameterByKey = @"adjust_removeGlobalPartnerParameterByKey";
NSString *const ADJAdjustBridgeMessageClearAllGlobalPartnerParameters = @"adjust_clearAllGlobalPartnerParameters";
NSString *const ADJAdjustBridgeMessageAppWentToTheBackgroundManualCall = @"adjust_appWentToTheBackgroundManualCall";
NSString *const ADJAdjustBridgeMessageAppWentToTheForegroundManualCall = @"adjust_appWentToTheForegroundManualCall";

NS_ASSUME_NONNULL_END

@interface ADJAdjustBridge() <ADJAdjustAttributionSubscriber, WKScriptMessageHandler>

@end

@implementation ADJAdjustBridge

#pragma mark - Init Web View

+ (nullable ADJAdjustBridge *)instanceWithWKWebView:(nonnull WKWebView *)webView {
    if (! [webView isKindOfClass:WKWebView.class]) {
        return nil;
    }

    ADJResult<NSString *> *_Nonnull scriptSourceResult =
        [ADJAdjustBridge getAdjustWebBridgeScript];
    if (scriptSourceResult.fail != nil) {
        // TODO possibly add a way to return the fail message
        //  at least some internal API that can be accessed for this purpose
        return nil;
    }

    ADJAdjustBridge *_Nonnull bridge = [[ADJAdjustBridge alloc] initWithWithWKWebView:webView];
    WKUserContentController *controller = webView.configuration.userContentController;
    [controller addUserScript:[[WKUserScript.class alloc]
                               initWithSource:scriptSourceResult.value
                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                               forMainFrameOnly:NO]];
    [controller addScriptMessageHandler:bridge name:@"adjust"];

    return bridge;
}

- (nonnull instancetype)initWithWithWKWebView:(nonnull WKWebView *)webView {
    self = [super init];
    _webView = webView;

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

#pragma mark - Handle Message from Web View

- (void)userContentController:(nonnull WKUserContentController *)userContentController
      didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        [self handleMessageFromWebview:message.body];
    }
}

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

@end
