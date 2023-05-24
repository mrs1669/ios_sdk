//
//  WKWebViewController.m
//  AdjustWebBridgeTestApp
//
//  Created by Pedro Silva (@nonelse) on 6th August 2018.
//  Copyright © 2018 Adjust GmbH. All rights reserved.
//

#import "WKWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

#import "TestLibraryBridge.h"
#import <AdjustSdkWebBridge/AdjustSdkWebBridge.h>

@interface WKWebViewController ()

@property ADJAdjustBridge *adjustBridge;
@property TestLibraryBridge *testLibraryBridge;

@end

@implementation WKWebViewController

#pragma mark - View Controller Life cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {

    WKWebView *webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];

    self.adjustBridge = [ADJAdjustBridge instanceWithWKWebView:webView];

    self.testLibraryBridge = [TestLibraryBridge instanceWithWKWebView:webView];

    NSString *htmlPath = [[NSBundle mainBundle]
                          pathForResource:@"AdjustTestApp-WebView" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath
                                                  encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}
/* Current state
    Test app web view.html
1    - calls TestLibraryBridge.addTestDirectory* + startTestSession .js
    Test app TestLibraryBridge.js
    - addTestDirectory
2        calls adjustTLB_addTestDirectory in TestLibraryBridge.m
    - startTestSession
3        stores locally new AdjustCommandExecutor
4       calls Adjust.getSdkVersion() .js
    - getSdkVersion()
7        calls adjustTLB_startTestSession in TestLibraryBridge.m
    Test app TestLibraryBridge.m
    - adjustTLB_startTestSession
8        calls testLibrary.startTestSession

    Adjust.js
    - getSdkVersion()
5        calls adjust_getSdkVersion in ADJAdjustBridge.m
    ADJAdjustBridge.m
    - adjust_getSdkVersion
6       calls TestLibraryBridge.getSdkVersion({sdkVersion}) in js

 */

@end
