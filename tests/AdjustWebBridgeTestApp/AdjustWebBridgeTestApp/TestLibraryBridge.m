//
//  TestLibraryBridge.m
//  AdjustWebBridgeTestApp
//
//  Created by Pedro Silva (@nonelse) on 6th August 2018.
//  Copyright © 2018 Adjust GmbH. All rights reserved.
//

#import "TestLibraryBridge.h"

@interface TestLibraryBridge ()

//@property WVJBResponseCallback commandExecutorCallback;
@property (nonatomic, strong) ATLTestLibrary *testLibrary;
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) ADJAdjustBridge *adjustBridge;

@end

@implementation TestLibraryBridge 

- (id)initWithAdjustBridgeRegister:(ADJAdjustBridge *)adjustBridge {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.testLibrary = [ATLTestLibrary testLibraryWithBaseUrl:baseUrl
                                                andControlUrl:controlUrl
                                           andCommandDelegate:self];

    [self augmentedHybridWebView:adjustBridge.webView];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.webView evaluateJavaScript:@"TestLibraryBridge.javaScriptTest()" completionHandler:nil];
    });

    return self;
}

- (void)augmentedHybridWebView:(WKWebView *_Nonnull)webView {

    if ([webView isKindOfClass:WKWebView.class]) {

        self.webView = webView;

        WKUserContentController *controller = webView.configuration.userContentController;

        [self userContentController:controller didAddUserScript:[self getWebBridgeScriptFor:@"adjust"]];
        [self userContentController:controller didAddUserScript:[self getWebBridgeScriptFor:@"adjust_config"]];
        [self userContentController:controller didAddUserScript:[self getWebBridgeScriptFor:@"adjust_event"]];
        [self userContentController:controller didAddUserScript:[self getWebBridgeScriptFor:@"adjust_revenue"]];
        [self userContentController:controller didAddUserScript:[self getWebBridgeScriptFor:@"adjust_third_party_sharing"]];

        [controller addScriptMessageHandler:self name:@"adjustTest"];
    }
}

- (NSString *)getWebBridgeScriptFor:(NSString *)resource {
    NSBundle *sourceBundle = [NSBundle bundleForClass:self.class];
    NSString *adjustScriptPath = [sourceBundle pathForResource:resource ofType:@"js"];
    NSString *adjustScript = [NSString stringWithContentsOfFile:adjustScriptPath encoding:NSUTF8StringEncoding error:nil];
    return adjustScript;
}

- (void)userContentController:(WKUserContentController *)controller didAddUserScript:(NSString *)javascript {
    [controller addUserScript:[[WKUserScript.class alloc] initWithSource:javascript
                                                           injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                        forMainFrameOnly:NO]];

}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        
        NSString *action = [message.body objectForKey:@"action"];
        NSDictionary *data = [message.body objectForKey:@"data"];

        if ([action isEqual:@"adjustTLB_startTestSession"]) {

            [self startTestSession:(NSString *)data];

        } else if ([action isEqual:@"adjustTLB_sendInfoToServer"]) {

            [self sendInfoToServer:(NSString *)data];

        } else if ([action isEqual:@"adjustTLB_addInfoToSend"]) {

            NSString *key = [data objectForKey:@"key"];
            NSString *value = [data objectForKey:@"value"];
            [self addInfoToSend:key andValue:value];
        }
    }
}

- (void)startTestSession:(NSString *)clientSdk {
    [self.testLibrary startTestSession:clientSdk];
}

- (void)addTestDirectory:(NSString *)directoryName {
    [self.testLibrary addTestDirectory:directoryName];
}

- (void)addTest:(NSString *)testName {
    [self.testLibrary addTest:testName];
}

- (void)addInfoToSend:(NSString *)key andValue:(NSString *)value {
    [self.testLibrary addInfoToSend:key value:value];
}

- (void)sendInfoToServer:(NSString *)extraPath {
    [self.testLibrary sendInfoToServer:extraPath];
}

- (void)executeCommandRawJson:(NSString *)json {
    NSString *javaScript = [NSString stringWithFormat:@"TestLibraryBridge.adjustCommandExecutor('%@')", json];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.webView evaluateJavaScript:javaScript completionHandler:nil];
    });
}

@end
