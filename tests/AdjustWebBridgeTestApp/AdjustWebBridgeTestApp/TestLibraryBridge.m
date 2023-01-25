//
//  TestLibraryBridge.m
//  AdjustWebBridgeTestApp
//
//  Created by Pedro Silva (@nonelse) on 6th August 2018.
//  Copyright © 2018 Adjust GmbH. All rights reserved.
//

#import "TestLibraryBridge.h"
#import "ATOAdjustTestOptions.h"

@interface TestLibraryBridge ()

@property (nonatomic, strong) ATLTestLibrary *testLibrary;
@property (nonatomic, strong) WKWebView *webView;

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
    [self augmentedHybridTestWebView:adjustBridge.webView];
    return self;
}

#pragma mark - Test Webview Methods

#pragma mark Set up Test Webview

- (void)augmentedHybridTestWebView:(WKWebView *_Nonnull)webView {
    if ([webView isKindOfClass:WKWebView.class]) {
        self.webView = webView;
        WKUserContentController *controller = webView.configuration.userContentController;
        [controller addScriptMessageHandler:self name:@"adjustTest"];
    }
}

#pragma mark Handle Message from Test Webview

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

        } else if ([action isEqual:@"adjustTLB_addTest"]) {

            [self addTest:(NSString *)data];

        } else if ([action isEqual:@"adjustTLB_addTestDirectory"]) {

            [self addTestDirectory:(NSString *)data];

        } else if ([action isEqual:@"adjustTLB_addToTestOptionsSet"]) {

            NSString *key = [data objectForKey:@"key"];
            NSString *value = [data objectForKey:@"value"];
            [self addToTestOptionsSet:key andValue:value];

        } else if ([action isEqual:@"adjustTLB_teardownAndApplyAddedTestOptionsSet"]) {

            [self teardownAndApplyAddedTestOptionsSet];
        }
    }
}

- (void)startTestSession:(NSString *)clientSdk {
    [self.testLibrary startTestSession:clientSdk];
}

- (void)addTest:(NSString *)testName {
    [self.testLibrary addTest:testName];
}

- (void)addTestDirectory:(NSString *)directoryName {
    [self.testLibrary addTestDirectory:directoryName];
}

- (void)addInfoToSend:(NSString *)key andValue:(NSString *)value {
    [self.testLibrary addInfoToSend:key value:value];
}

- (void)sendInfoToServer:(NSString *)extraPath {
    [self.testLibrary sendInfoToServer:extraPath];
}

- (void)addToTestOptionsSet:(NSString *)key andValue:(NSString *)value {
    [ATOAdjustTestOptions addToOptionsSetWithKey:key value:value];
}

- (void)teardownAndApplyAddedTestOptionsSet {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *extraPath = [ATOAdjustTestOptions teardownAndApplyAddedTestOptionsSetWithUrlOverwrite:baseUrl];
        NSString *javaScript = [NSString stringWithFormat:@"TestLibraryBridge.teardownReturnExtraPath('%@')", extraPath];
            [self.webView evaluateJavaScript:javaScript completionHandler:nil];
    });

}

#pragma mark - Test cases command handler

- (void)executeCommandRawJson:(NSString *)json {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *javaScript = [NSString stringWithFormat:@"TestLibraryBridge.adjustCommandExecutor('%@')", json];
        [self.webView evaluateJavaScript:javaScript completionHandler:nil];
    });
}

@end


