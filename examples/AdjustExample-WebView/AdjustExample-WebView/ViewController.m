//
//  ViewController.m
//  AdjustExample-WebView
//
//  Created by Aditi Agrawal on 27/10/22.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@import Adjust;
#import "ADJAdjustBridge.h"

@interface ViewController ()

@property(strong,nonatomic) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadWKWebView];
}

- (void)loadWKWebView {


//    NSString *path1 = [[NSBundle mainBundle]  pathForResource:@"test" ofType:@"js"];
//    NSURL *instructionsURL = [NSURL fileURLWithPath:path1];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"AdjustExample-WebView" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];

    /// One way of initialising the SDK
//    ADJAdjustConfig *config = [[ADJAdjustConfig alloc] initWithAppToken:@"2fm9gkqubvpc" environment:ADJEnvironmentSandbox];
//    [[ADJAdjustBridge alloc] augmentedHybridWebView:_webView withAdjustConfig:config];

    /// Another way of initialising the SDK
    [[ADJAdjustBridge alloc] augmentedHybridWebView:_webView];
}

@end
