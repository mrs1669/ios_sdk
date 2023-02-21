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

@interface ADJAdjustBridge() <ADJAdjustAttributionSubscriber>

@end

@implementation ADJAdjustBridge

#pragma mark - Init Web View

- (void)augmentedHybridWebView:(WKWebView *_Nonnull)webView {
    if ([webView isKindOfClass:WKWebView.class]) {
        self.webView = webView;
        WKUserContentController *controller = webView.configuration.userContentController;
        [self userContentController:controller didAddUserScript:[self
                                                                 getWebBridgeScriptFor:@"adjust"]];
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

- (void)userContentController:(WKUserContentController *)controller
             didAddUserScript:(NSString *)javascript {
    [controller addUserScript:[[WKUserScript.class alloc]
                               initWithSource:javascript
                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                               forMainFrameOnly:NO]];

}

- (void)didReadWithAdjustAttribution:(ADJAdjustAttribution *)adjustAttribution {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSString *adjustAttributionString = adjustAttribution.description;
        NSString *javaScript = [NSString stringWithFormat:@"didReadWithAdjustAttribution('%@')",
                                adjustAttributionString];
        [self.webView evaluateJavaScript:javaScript completionHandler:nil];
    });
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
    NSDictionary *data = [message objectForKey:@"data"];
    NSString *instanceId = [message objectForKey:@"instanceId"];

    if ([action isEqual:@"adjust_initSdk"]) {

        [self sdkInitWithAdjustConfig:data forInstanceId:instanceId];

    }else if ([action isEqual:@"adjust_getSdkVersion"]) {

        NSString *javaScript = [NSString stringWithFormat:@"getSdkVersion('%@')",
                                [ADJAdjustInternal sdkVersion]];
        [self.webView evaluateJavaScript:javaScript completionHandler:nil];

    } else  if ([action isEqual:@"adjust_trackEvent"]) {

        [self trackEvent:data forInstanceId:instanceId];

    } else if ([action isEqual:@"adjust_trackAdRevenue"]) {

        [self trackAdRevenue:data forInstanceId:instanceId];

    } else if ([action isEqual:@"adjust_trackPushToken"]) {

        if (![data isKindOfClass:[NSString class]]) {
            return;
        }

        ADJAdjustPushToken *pushToken = [[ADJAdjustPushToken alloc]
                                         initWithStringPushToken:(NSString *)data];
        [[ADJAdjust instanceForId:instanceId] trackPushToken:pushToken];

    } else if ([action isEqual:@"adjust_switchToOfflineMode"]) {

        [[ADJAdjust instanceForId:instanceId] switchToOfflineMode];

    } else if ([action isEqual:@"adjust_switchBackToOnlineMode"]) {

        [[ADJAdjust instanceForId:instanceId] switchBackToOnlineMode];

    } else if ([action isEqual: @"adjust_trackDeeplink"]) {

        if (![data isKindOfClass:[NSString class]]) {
            return;
        }

        ADJAdjustLaunchedDeeplink *_Nonnull adjustLaunchedDeeplink =
        [[ADJAdjustLaunchedDeeplink alloc] initWithString:(NSString *)data];
        [[ADJAdjust instanceForId:instanceId] trackLaunchedDeeplink:adjustLaunchedDeeplink];

    } else if ([action isEqual: @"adjust_trackThirdPartySharing"]) {

        [self trackThirdPartySharing:data forInstanceId:instanceId];

    } else if ([action isEqual: @"adjust_inactivateSdk"]) {

        [[ADJAdjust instanceForId:instanceId] inactivateSdk];

    } else if ([action isEqual: @"adjust_reactivateSdk"]) {

        [[ADJAdjust instanceForId:instanceId] reactivateSdk];

    } else if ([action isEqual: @"adjust_addGlobalCallbackParameter"]) {

        NSString *key = [message objectForKey:@"key"];
        NSString *value = [message objectForKey:@"value"];
        [[ADJAdjust instanceForId:instanceId] addGlobalCallbackParameterWithKey:key value:value];

    } else if ([action isEqual: @"adjust_removeGlobalCallbackParameterByKey"]) {

        NSString *key = [message objectForKey:@"key"];
        [[ADJAdjust instanceForId:instanceId] removeGlobalCallbackParameterByKey:key];

    } else if ([action isEqual: @"adjust_clearAllGlobalCallbackParameters"]) {

        [[ADJAdjust instanceForId:instanceId] clearAllGlobalCallbackParameters];

    } else if ([action isEqual: @"adjust_addGlobalPartnerParameter"]) {

        NSString *key = [message objectForKey:@"key"];
        NSString *value = [message objectForKey:@"value"];
        [[ADJAdjust instanceForId:instanceId] addGlobalPartnerParameterWithKey:key value:value];

    } else if ([action isEqual: @"adjust_removeGlobalPartnerParameterByKey"]) {

        NSString *key = [message objectForKey:@"key"];
        [[ADJAdjust instanceForId:instanceId] removeGlobalPartnerParameterByKey:key];

    } else if ([action isEqual: @"adjust_clearAllGlobalPartnerParameters"]) {

        [[ADJAdjust instanceForId:instanceId] clearAllGlobalPartnerParameters];

    } else if ([action isEqual:@"adjust_gdprForgetMe"]) {

        [[ADJAdjust instanceForId:instanceId] gdprForgetDevice];

    } else if ([action isEqual:@"adjust_appWentToTheBackgroundManualCall"]) {

        [[ADJAdjust instanceForId:instanceId] appWentToTheBackgroundManualCall];

    } else if ([action isEqual:@"adjust_appWentToTheForegroundManualCall"]) {

        [[ADJAdjust instanceForId:instanceId] appWentToTheForegroundManualCall];

    } else if ([action isEqual:@"adjust_teardown"]) {

        //        [ADJAdjustInternal teardownWithShouldClearStorage:YES sdkConfigDataBuilder:d];
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
    NSNumber *coppaCompliantEnabled = [data objectForKey:@"coppaCompliantEnabled"];
    NSNumber *linkMeEnabled = [data objectForKey:@"linkMeEnabled"];
    NSNumber *allowiAdInfoReading = [data objectForKey:@"allowiAdInfoReading"];
    NSNumber *allowAdServicesInfoReading = [data objectForKey:@"allowAdServicesInfoReading"];
    NSNumber *allowIdfaReading = [data objectForKey:@"allowIdfaReading"];
    NSNumber *allowSkAdNetworkHandling = [data objectForKey:@"allowSkAdNetworkHandling"];
    NSNumber *openDeferredDeeplink = [data objectForKey:@"openDeferredDeeplink"];
    NSString *attributionCallback = [data objectForKey:@"attributionCallback"];
    NSString *urlStrategy = [data objectForKey:@"urlStrategy"];

    ADJAdjustConfig *adjustConfig = [[ADJAdjustConfig alloc] initWithAppToken:appToken
                                                                  environment:environment];

    [adjustConfig doLogAll];

    [adjustConfig setUrlStrategy:urlStrategy];
    [adjustConfig setDefaultTracker:defaultTracker];
    [adjustConfig setCustomEndpointWithUrl:customEndpointUrl
                  optionalPublicKeyKeyHash:customEndpointPublicKeyHash];

    [adjustConfig doNotOpenDeferredDeeplinkNumberBool];
    [adjustConfig setAdjustAttributionSubscriber:self];

    if ([self isFieldValid:eventDeduplicationListLimit]) {
        [adjustConfig setEventIdDeduplicationMaxCapacity:[eventDeduplicationListLimit intValue]];
    }

    if (sendInBackground) {
        [adjustConfig allowSendingFromBackground];
    }

    [[ADJAdjust instance] initSdkWithConfiguration:adjustConfig];

    [[ADJAdjust instanceForId:instanceId] initSdkWithConfiguration:adjustConfig];
}

- (void)trackEvent:(NSDictionary *)data forInstanceId:(nullable NSString *)instanceId {

    NSString *eventToken = [data objectForKey:@"eventId"];
    NSString *revenue = [data objectForKey:@"revenue"];
    NSString *currency = [data objectForKey:@"currency"];
    NSString *deduplicationId = [data objectForKey:@"deduplicationId"];
    id callbackParameters = [data objectForKey:@"callbackParameters"];
    id partnerParameters = [data objectForKey:@"partnerParameters"];

    ADJAdjustEvent *_Nonnull adjustEvent = [[ADJAdjustEvent alloc] initWithEventId:eventToken];

    [adjustEvent setDeduplicationId:deduplicationId];

    if ([self isFieldValid:revenue]) {
        [adjustEvent setRevenueWithDouble:[revenue doubleValue] currency:currency];
    }

    for (int i = 0; i < [callbackParameters count]; i += 2) {
        NSString *key = [[callbackParameters objectAtIndex:i] description];
        NSString *value = [[callbackParameters objectAtIndex:(i + 1)] description];
        [adjustEvent addCallbackParameterWithKey:key value:value];
    }

    for (int i = 0; i < [partnerParameters count]; i += 2) {
        NSString *key = [[partnerParameters objectAtIndex:i] description];
        NSString *value = [[partnerParameters objectAtIndex:(i + 1)] description];
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
    id callbackParameters = [data objectForKey:@"callbackParameters"];
    id partnerParameters = [data objectForKey:@"partnerParameters"];

    ADJAdjustAdRevenue *_Nonnull adjustAdRevenue = [[ADJAdjustAdRevenue alloc]
                                                    initWithSource:adRevenueSource];
    [adjustAdRevenue setRevenueWithDoubleNumber:revenue currency:currency];

    if ([self isFieldValid:adImpressionsCount]) {
        [adjustAdRevenue setAdImpressionsCountWithInteger:[adImpressionsCount intValue]];
    }

    [adjustAdRevenue setAdRevenueNetwork:adRevenueNetwork];
    [adjustAdRevenue setAdRevenueUnit:adRevenueUnit];
    [adjustAdRevenue setAdRevenuePlacement:adRevenuePlacement];

    for (int i = 0; i < [callbackParameters count]; i += 2) {
        NSString *key = [[callbackParameters objectAtIndex:i] description];
        NSString *value = [[callbackParameters objectAtIndex:(i + 1)] description];
        [adjustAdRevenue addCallbackParameterWithKey:key value:value];
    }

    for (int i = 0; i < [partnerParameters count]; i += 2) {
        NSString *key = [[partnerParameters objectAtIndex:i] description];
        NSString *value = [[partnerParameters objectAtIndex:(i + 1)] description];
        [adjustAdRevenue addPartnerParameterWithKey:key value:value];
    }

    [[ADJAdjust instanceForId:instanceId] trackAdRevenue:adjustAdRevenue];
}

- (void)trackThirdPartySharing:(NSDictionary *)data forInstanceId:(nullable NSString *)instanceId {

    id isEnabledO = [data objectForKey:@"isEnabled"];
    id granularOptions = [data objectForKey:@"granularOptions"];
    id partnerSharingSettings = [data objectForKey:@"partnerSharingSettings"];

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
        NSString *partnerName = [[granularOptions objectAtIndex:i] description];
        NSString *key = [[granularOptions objectAtIndex:(i + 1)] description];
        NSString *value = [[granularOptions objectAtIndex:(i + 2)] description];
        [adjustThirdPartySharing addGranularOptionWithPartnerName:partnerName key:key value:value];
    }

    for (int i = 0; i < [partnerSharingSettings count]; i += 3) {
        NSString *partnerName = [[partnerSharingSettings objectAtIndex:i] description];
        NSString *key = [[partnerSharingSettings objectAtIndex:(i + 1)] description];
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
    return !!field;
}

@end



