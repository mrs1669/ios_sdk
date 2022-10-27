//
//  ADJAdjustBridge.m
//  AdjustSdkWebBridge
//
//  Created by Aditi Agrawal on 26/10/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustBridge.h"
#import "ADJAdjustAttribution.h"

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
    NSString *javaScript = [NSString stringWithFormat:@"attributionCallback('%@');", adjustAttributionString];
    [self.webView evaluateJavaScript:javaScript completionHandler:nil];
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        [self handleMessageFromWebview:message.body];
    }
}

- (void)handleMessageFromWebview:(NSDictionary<NSString *,id> *)message{
    NSString *action = [message objectForKey:@"action"];
    if ([action isEqual:@"adjust_trackEvent"]) {
        NSDictionary *eventDetails = [message objectForKey:@"eventDetails"];
        ADJAdjustEvent *_Nonnull adjustEvent = [[ADJAdjustEvent alloc] initWithEventId:[eventDetails objectForKey:@"eventToken"]];
        [ADJAdjust trackEvent:adjustEvent];
    }
}

@end
