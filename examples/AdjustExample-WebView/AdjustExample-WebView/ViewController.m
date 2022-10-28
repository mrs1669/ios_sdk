//
//  ViewController.m
//  AdjustExample-WebView
//
//  Created by Aditi Agrawal on 27/10/22.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

#import <Adjust/ADJAdjust.h>
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

    NSString *path = [[NSBundle mainBundle] pathForResource:@"AdjustExample-WebView" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];

    ADJAdjustConfig *adjustConfig = [[ADJAdjustConfig alloc] initWithAppToken:@"2fm9gkqubvpc" environment:ADJEnvironmentSandbox];
    [[ADJAdjustBridge alloc] augmentedHybridWebView:_webView withAdjustConfig:adjustConfig];
}

@end
