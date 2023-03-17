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

- (void)augmentHybridWKWebView:(WKWebView *_Nonnull)webView {
    if ([webView isKindOfClass:WKWebView.class]) {
        self.webView = webView;
        WKUserContentController *controller = webView.configuration.userContentController;
        [controller addUserScript:[[WKUserScript.class alloc]
                                   initWithSource:[self getWebBridgeScriptFor:@"adjust"]
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                   forMainFrameOnly:NO]];
        [controller addScriptMessageHandler:self name:@"adjust"];
    }
}

- (NSString *)getWebBridgeScriptFor:(NSString *)resource {
    NSBundle *sourceBundle = [NSBundle bundleForClass:self.class];
    NSString *adjustScriptPath = [sourceBundle pathForResource:resource ofType:@"js"];
    NSString *adjustScript = [NSString stringWithContentsOfFile:adjustScriptPath
                                                       encoding:NSUTF8StringEncoding error:nil];
    return adjustScript;
}

#pragma mark - Attribution callbacks

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

        NSString *javaScript = [NSString stringWithFormat:@"TestLibraryBridge.getSdkVersion('%@')",
                                [ADJAdjustInternal sdkVersion]];
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
        [[ADJAdjust instanceForId:instanceId] trackPushToken:pushToken];

    } else if ([action isEqual:ADJAdjustBridgeMessageTrackDeeplink]) {

        if (![data isKindOfClass:[NSString class]]) {
            return;
        }

        ADJAdjustLaunchedDeeplink *_Nonnull adjustLaunchedDeeplink =
        [[ADJAdjustLaunchedDeeplink alloc] initWithString:(NSString *)data];
        [[ADJAdjust instanceForId:instanceId] trackLaunchedDeeplink:adjustLaunchedDeeplink];

    } else if ([action isEqual:ADJAdjustBridgeMessageTrackThirdPartySharing]) {

        [self trackThirdPartySharing:data forInstanceId:instanceId];

    } else if ([action isEqual:ADJAdjustBridgeMessageOfflineMode]) {

        [[ADJAdjust instanceForId:instanceId] switchToOfflineMode];

    } else if ([action isEqual:ADJAdjustBridgeMessageOnlineMode]) {

        [[ADJAdjust instanceForId:instanceId] switchBackToOnlineMode];

    } else if ([action isEqual:ADJAdjustBridgeMessageInActivateSdk]) {

        [[ADJAdjust instanceForId:instanceId] inactivateSdk];

    } else if ([action isEqual:ADJAdjustBridgeMessageReactiveSdk]) {

        [[ADJAdjust instanceForId:instanceId] reactivateSdk];

    } else if ([action isEqual:ADJAdjustBridgeMessageAddGlobalCallbackParameter]) {

        NSString *key = [message objectForKey:@"key"];
        NSString *value = [message objectForKey:@"value"];
        [[ADJAdjust instanceForId:instanceId] addGlobalCallbackParameterWithKey:key value:value];

    } else if ([action isEqual:ADJAdjustBridgeMessageRemoveGlobalCallbackParameterByKey]) {

        NSString *key = [message objectForKey:@"key"];
        [[ADJAdjust instanceForId:instanceId] removeGlobalCallbackParameterByKey:key];

    } else if ([action isEqual:ADJAdjustBridgeMessageClearAllGlobalCallbackParameters]) {

        [[ADJAdjust instanceForId:instanceId] clearAllGlobalCallbackParameters];

    } else if ([action isEqual:ADJAdjustBridgeMessageAddGlobalPartnerParameter]) {

        NSString *key = [message objectForKey:@"key"];
        NSString *value = [message objectForKey:@"value"];
        [[ADJAdjust instanceForId:instanceId] addGlobalPartnerParameterWithKey:key value:value];

    } else if ([action isEqual:ADJAdjustBridgeMessageRemoveGlobalPartnerParameterByKey]) {

        NSString *key = [message objectForKey:@"key"];
        [[ADJAdjust instanceForId:instanceId] removeGlobalPartnerParameterByKey:key];

    } else if ([action isEqual:ADJAdjustBridgeMessageClearAllGlobalPartnerParameters]) {

        [[ADJAdjust instanceForId:instanceId] clearAllGlobalPartnerParameters];

    } else if ([action isEqual:ADJAdjustBridgeMessageGdprForgetMe]) {

        [[ADJAdjust instanceForId:instanceId] gdprForgetDevice];

    } else if ([action isEqual:ADJAdjustBridgeMessageAppWentToTheBackgroundManualCall]) {

        [[ADJAdjust instanceForId:instanceId] appWentToTheBackgroundManualCall];

    } else if ([action isEqual:ADJAdjustBridgeMessageAppWentToTheForegroundManualCall]) {

        [[ADJAdjust instanceForId:instanceId] appWentToTheForegroundManualCall];

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

    [adjustConfig setUrlStrategy:urlStrategy];
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

    [[ADJAdjust instanceForId:instanceId] initSdkWithConfiguration:adjustConfig];
}

- (void)trackEvent:(NSDictionary *)data forInstanceId:(nullable NSString *)instanceId {

    NSString *eventToken = [data objectForKey:@"eventId"];
    NSNumber *revenue = [data objectForKey:@"revenue"];
    NSString *currency = [data objectForKey:@"currency"];
    NSString *deduplicationId = [data objectForKey:@"deduplicationId"];
    NSArray *callbackParameters = [data objectForKey:@"callbackParameters"];
    NSArray *partnerParameters = [data objectForKey:@"partnerParameters"];

    ADJAdjustEvent *_Nonnull adjustEvent = [[ADJAdjustEvent alloc] initWithEventId:eventToken];
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

    [[ADJAdjust instanceForId:instanceId] trackEvent:adjustEvent];
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
    [adjustAdRevenue setAdRevenueNetwork:adRevenueNetwork];
    [adjustAdRevenue setAdRevenueUnit:adRevenueUnit];
    [adjustAdRevenue setAdRevenuePlacement:adRevenuePlacement];

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

    [[ADJAdjust instanceForId:instanceId] trackAdRevenue:adjustAdRevenue];
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

    [[ADJAdjust instanceForId:instanceId] trackThirdPartySharing:adjustThirdPartySharing];
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

@end


