//
//  ADJWebViewCallback.h
//  Adjust
//
//  Created by Pedro Silva on 26.04.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WebKit/WebKit.h>

#import "ADJLogger.h"
#import "ADJAdjustInternal.h"

@interface ADJWebViewCallback : NSObject
- (nonnull instancetype)initWithWebView:(nonnull WKWebView *)webView
                                 logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

- (nonnull id<ADJInternalCallback>)
    attributionSubscriberInternalCallbackWithId:
        (nonnull NSString *)attributionSubscriberCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString;

- (nonnull id<ADJInternalCallback>)
    attributionGetterAsyncInternalCallbackWithId:
        (nonnull NSString *)attributionGetterAsyncCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString;

@property (nonnull, readonly, strong, nonatomic) WKWebView *webView;
@property (nonnull, readonly, strong, nonatomic) ADJLogger *logger;

@end
