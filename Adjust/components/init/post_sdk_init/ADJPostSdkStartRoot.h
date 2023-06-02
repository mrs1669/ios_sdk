//
//  ADJPostSdkStartRoot.h
//  Adjust
//
//  Created by Pedro Silva on 01.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientActionsAPIPostSdkStart.h"
#import "ADJAdRevenueController.h"
#import "ADJBillingSubscriptionController.h"
#import "ADJLaunchedDeeplinkController.h"
#import "ADJEventController.h"
#import "ADJPushTokenController.h"
#import "ADJMeasurementConsentController.h"
#import "ADJThirdPartySharingController.h"
#import "ADJGlobalCallbackParametersController.h"
#import "ADJGlobalPartnerParametersController.h"
#import "ADJClientConfigData.h"
#import "ADJInstanceRootBag.h"
#import "ADJPreSdkInitRootBag.h"

@interface ADJPostSdkStartRoot : NSObject <
    ADJClientActionsAPIPostSdkStart
>

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJAdRevenueController *adRevenueController;
@property (nonnull, readonly, strong, nonatomic)
ADJBillingSubscriptionController *billingSubscriptionController;
@property (nonnull, readonly, strong, nonatomic)
ADJLaunchedDeeplinkController *launchedDeeplinkController;
@property (nonnull, readonly, strong, nonatomic) ADJEventController *eventController;
@property (nonnull, readonly, strong, nonatomic) ADJPushTokenController *pushTokenController;
@property (nonnull, readonly, strong, nonatomic)
ADJMeasurementConsentController *measurementConsentController;
@property (nonnull, readonly, strong, nonatomic)
ADJThirdPartySharingController *thirdPartySharingController;
@property (nonnull, readonly, strong, nonatomic)
ADJGlobalCallbackParametersController *globalCallbackParametersController;
@property (nonnull, readonly, strong, nonatomic)
ADJGlobalPartnerParametersController *globalPartnerParametersController;

// instantiation
- (nonnull instancetype)initWithClientConfigData:(nonnull ADJClientConfigData *)clientConfig
                                 instanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag
                               preSdkInitRootBag:(nonnull id<ADJPreSdkInitRootBag>)preSdkInitRootBag
                               sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                             mainQueueController:(nonnull ADJMainQueueController *)mainQueueController;

- (nullable instancetype)init NS_UNAVAILABLE;

@end
