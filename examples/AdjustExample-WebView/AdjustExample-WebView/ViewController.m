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

@interface ViewController () <ADJAdjustLogSubscriber>

@property(strong,nonatomic) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadWKWebView];
}

- (void)loadWKWebView {

    NSString *path = [[NSBundle mainBundle] pathForResource:@"AdjustExample-WebView"
                                                     ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];

    [ADJAdjustBridge instanceWithWKWebView:self.webView
                       adjustJsLogSubscriber:self];
}

- (void)didLogWithMessage:(nonnull NSString *)logMessage
                 logLevel:(nonnull ADJAdjustLogLevel)logLevel
{
    NSLog(@"bridge: %@", logMessage);
}

- (void)didLogMessagesPreInitWithArray:
    (nonnull NSArray<ADJAdjustLogMessageData *> *)preInitLogMessageArray
{
    NSLog(@"didLogMessagesPreInitWithArray count %@", @(preInitLogMessageArray.count));
}

@end

