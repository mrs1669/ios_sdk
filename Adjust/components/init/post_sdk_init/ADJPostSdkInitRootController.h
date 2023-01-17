//
//  ADJPostSdkInitRootController.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJCommonBase.h"
#import "ADJClientActionsAPI.h"
#import "ADJMeasurementSessionStartSubscriber.h"
#import "ADJMeasurementSessionController.h"
#import "ADJClientConfigData.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJSdkPackageSenderController.h"
#import "ADJEventController.h"
#import "ADJAdRevenueController.h"
#import "ADJGlobalCallbackParametersController.h"
#import "ADJGlobalPartnerParametersController.h"
#import "ADJBillingSubscriptionController.h"
#import "ADJLaunchedDeeplinkController.h"
#import "ADJPushTokenController.h"
#import "ADJThirdPartySharingController.h"
#import "ADJPublishersRegistry.h"
#import "ADJStorageRootController.h"
#import "ADJReachabilityController.h"
#import "ADJSdkConfigData.h"

@interface ADJPostSdkInitRootController : ADJCommonBase<
ADJClientActionsAPI,
// subscriptions
ADJMeasurementSessionStartSubscriber
>
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilder;
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageSenderController *sdkPackageSenderController;
@property (nonnull, readonly, strong, nonatomic) ADJMeasurementSessionController *measurementSessionController;
@property (nonnull, readonly, strong, nonatomic) ADJAdRevenueController *adRevenueController;
@property (nonnull, readonly, strong, nonatomic) ADJBillingSubscriptionController *billingSubscriptionController;
@property (nonnull, readonly, strong, nonatomic) ADJLaunchedDeeplinkController *launchedDeeplinkController;
@property (nonnull, readonly, strong, nonatomic) ADJEventController *eventController;
@property (nonnull, readonly, strong, nonatomic) ADJGlobalCallbackParametersController *globalCallbackParametersController;
@property (nonnull, readonly, strong, nonatomic) ADJGlobalPartnerParametersController *globalPartnerParametersController;
@property (nonnull, readonly, strong, nonatomic) ADJPushTokenController *pushTokenController;
@property (nonnull, readonly, strong, nonatomic) ADJThirdPartySharingController *thirdPartySharingController;
@property (nonnull, readonly, strong, nonatomic) ADJReachabilityController *reachabilityController;


- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                threadFactory:(nonnull ADJThreadController *)threadFactory
                               clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
                         clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
                        storageRootController:(nonnull ADJStorageRootController *)storageRootController
                             deviceController:(nonnull ADJDeviceController *)deviceController
                             clientConfigData:(nonnull ADJClientConfigData *)clientConfigData
                                sdkConfigData:(nonnull ADJSdkConfigData *)sdkConfigData
                                        clock:(nonnull ADJClock *)clock
                           publishersRegistry:(nonnull ADJPublishersRegistry *)pubRegistry;

- (void)subscribeToPublishers:(nonnull ADJPublishersRegistry *)pubRegistry;
- (void)startSdk;

- (nullable id<ADJClientActionsAPI>)sdkStartClientActionAPI;

@end
