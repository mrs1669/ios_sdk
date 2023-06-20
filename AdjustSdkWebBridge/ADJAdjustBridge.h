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

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageInitSdk;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageSdkVersion;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageTrackEvent;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageTrackAdRevenue;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageTrackPushToken;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageTrackDeeplink;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageTrackThirdPartySharing;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageInActivateSdk;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageReactiveSdk;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageOfflineMode;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageOnlineMode;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageGdprForgetMe;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageAddGlobalCallbackParameter;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageRemoveGlobalCallbackParameterByKey;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageClearAllGlobalCallbackParameters;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageAddGlobalPartnerParameter;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageRemoveGlobalPartnerParameterByKey;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageClearAllGlobalPartnerParameters;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageAppWentToTheBackgroundManualCall;
FOUNDATION_EXPORT NSString *const ADJAdjustBridgeMessageAppWentToTheForegroundManualCall;

NS_ASSUME_NONNULL_END

@interface ADJAdjustBridge : NSObject

- (nullable instancetype)init NS_UNAVAILABLE;

+ (nullable ADJAdjustBridge *)instanceWithWKWebView:(nonnull WKWebView *)webView;

+ (nullable ADJAdjustBridge *)
instanceWithWKWebView:(nonnull WKWebView *)webView
adjustJsLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustJsLogSubscriber;

- (nonnull WKWebView *)webView;

@end
