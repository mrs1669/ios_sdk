//
//  ADJAdjustBridge.h
//  AdjustSdkWebBridge
//
//  Created by Aditi Agrawal on 26/10/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "ADJAdjustLogSubscriber.h"

@interface ADJAdjustBridge : NSObject

- (nullable instancetype)init NS_UNAVAILABLE;

+ (nullable ADJAdjustBridge *)instanceWithWKWebView:(nonnull WKWebView *)webView;

+ (nullable ADJAdjustBridge *)
instanceWithWKWebView:(nonnull WKWebView *)webView
adjustJsLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustJsLogSubscriber;

- (nonnull WKWebView *)webView;

@end
