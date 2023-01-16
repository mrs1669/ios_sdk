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

@protocol ADJAdjustInstance <NSObject>

// public api
- (void)sdkInitWithConfiguration:(nonnull ADJAdjustConfig *)adjustConfig;

- (void)trackEvent:(nonnull ADJAdjustEvent *)adjustEvent;

- (void)trackAdRevenue:(nonnull ADJAdjustAdRevenue *)adjustAdRevenue;

- (void)trackPushToken:(nonnull ADJAdjustPushToken *)adjustPushToken;

- (void)trackLaunchedDeeplink:(nonnull ADJAdjustLaunchedDeeplink *)adjustLaunchedDeeplink;

- (void)trackBillingSubscription:(nonnull ADJAdjustBillingSubscription *)adjustBillingSubscription;

- (void)trackThirdPartySharing:(nonnull ADJAdjustThirdPartySharing *)adjustThirdPartySharing;

- (void)adjustAttributionWithCallback:(nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback;

- (void)deviceIdsWithCallback:(nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback;

- (void)gdprForgetDevice;

- (void)inactivateSdk;
- (void)reactivateSdk;

- (void)switchToOfflineMode;
- (void)switchBackToOnlineMode;

- (void)appWentToTheForegroundManualCall;
- (void)appWentToTheBackgroundManualCall;

- (void)addGlobalCallbackParameterWithKey:(nonnull NSString *)key
                                    value:(nonnull NSString *)value;
- (void)removeGlobalCallbackParameterByKey:(nonnull NSString *)key;
- (void)clearAllGlobalCallbackParameters;

- (void)addGlobalPartnerParameterWithKey:(nonnull NSString *)key
                                    value:(nonnull NSString *)value;
- (void)removeGlobalPartnerParameterByKey:(nonnull NSString *)key;
- (void)clearAllGlobalPartnerParameters;

@end
