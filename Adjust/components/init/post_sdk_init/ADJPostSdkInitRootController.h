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
#import "ADJSubscribingGateSubscriber.h"
#import "ADJPublishingGateSubscriber.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJMeasurementSessionController.h"
#import "ADJClientConfigData.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJSdkPackageSenderController.h"
#import "ADJMainQueueController.h"
#import "ADJEventController.h"

/*
#import "ADJAdRevenueController.h"
#import "ADJAttributionController.h"
#import "ADJBillingSubscriptionController.h"
#import "ADJLaunchedDeeplinkController.h"
#import "ADJPushTokenController.h"
#import "ADJKeepAliveController.h"
#import "ADJGlobalCallbackParametersController.h"
#import "ADJGlobalPartnerParametersController.h"
*/
#import "ADJReachabilityController.h"
#import "ADJPausingController.h"
/*
#import "ADJThirdPartySharingController.h"
#import "ADJClientSubscriptionsController.h"
#import "ADJLogQueueController.h"
#import "ADJAsaAttributionController.h"
*/
//#import "ADJEntryRoot.h"
@class ADJEntryRoot;
//#import "ADJPreSdkInitRootController.h"
@class ADJPreSdkInitRootController;

@interface ADJPostSdkInitRootController : ADJCommonBase<ADJClientActionsAPI,
    // subscriptions
    ADJMeasurementSessionStartSubscriber
>

- (void)ccSubscribeToPublishersWithMeasurementSessionStartPublisher:
    (nonnull ADJMeasurementSessionStartPublisher *)measurementSessionStartPublisher;
// publishers
@property (nonnull, readonly, strong, nonatomic)
    ADJSubscribingGatePublisher *subscribingGatePublisher;
@property (nonnull, readonly, strong, nonatomic)
    ADJPublishingGatePublisher *publishingGatePublisher;
@property (nonnull, readonly, strong, nonatomic) ADJSdkInitPublisher *sdkInitPublisher;

// instantiation
- (nonnull instancetype) initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              clientConfigData:(nonnull ADJClientConfigData *)clientConfigData
                                     entryRoot:(nonnull ADJEntryRoot *)entryRoot
                      preSdkInitRootController:(nonnull ADJPreSdkInitRootController *)preSdkInitRootController;
// public properties
@property (nonnull, readonly, strong, nonatomic) ADJClientConfigData *clientConfigData;
@property (nonnull, readonly, strong, nonatomic) ADJMeasurementSessionController *measurementSessionController;
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilder;
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageSenderController *sdkPackageSenderController;
@property (nonnull, readonly, strong, nonatomic) ADJMainQueueController *mainQueueController;
@property (nonnull, readonly, strong, nonatomic) ADJEventController *eventController;


/*
@property (nonnull, readonly, strong, nonatomic) ADJAdRevenueController *adRevenueController;
@property (nonnull, readonly, strong, nonatomic) ADJAttributionController *attributionController;
@property (nonnull, readonly, strong, nonatomic) ADJBillingSubscriptionController *billingSubscriptionController;
@property (nonnull, readonly, strong, nonatomic) ADJLaunchedDeeplinkController *launchedDeeplinkController;
@property (nonnull, readonly, strong, nonatomic) ADJPushTokenController *pushTokenController;
@property (nonnull, readonly, strong, nonatomic) ADJKeepAliveController *keepAliveController;
@property (nonnull, readonly, strong, nonatomic) ADJGlobalCallbackParametersController *globalCallbackParametersController;
@property (nonnull, readonly, strong, nonatomic) ADJGlobalPartnerParametersController *globalPartnerParametersController;
*/
@property (nonnull, readonly, strong, nonatomic) ADJReachabilityController *reachabilityController;
@property (nonnull, readonly, strong, nonatomic) ADJPausingController *pausingController;
/*
@property (nonnull, readonly, strong, nonatomic) ADJThirdPartySharingController *thirdPartySharingController;
@property (nonnull, readonly, strong, nonatomic) ADJClientSubscriptionsController *clientSubscriptionsController;
@property (nonnull, readonly, strong, nonatomic) ADJLogQueueController *logQueueController;
@property (nonnull, readonly, strong, nonatomic) ADJAsaAttributionController *asaAttributionController;
 */

// public api
- (void)
    ccSdkInitWithEntryRoot:(nonnull ADJEntryRoot *)entryRoot
    preSdkInitRootController:(nonnull ADJPreSdkInitRootController *)preSdkInitRootController;

- (nullable id<ADJClientActionsAPI>)sdkStartClientActionAPI;
@end
