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
@property (nonatomic, weak) WKWebView *webview;
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
    self.webview = adjustBridge.webView;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.webview evaluateJavaScript:@"TestLibraryBridge.javaScriptTest()" completionHandler:nil];
    });

    return self;
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
    NSLog(@"TestLibraryBridge executeCommandRawJson: %@", json);
}

@end
