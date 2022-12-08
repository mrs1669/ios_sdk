//
//  ADJAdjustBridge.m
//  AdjustSdkWebBridge
//
//  Created by Aditi Agrawal on 26/10/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustBridge.h"

#import "ADJAdjustEvent.h"
#import "ADJAdjustPushToken.h"
#import "ADJAdjustAttribution.h"
#import "ADJAdjustLaunchedDeeplink.h"
#import "ADJAdjustThirdPartySharing.h"
#import "ADJAdjustAdRevenue.h"

@implementation ADJAdjustBridge

- (void)augmentedHybridWebView:(WKWebView *_Nonnull)webView {

    if ([webView isKindOfClass:WKWebView.class]) {

        self.webView = webView;

        NSString *adjustScriptPath = [[NSBundle mainBundle] pathForResource:@"adjust" ofType:@"js"];
        NSString *adjustScript = [NSString stringWithContentsOfFile:adjustScriptPath encoding:NSUTF8StringEncoding error:nil];

        NSString *adjustEventScriptPath = [[NSBundle mainBundle] pathForResource:@"adjust_event" ofType:@"js"];
        NSString *adjustEventScript = [NSString stringWithContentsOfFile:adjustEventScriptPath encoding:NSUTF8StringEncoding error:nil];

        NSString *adjustRevenueScriptPath = [[NSBundle mainBundle] pathForResource:@"adjust_revenue" ofType:@"js"];
        NSString *adjustRevenueScript = [NSString stringWithContentsOfFile:adjustRevenueScriptPath encoding:NSUTF8StringEncoding error:nil];

        NSString *adjustConfigScriptPath = [[NSBundle mainBundle] pathForResource:@"adjust_config" ofType:@"js"];
        NSString *adjustConfigScript = [NSString stringWithContentsOfFile:adjustConfigScriptPath encoding:NSUTF8StringEncoding error:nil];

        NSString *adjustThirdPartySharingScriptPath = [[NSBundle mainBundle] pathForResource:@"adjust_third_party_sharing" ofType:@"js"];
        NSString *adjustThirdPartySharingScript = [NSString stringWithContentsOfFile:adjustThirdPartySharingScriptPath encoding:NSUTF8StringEncoding error:nil];

        WKUserContentController *controller = webView.configuration.userContentController;

        [controller addUserScript:[[WKUserScript.class alloc]
                                   initWithSource:adjustScript
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                   forMainFrameOnly:NO]];

        [controller addUserScript:[[WKUserScript.class alloc]
                                   initWithSource:adjustEventScript
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                   forMainFrameOnly:NO]];

        [controller addUserScript:[[WKUserScript.class alloc]
                                   initWithSource:adjustRevenueScript
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                   forMainFrameOnly:NO]];
        
        [controller addUserScript:[[WKUserScript.class alloc]
                                   initWithSource:adjustConfigScript
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                   forMainFrameOnly:NO]];

        [controller addUserScript:[[WKUserScript.class alloc]
                                   initWithSource:adjustThirdPartySharingScript
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                   forMainFrameOnly:NO]];

        [controller addScriptMessageHandler:self name:@"adjust"];
    }
}

- (void)didReadWithAdjustAttribution:(ADJAdjustAttribution *)adjustAttribution {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSString *adjustAttributionString = adjustAttribution.description;
        NSString *javaScript = [NSString stringWithFormat:@"didReadWithAdjustAttribution('%@')", adjustAttributionString];
        [self.webView evaluateJavaScript:javaScript completionHandler:nil];
    });
}

- (void)didChangeWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    NSString *adjustAttributionString = adjustAttribution.description;
    NSString *javaScript = [NSString stringWithFormat:@"didChangeWithAdjustAttribution('%@')", adjustAttributionString];
    [self.webView evaluateJavaScript:javaScript completionHandler:nil];
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        [self handleMessageFromWebview:message.body];
    }
}

- (void)handleMessageFromWebview:(NSDictionary<NSString *,id> *)message{

    NSString *action = [message objectForKey:@"action"];
    NSDictionary *data = [message objectForKey:@"data"];

    if ([action isEqual:@"adjust_appDidLaunch"]) {

        [self setAdjustConfig:data];

    } else  if ([action isEqual:@"adjust_trackEvent"]) {

        [self trackEvent:data];

    } else if ([action isEqual:@"adjust_trackAdRevenue"]) {

        [self trackAdRevenue:data];

    } else if ([action isEqual:@"adjust_trackPushToken"]) {

        if (![data isKindOfClass:[NSString class]]) {
            return;
        }

        ADJAdjustPushToken *pushToken = [[ADJAdjustPushToken alloc] initWithStringPushToken:(NSString *)data];
        [ADJAdjust trackPushToken:pushToken];

    } else if ([action isEqual:@"adjust_switchToOfflineMode"]) {

        [ADJAdjust switchToOfflineMode];

    } else if ([action isEqual:@"adjust_switchToOnlineMode"]) {

        [ADJAdjust switchBackToOnlineMode];

    } else if ([action isEqual:@"adjust_switchToOnlineMode"]) {

        [ADJAdjust switchBackToOnlineMode];

    } else if ([action isEqual: @"adjust_trackDeeplink"]) {

        if (![data isKindOfClass:[NSString class]]) {
            return;
        }

        ADJAdjustLaunchedDeeplink *_Nonnull adjustLaunchedDeeplink = [[ADJAdjustLaunchedDeeplink alloc] initWithString:(NSString *)data];
        [ADJAdjust trackLaunchedDeeplink:adjustLaunchedDeeplink];

    } else if ([action isEqual: @"adjust_trackThirdPartySharing"]) {

        [self trackThirdPartySharing:data];

    } else if ([action isEqual: @"adjust_inactivateSdk"]) {

        [ADJAdjust inactivateSdk];

    } else if ([action isEqual: @"adjust_reactivateSdk"]) {

        [ADJAdjust reactivateSdk];

    } else if ([action isEqual: @"adjust_addGlobalCallbackParameter"]) {

        NSString *key = [message objectForKey:@"key"];
        NSString *value = [message objectForKey:@"value"];
        [ADJAdjust addGlobalCallbackParameterWithKey:key value:value];

    } else if ([action isEqual: @"adjust_removeGlobalCallbackParameterByKey"]) {

        NSString *key = [message objectForKey:@"key"];
        [ADJAdjust removeGlobalCallbackParameterByKey:key];

    } else if ([action isEqual: @"adjust_clearAllGlobalCallbackParameters"]) {

        [ADJAdjust clearAllGlobalCallbackParameters];

    } else if ([action isEqual: @"adjust_addGlobalPartnerParameter"]) {

        NSString *key = [message objectForKey:@"key"];
        NSString *value = [message objectForKey:@"value"];
        [ADJAdjust addGlobalPartnerParameterWithKey:key value:value];

    } else if ([action isEqual: @"adjust_removeGlobalPartnerParameterByKey"]) {

        NSString *key = [message objectForKey:@"key"];
        [ADJAdjust removeGlobalPartnerParameterByKey:key];

    } else if ([action isEqual: @"adjust_clearAllGlobalPartnerParameters"]) {

        [ADJAdjust clearAllGlobalPartnerParameters];

    } else if ([action isEqual:@"adjust_gdprForgetMe"]) {

        [ADJAdjust gdprForgetDevice];
    }
}

- (void)setAdjustConfig:(NSDictionary *)data {

    NSString *appToken = [data objectForKey:@"appToken"];
    NSString *environment = [data objectForKey:@"environment"];
    NSString *customEndpointUrl = [data objectForKey:@"customEndpointUrl"];
    NSString *defaultTracker = [data objectForKey:@"defaultTracker"];
    NSNumber *sendInBackground = [data objectForKey:@"sendInBackground"];
    NSString *logLevel = [data objectForKey:@"logLevel"];
    NSNumber *eventBufferingEnabled = [data objectForKey:@"eventBufferingEnabled"];
    NSNumber *coppaCompliantEnabled = [data objectForKey:@"coppaCompliantEnabled"];
    NSNumber *linkMeEnabled = [data objectForKey:@"linkMeEnabled"];
    NSNumber *allowiAdInfoReading = [data objectForKey:@"allowiAdInfoReading"];
    NSNumber *allowAdServicesInfoReading = [data objectForKey:@"allowAdServicesInfoReading"];
    NSNumber *allowIdfaReading = [data objectForKey:@"allowIdfaReading"];
    NSNumber *allowSkAdNetworkHandling = [data objectForKey:@"allowSkAdNetworkHandling"];
    NSNumber *openDeferredDeeplink = [data objectForKey:@"openDeferredDeeplink"];
    NSString *attributionCallback = [data objectForKey:@"attributionCallback"];
    NSString *urlStrategy = [data objectForKey:@"urlStrategy"];

    ADJAdjustConfig *adjustConfig;
    if ([self isFieldValid:appToken] && [self isFieldValid:environment]) {
        adjustConfig = [[ADJAdjustConfig alloc] initWithAppToken:appToken environment:environment];
    }

    if ([self isFieldValid:logLevel]) {
        [adjustConfig setLogLevel:logLevel];
    }

    if ([self isFieldValid:urlStrategy]) {
        [adjustConfig setUrlStrategy:urlStrategy];
    }

    if ([self isFieldValid:defaultTracker]) {
        [adjustConfig setDefaultTracker:defaultTracker];
    }

    if ([self isFieldValid:logLevel]) {
        // TODO: add option to take Public Key Hash
        [adjustConfig setCustomEndpointWithUrl:customEndpointUrl optionalPublicKeyKeyHash:nil];
    }

    if ([self isFieldValid:openDeferredDeeplink]) {
        [adjustConfig doNotOpenDeferredDeeplinkNumberBool];
    }

    if ([self isFieldValid:sendInBackground]) {
        [adjustConfig allowSendingFromBackground];
    }

    if ([self isFieldValid:attributionCallback]) {
        [adjustConfig setAdjustAttributionSubscriber:self];
    }

    [ADJAdjust sdkInitWithAdjustConfig:adjustConfig];
}

- (void)trackEvent:(NSDictionary *)data {

    NSString *eventToken = [data objectForKey:@"eventId"];
    NSString *revenue = [data objectForKey:@"revenue"];
    NSString *currency = [data objectForKey:@"currency"];
    NSString *deduplicationId = [data objectForKey:@"deduplicationId"];
    id callbackParameters = [data objectForKey:@"callbackParameters"];
    id partnerParameters = [data objectForKey:@"partnerParameters"];

    ADJAdjustEvent *_Nonnull adjustEvent = [[ADJAdjustEvent alloc] initWithEventId:eventToken];

    if ([self isFieldValid:@"deduplicationId"]) {
        [adjustEvent setDeduplicationId:deduplicationId];
    }

    if ([self isFieldValid:revenue] && [self isFieldValid:currency]) {
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

    [ADJAdjust trackEvent:adjustEvent];
}

- (void)trackAdRevenue:(NSDictionary *)data {

    NSString *adRevenueSource = [data objectForKey:@"source"];
    NSNumber *revenue = [data objectForKey:@"revenue"];
    NSNumber *adImpressionsCount = [data objectForKey:@"adImpressionsCount"];
    NSString *currency = [data objectForKey:@"currency"];
    NSString *adRevenueNetwork = [data objectForKey:@"adRevenueNetwork"];
    NSString *adRevenueUnit = [data objectForKey:@"adRevenueUnit"];
    NSString *adRevenuePlacement = [data objectForKey:@"adRevenuePlacement"];

    id callbackParameters = [data objectForKey:@"callbackParameters"];
    id partnerParameters = [data objectForKey:@"partnerParameters"];

    ADJAdjustAdRevenue *_Nonnull adjustAdRevenue = [[ADJAdjustAdRevenue alloc] initWithSource:adRevenueSource];

    if ([self isFieldValid:revenue] && [self isFieldValid:currency]) {
        [adjustAdRevenue setRevenueWithDoubleNumber:revenue currency:currency];
    }

    if ([self isFieldValid:adImpressionsCount]) {
        [adjustAdRevenue setAdImpressionsCountWithIntegerNumber:adImpressionsCount];
    }

    if ([self isFieldValid:adRevenueNetwork]) {
        [adjustAdRevenue setAdRevenueNetwork:adRevenueNetwork];
    }

    if ([self isFieldValid:adRevenueUnit]) {
        [adjustAdRevenue setAdRevenueUnit:adRevenueUnit];
    }

    if ([self isFieldValid:adRevenuePlacement]) {
        [adjustAdRevenue setAdRevenuePlacement:adRevenuePlacement];
    }

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

    [ADJAdjust trackAdRevenue:adjustAdRevenue];
}

- (void)trackThirdPartySharing:(NSDictionary *)data {

    id isEnabledO = [data objectForKey:@"isEnabled"];
    id granularOptions = [data objectForKey:@"granularOptions"];
    id partnerSharingSettings = [data objectForKey:@"partnerSharingSettings"];

    NSNumber *isEnabled = nil;
    if ([isEnabledO isKindOfClass:[NSNumber class]]) {
        isEnabled = (NSNumber *)isEnabledO;
    }

    ADJAdjustThirdPartySharing *adjustThirdPartySharing = [[ADJAdjustThirdPartySharing alloc] init];

    if (isEnabled) {
        [adjustThirdPartySharing enableThirdPartySharing];
    } else {
        [adjustThirdPartySharing disableThirdPartySharing];
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
        [adjustThirdPartySharing addPartnerSharingSettingWithPartnerName:partnerName key:key value:value];
    }

    [ADJAdjust trackThirdPartySharing:adjustThirdPartySharing];
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

