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
    attributionGetterInternalCallbackWithId:
        (nonnull NSString *)attributionGetterCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString;

- (nonnull id<ADJInternalCallback>)
    deviceIdsGetterInternalCallbackWithId:
        (nonnull NSString *)deviceIdsGetterCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString;

- (void)execJsTopLevelCallbackWithId:(nonnull NSString *)callbackId
                         stringParam:(nonnull NSString *)stringParam;

@property (nonnull, readonly, strong, nonatomic) WKWebView *webView;

@end
