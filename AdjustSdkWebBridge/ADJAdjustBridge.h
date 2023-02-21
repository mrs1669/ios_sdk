//
//  ADJAdjustBridge.h
//  AdjustSdkWebBridge
//
//  Created by Aditi Agrawal on 26/10/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "ADJAdjust.h"

@interface ADJAdjustBridge : NSObject <WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *_Nonnull webView;

- (void)augmentedHybridWebView:(WKWebView *_Nonnull)webView;

@end
