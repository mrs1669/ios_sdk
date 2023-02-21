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

    self.adjustBridge = [[ADJAdjustBridge alloc] init];
    [self.adjustBridge augmentedHybridWebView:webView];

    self.testLibraryBridge = [[TestLibraryBridge alloc]
                              initWithAdjustBridgeRegister:self.adjustBridge];

    NSString *htmlPath = [[NSBundle mainBundle]
                          pathForResource:@"AdjustTestApp-WebView" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath
                                                  encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

@end
