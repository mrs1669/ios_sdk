//
//  ADJAdjustInstance.h
//  Adjust
//
//  Created by Genady Buchatsky on 01.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADJAdjustConfig;
@class ADJAdjustEvent;
@class ADJAdjustAdRevenue;
@class ADJAdjustPushToken;
@class ADJAdjustLaunchedDeeplink;
@class ADJAdjustBillingSubscription;
@class ADJAdjustThirdPartySharing;
@class ADJAdjustInstance;
@protocol ADJAdjustAttributionCallback;
@protocol ADJAdjustDeviceIdsCallback;
@protocol ADJAdjustIdentifierCallback;
@protocol ADJAdjustLaunchedDeeplinkCallback;

@protocol ADJAdjustInstance <NSObject>

- (void)initSdkWithConfig:(nonnull ADJAdjustConfig *)adjustConfig;

- (void)inactivateSdk;
- (void)reactivateSdk;

- (void)gdprForgetDevice;

- (void)appWentToTheForegroundManualCall;
- (void)appWentToTheBackgroundManualCall;

- (void)switchToOfflineMode;
- (void)switchBackToOnlineMode;

- (void)activateMeasurementConsent;
- (void)inactivateMeasurementConsent;

- (void)adjustIdentifierWithCallback:
    (nonnull id<ADJAdjustIdentifierCallback>)adjustIdentifierCallback;
- (void)deviceIdsWithCallback:(nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback;
- (void)adjustAttributionWithCallback:
    (nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback;
- (void)adjustLaunchedDeeplinkWithCallback:
(nonnull id<ADJAdjustLaunchedDeeplinkCallback>)adjustLaunchedDeeplinkCallback;

- (void)sendEvent:(nonnull ADJAdjustEvent *)adjustEvent;

- (void)sendLaunchedDeeplink:(nonnull ADJAdjustLaunchedDeeplink *)adjustLaunchedDeeplink;

- (void)sendPushToken:(nonnull ADJAdjustPushToken *)adjustPushToken;

- (void)sendThirdPartySharing:(nonnull ADJAdjustThirdPartySharing *)adjustThirdPartySharing;

- (void)sendAdRevenue:(nonnull ADJAdjustAdRevenue *)adjustAdRevenue;

- (void)sendBillingSubscription:(nonnull ADJAdjustBillingSubscription *)adjustBillingSubscription;

- (void)addGlobalCallbackParameterWithKey:(nonnull NSString *)key
                                    value:(nonnull NSString *)value;
- (void)removeGlobalCallbackParameterByKey:(nonnull NSString *)key;
- (void)clearGlobalCallbackParameters;

- (void)addGlobalPartnerParameterWithKey:(nonnull NSString *)key
                                    value:(nonnull NSString *)value;
- (void)removeGlobalPartnerParameterByKey:(nonnull NSString *)key;
- (void)clearGlobalPartnerParameters;

@end
