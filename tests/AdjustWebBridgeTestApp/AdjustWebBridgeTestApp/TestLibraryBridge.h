//
//  TestLibraryBridge.h
//  AdjustWebBridgeTestApp
//
//  Created by Pedro Silva (@nonelse) on 6th August 2018.
//  Copyright © 2018 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATLTestLibrary.h"
#import <AdjustSdkWebBridge/AdjustSdkWebBridge.h>

// simulator
static NSString *_Nonnull baseUrl = @"http://127.0.0.1:8080";
static NSString *_Nonnull controlUrl = @"ws://127.0.0.1:1987";
// device
// static NSString * baseUrl = @"http://192.168.86.65:8080";
// static NSString * controlUrl = @"ws://192.168.86.65:1987";

@interface TestLibraryBridge : NSObject

+ (nullable TestLibraryBridge *)
    instanceWithWKWebView:(nonnull WKWebView *)webView;

@end
