//
//  ADJPostSdkStartRoot.h
//  Adjust
//
//  Created by Pedro Silva on 01.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientActionsAPI.h"
#import "ADJAdRevenueController.h"
#import "ADJBillingSubscriptionController.h"
#import "ADJLaunchedDeeplinkController.h"
#import "ADJEventController.h"
#import "ADJPushTokenController.h"
#import "ADJThirdPartySharingController.h"
#import "ADJGlobalCallbackParametersController.h"
#import "ADJGlobalPartnerParametersController.h"

#import "ADJClientConfigData.h"
#import "ADJLoggerFactory.h"
#import "ADJStorageRoot.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJMainQueueController.h"

@interface ADJPostSdkStartRoot : NSObject <
    ADJClientActionsAPI
>
// instantiation
- (nonnull instancetype)
    initWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData
    loggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    storageRoot:(nonnull ADJStorageRoot *)storageRoot
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    mainQueueController:(nonnull ADJMainQueueController *)mainQueueController;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (nullable id<ADJClientActionHandler>)handlerById:(nonnull ADJNonEmptyString *)clientHandlerId;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJAdRevenueController *adRevenueController;
@property (nonnull, readonly, strong, nonatomic)
    ADJBillingSubscriptionController *billingSubscriptionController;
@property (nonnull, readonly, strong, nonatomic)
    ADJLaunchedDeeplinkController *launchedDeeplinkController;
@property (nonnull, readonly, strong, nonatomic) ADJEventController *eventController;
@property (nonnull, readonly, strong, nonatomic) ADJPushTokenController *pushTokenController;
@property (nonnull, readonly, strong, nonatomic)
    ADJThirdPartySharingController *thirdPartySharingController;
@property (nonnull, readonly, strong, nonatomic)
    ADJGlobalCallbackParametersController *globalCallbackParametersController;
@property (nonnull, readonly, strong, nonatomic)
    ADJGlobalPartnerParametersController *globalPartnerParametersController;

@end
