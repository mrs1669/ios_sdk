//
//  WKWebViewController.m
//  AdjustWebBridgeTestApp
//
//  Created by Pedro Silva (@nonelse) on 6th August 2018.
//  Copyright © 2018 Adjust GmbH. All rights reserved.
//

#import "WKWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@import AdjustSdkWebBridge;
#import "TestLibraryBridge.h"


@interface WKWebViewController ()

@property ADJAdjustBridge *adjustBridge;
@property TestLibraryBridge *testLibraryBridge;

@end

@implementation WKWebViewController

- (void)viewWillAppear:(BOOL)animated {
    WKWebView *webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];

     ADJAdjustConfig *_Nonnull adjustConfig = [[ADJAdjustConfig alloc] initWithAppToken:@"2fm9gkqubvpc"
                                                                               environment:ADJEnvironmentSandbox];

    _adjustBridge = [[ADJAdjustBridge alloc] init];
    [_adjustBridge augmentedHybridWebView:webView withAdjustConfig:adjustConfig];

//    self.testLibraryBridge = [[TestLibraryBridge alloc] initWithAdjustBridgeRegister:[self.adjustBridge bridgeRegister]];

    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"AdjustTestApp-WebView" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidFinishLoad");
}

@end
