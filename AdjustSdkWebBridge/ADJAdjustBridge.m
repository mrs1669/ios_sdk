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

@implementation ADJAdjustBridge

- (void)augmentedHybridWebView:(WKWebView *_Nonnull)webView withAdjustConfig:(ADJAdjustConfig *)adjustConfig {

    if ([webView isKindOfClass:WKWebView.class]) {

        ADJAdjustConfig *config = adjustConfig;
        [config setAdjustAttributionSubscriber:self];
        [config setUrlStrategy:ADJUrlStategyIndia];
        [ADJAdjust sdkInitWithAdjustConfig:config];

        self.webView = webView;
        WKUserContentController *controller = webView.configuration.userContentController;

        [controller addScriptMessageHandler:self name:@"adjust"];
    }
}

- (void)didReadWithAdjustAttribution:(ADJAdjustAttribution *)adjustAttribution {
    NSString *adjustAttributionString = adjustAttribution.description;
    NSString *javaScript = [NSString stringWithFormat:@"attributionCallback('%@');", adjustAttributionString];
    [self.webView evaluateJavaScript:javaScript completionHandler:nil];
}

- (void)didChangeWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    NSString *adjustAttributionString = adjustAttribution.description;
    NSString *javaScript = [NSString stringWithFormat:@"%@", adjustAttributionString];
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

    if ([action isEqual:@"adjust_trackEvent"]) {

        NSString *eventToken = [data objectForKey:@"eventToken"];
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
            // TODO: not sure if clients will be using NSNumber over double approach
            // NSNumber *_Nullable revenueNumber = [self strictParseNumberDoubleWithString:revenueString];
            // [adjustEvent setRevenueWithDoubleNumber:revenueNumber
            //                                currency:currency];
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

    } else if ([action isEqual:@"adjust_trackAdRevenue"]) {

        NSString *source = [data objectForKey:@"source"];
        NSString *payload = [data objectForKey:@"payload"];
        NSData *dataPayload = [payload dataUsingEncoding:NSUTF8StringEncoding];
        
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

        NSString *_Nullable openDeeplink = [data objectForKey:@"deeplink"];
        ADJAdjustLaunchedDeeplink *_Nonnull adjustLaunchedDeeplink = [[ADJAdjustLaunchedDeeplink alloc] initWithString:openDeeplink];
        [ADJAdjust trackLaunchedDeeplink:adjustLaunchedDeeplink];
        
    } else if ([action isEqual: @"adjust_trackThirdPartySharing"]) {

        id isEnabledO = [data objectForKey:@"isEnabled"];
        id granularOptions = [data objectForKey:@"granularOptions"];

        NSNumber *isEnabled = nil;
        if ([isEnabledO isKindOfClass:[NSNumber class]]) {
            isEnabled = (NSNumber *)isEnabledO;
        }

        ADJAdjustThirdPartySharing *adjustThirdPartySharing = [ADJAdjustThirdPartySharing init];

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

        [ADJAdjust trackThirdPartySharing:adjustThirdPartySharing];

    } else if ([action isEqual: @"adjust_trackDeeplink"]) {

        NSString *_Nullable openDeeplink = [data objectForKey:@"deeplink"];
        ADJAdjustLaunchedDeeplink *_Nonnull adjustLaunchedDeeplink = [[ADJAdjustLaunchedDeeplink alloc] initWithString:openDeeplink];
        [ADJAdjust trackLaunchedDeeplink:adjustLaunchedDeeplink];

    } else if ([action isEqual: @"adjust_inactivateSdk"]) {

        [ADJAdjust inactivateSdk];

    } else if ([action isEqual: @"adjust_reactivateSdk"]) {

        [ADJAdjust reactivateSdk];

    } else if ([action isEqual: @"adjust_addGlobalCallbackParameter"]) {

        NSString *key = [data objectForKey:@"key"];
        NSString *value = [data objectForKey:@"value"];
        [ADJAdjust addGlobalCallbackParameterWithKey:key value:value];

    } else if ([action isEqual: @"adjust_removeGlobalCallbackParameterByKey"]) {

        NSString *key = [data objectForKey:@"key"];
        [ADJAdjust removeGlobalCallbackParameterByKey:key];

    } else if ([action isEqual: @"adjust_clearAllGlobalCallbackParameters"]) {

        [ADJAdjust clearAllGlobalCallbackParameters];

    } else if ([action isEqual: @"adjust_addGlobalPartnerParameter"]) {

        NSString *key = [data objectForKey:@"key"];
        NSString *value = [data objectForKey:@"value"];
        [ADJAdjust addGlobalPartnerParameterWithKey:key value:value];

    } else if ([action isEqual: @"adjust_removeGlobalPartnerParameterByKey"]) {

        NSString *key = [data objectForKey:@"key"];
        [ADJAdjust removeGlobalPartnerParameterByKey:key];

    } else if ([action isEqual: @"adjust_clearAllGlobalPartnerParameters"]) {

        [ADJAdjust clearAllGlobalPartnerParameters];

    } else if ([action isEqual:@"adjust_gdprForgetMe"]) {

        [ADJAdjust gdprForgetDevice];
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
    return !!field;
}

@end
