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

@interface WKWebViewController () <ADJAdjustLogSubscriber>

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

    self.adjustBridge = [ADJAdjustBridge instanceWithWKWebView:webView
                                         adjustJsLogSubscriber:self];

    self.testLibraryBridge = [TestLibraryBridge instanceWithWKWebView:webView];

    NSString *htmlPath = [[NSBundle mainBundle]
                          pathForResource:@"AdjustTestApp-WebView" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath
                                                  encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

- (void)didLogWithMessage:(nonnull NSString *)logMessage
                 logLevel:(nonnull ADJAdjustLogLevel)logLevel
{
    NSLog(@"WKWebViewController didLogWithMessage logLevel %@, %@",
          logLevel, logMessage);
}

- (void)didLogMessagesPreInitWithArray:
    (nonnull NSArray<ADJAdjustLogMessageData *> *)preInitLogMessageArray
{
    NSLog(@"WKWebViewController didLogMessagesPreInitWithArray preInitLogMessageArray count %@",
          @(preInitLogMessageArray.count));
}

@end

