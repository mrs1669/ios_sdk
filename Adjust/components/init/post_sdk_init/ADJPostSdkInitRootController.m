//
//  ADJPostSdkInitRootController.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJPostSdkInitRootController.h"

#import "ADJEntryRoot.h"
#import "ADJPreSdkInitRootController.h"
#import "ADJConstants.h"
#import "ADJConstantsSys.h"

#pragma mark Private class
@implementation ADJSubscribingGatePublisher @end
@implementation ADJPublishingGatePublisher @end
@implementation ADJSdkInitPublisher @end

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic)
 ADJSubscribingGatePublisher *subscribingGatePublisher;
 @property (nonnull, readonly, strong, nonatomic)
 ADJPublishingGatePublisher *publishingGatePublisher;
 @property (nonnull, readonly, strong, nonatomic) ADJSdkInitPublisher *sdkInitPublisher;

 @property (nonnull, readonly, strong, nonatomic) ADJClientConfigData *clientConfigData;
 @property (nonnull, readonly, strong, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilder;
 @property (nonnull, readonly, strong, nonatomic) ADJMeasurementSessionController *measurementSessionController;
 @property (nonnull, readonly, strong, nonatomic) ADJAdRevenueController *adRevenueController;
 @property (nonnull, readonly, strong, nonatomic)
 ADJAttributionController *attributionController;
 @property (nonnull, readonly, strong, nonatomic)
 ADJBillingSubscriptionController *billingSubscriptionController;
 @property (nonnull, readonly, strong, nonatomic)
 ADJLaunchedDeeplinkController *launchedDeeplinkController;
 @property (nonnull, readonly, strong, nonatomic) ADJEventController *eventController;
 @property (nonnull, readonly, strong, nonatomic) ADJPushTokenController *pushTokenController;
 @property (nonnull, readonly, strong, nonatomic) ADJKeepAliveController *keepAliveController;
 @property (nonnull, readonly, strong, nonatomic)
 ADJGlobalCallbackParametersController *globalCallbackParametersController;
 @property (nonnull, readonly, strong, nonatomic)
 ADJGlobalPartnerParametersController *globalPartnerParametersController;
 @property (nonnull, readonly, strong, nonatomic)
 ADJSdkPackageSenderController *sdkPackageSenderController;
 @property (nonnull, readonly, strong, nonatomic) ADJMainQueueController *mainQueueController;
 @property (nonnull, readonly, strong, nonatomic)
 ADJReachabilityController *reachabilityController;
 @property (nonnull, readonly, strong, nonatomic)
 ADJPausingController *pausingController;
 @property (nonnull, readonly, strong, nonatomic)
 ADJThirdPartySharingController *thirdPartySharingController;
 @property (nonnull, readonly, strong, nonatomic)
 ADJClientSubscriptionsController *clientSubscriptionsController;
 @property (nonnull, readonly, strong, nonatomic) ADJLogQueueController *logQueueController;
 @property (nonnull, readonly, strong, nonatomic) ADJAsaAttributionController *asaAttributionController;
 */

@interface ADJPostSdkInitRootController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJEntryRoot *entryRootWeak;
@property (nullable, readonly, weak, nonatomic) ADJPreSdkInitRootController *preSdkInitRootControllerWeak;

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL hasMeasurementSessionStart;

@end

@implementation ADJPostSdkInitRootController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             clientConfigData:(nonnull ADJClientConfigData *)clientConfigData
                                    entryRoot:(nonnull ADJEntryRoot *)entryRoot
                     preSdkInitRootController:(nonnull ADJPreSdkInitRootController *)preSdkInitRootController {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"PostSdkInitRootController"];
    _entryRootWeak = entryRoot;
    _preSdkInitRootControllerWeak = preSdkInitRootController;

    _subscribingGatePublisher = [[ADJSubscribingGatePublisher alloc] init];

    _publishingGatePublisher = [[ADJPublishingGatePublisher alloc] init];

    _clientConfigData = clientConfigData;

    _sdkInitPublisher = [[ADJSdkInitPublisher alloc] init];

    _hasMeasurementSessionStart = NO;

    ADJStorageRootController *_Nonnull storageRootController = preSdkInitRootController.storageRootController;

    ADJSdkConfigData *_Nonnull sdkConfigData = entryRoot.sdkConfigData;

    _globalCallbackParametersController = [[ADJGlobalCallbackParametersController alloc]
                                           initWithLoggerFactory:loggerFactory
                                           storage:storageRootController.globalCallbackParametersStorage];

    _globalPartnerParametersController = [[ADJGlobalPartnerParametersController alloc]
                                          initWithLoggerFactory:loggerFactory
                                          storage:storageRootController.globalPartnerParametersStorage];

    _sdkPackageBuilder = [[ADJSdkPackageBuilder alloc] initWithLoggerFactory:loggerFactory
                                                                       clock:preSdkInitRootController.clock
                                                                   clientSdk:ADJClientSdk
                                                            clientConfigData:clientConfigData
                                                            deviceController:preSdkInitRootController.deviceController
                                             globalCallbackParametersStorage:storageRootController.globalCallbackParametersStorage
                                              globalPartnerParametersStorage:storageRootController.globalPartnerParametersStorage
                                                           eventStateStorage:storageRootController.eventStateStorage
                                              measurementSessionStateStorage:storageRootController.measurementSessionStateStorage];

    _sdkPackageSenderController = [[ADJSdkPackageSenderController alloc] initWithLoggerFactory:loggerFactory
                                                                           networkEndpointData:sdkConfigData.networkEndpointData
                                                                             adjustUrlStrategy:clientConfigData.urlStrategy
                                                                      clientCustomEndpointData:clientConfigData.clientCustomEndpointData];

    _mainQueueController = [[ADJMainQueueController alloc] initWithLoggerFactory:loggerFactory
                                                                mainQueueStorage:storageRootController.mainQueueStorage
                                                                threadController:entryRoot.threadController
                                                                           clock:preSdkInitRootController.clock
                                                                 backoffStrategy:sdkConfigData.mainQueueBackoffStrategy
                                                         sdkPackageSenderFactory:self.sdkPackageSenderController];

    _measurementSessionController = [[ADJMeasurementSessionController alloc] initWithLoggerFactory:loggerFactory
                                                                minMeasurementSessionIntervalMilli:sdkConfigData.minMeasurementSessionIntervalMilli
                                                     overwriteFirstMeasurementSessionIntervalMilli:sdkConfigData.overwriteFirstMeasurementSessionIntervalMilli
                                                                                    clientExecutor:entryRoot.clientExecutor
                                                                                 sdkPackageBuilder:self.sdkPackageBuilder
                                                                    measurementSessionStateStorage:storageRootController.measurementSessionStateStorage
                                                                               mainQueueController:self.mainQueueController
                                                                                             clock:preSdkInitRootController.clock];

    _adRevenueController = [[ADJAdRevenueController alloc] initWithLoggerFactory:loggerFactory
                                                               sdkPackageBuilder:self.sdkPackageBuilder
                                                             mainQueueController:self.mainQueueController];

    /*
     _attributionController =
     [[ADJAttributionController alloc]
     initWithLoggerFactory:loggerFactory
     attributionStateStorage:storageRootController.attributionStateStorage
     clock:preSdkInitRootController.clock
     sdkPackageBuilder:self.sdkPackageBuilder
     threadController:entryRoot.threadController
     attributionBackoffStrategy:sdkConfigData.attributionBackoffStrategy
     sdkPackageSenderFactory:self.sdkPackageSenderController
     mainQueueController:self.mainQueueController
     doNotInitiateAttributionFromSdk:sdkConfigData.doNotInitiateAttributionFromSdk];

     _billingSubscriptionController =
     [[ADJBillingSubscriptionController alloc]
     initWithLoggerFactory:loggerFactory
     sdkPackageBuilder:self.sdkPackageBuilder
     mainQueueController:self.mainQueueController];

     _launchedDeeplinkController =
     [[ADJLaunchedDeeplinkController alloc] initWithLoggerFactory:loggerFactory
     sdkPackageBuilder:self.sdkPackageBuilder
     mainQueueController:self.mainQueueController];
     */
    _eventController = [[ADJEventController alloc] initWithLoggerFactory:loggerFactory
                                                       sdkPackageBuilder:self.sdkPackageBuilder
                                                       eventStateStorage:storageRootController.eventStateStorage
                                               eventDeduplicationStorage:storageRootController.eventDeduplicationStorage
                                                     mainQueueController:self.mainQueueController
                                           maxCapacityEventDeduplication:clientConfigData.eventIdDeduplicationMaxCapacity];
    /*
     _pushTokenController = [[ADJPushTokenController alloc]
     initWithLoggerFactory:loggerFactory
     sdkPackageBuilder:self.sdkPackageBuilder
     mainQueueController:self.mainQueueController];

     _keepAliveController =
     [[ADJKeepAliveController alloc]
     initWithLoggerFactory:loggerFactory
     threadExecutorFactory:entryRoot.threadController
     foregroundTimerStartMilli:sdkConfigData.foregroundTimerStartMilli
     foregroundTimerIntervalMilli:sdkConfigData.foregroundTimerIntervalMilli];
     */

    _reachabilityController = [[ADJReachabilityController alloc] initWithLoggerFactory:loggerFactory
                                                                      threadController:entryRoot.threadController
                                                                        targetEndpoint:[self.mainQueueController defaultTargetUrl]];
    _pausingController = [[ADJPausingController alloc] initWithLoggerFactory:loggerFactory
                                                       threadExecutorFactory:entryRoot.threadController
                                                         canSendInBackground:clientConfigData.canSendInBackground];
    /*
     _thirdPartySharingController =
     [[ADJThirdPartySharingController alloc]
     initWithLoggerFactory:loggerFactory
     sdkPackageBuilder:self.sdkPackageBuilder
     mainQueueController:self.mainQueueController];

     _clientSubscriptionsController =
     [[ADJClientSubscriptionsController alloc]
     initWithLoggerFactory:loggerFactory
     threadController:entryRoot.threadController
     clientReturnExecutor:[entryRoot clientReturnExecutor]
     adjustAttributionSubscriber:clientConfigData.adjustAttributionSubscriber
     adjustLogSubscriber:clientConfigData.adjustLogSubscriber
     doNotOpenDeferredDeeplink:clientConfigData.doNotOpenDeferredDeeplink];

     _logQueueController =
     [[ADJLogQueueController alloc]
     initWithLoggerFactory:loggerFactory
     storage:storageRootController.logQueueStorage
     threadController:entryRoot.threadController
     clock:preSdkInitRootController.clock
     backoffStrategy:sdkConfigData.mainQueueBackoffStrategy
     sdkPackageSenderFactory:self.sdkPackageSenderController];

     _asaAttributionController =
     [[ADJAsaAttributionController alloc]
     initWithLoggerFactory:loggerFactory
     threadExecutorFactory:entryRoot.threadController
     sdkPackageBuilder:self.sdkPackageBuilder
     asaAttributionStateStorage:storageRootController.asaAttributionStateStorage
     clock:preSdkInitRootController.clock
     threadPool:entryRoot.threadController
     clientConfigData:clientConfigData
     asaAttributionConfig:sdkConfigData.asaAttributionConfigData
     logQueueController:self.logQueueController
     mainQueueController:self.mainQueueController
     adjustAttributionStateStorage:storageRootController.attributionStateStorage];
     */
    return self;
    /*
     googlePlayInstallReferrerController = new GooglePlayInstallReferrerController(
     entryRoot.logController,
     preSdkInitRootController.application,
     entryRoot.sdkConfigData.googlePlayInstallReferrerConfigData,
     sdkPackageBuilder,
     storageRootController.googlePlayInstallReferrerStateStorage,
     mainQueueController,
     entryRoot.threadPoolExecutor,
     preSdkInitRootController.runtimeFinalizerController);

     huaweiInstallReferrerController = new HuaweiInstallReferrerController(
     entryRoot.logController,
     preSdkInitRootController.application,
     entryRoot.sdkConfigData.huaweiInstallReferrerConfigData,
     sdkPackageBuilder,
     storageRootController.huaweiInstallReferrerStorage,
     mainQueueController,
     entryRoot.threadPoolExecutor,
     preSdkInitRootController.runtimeFinalizerController);
     */
}

#pragma mark Public API
- (void)ccSdkInitWithEntryRoot:(nonnull ADJEntryRoot *)entryRoot
      preSdkInitRootController:(nonnull ADJPreSdkInitRootController *)preSdkInitRootController {
    [self ccSubscribeAllWithEntryRoot:entryRoot preSdkInitRootController:preSdkInitRootController];

    [self ccOpenPubSubGates];

    [self.sdkInitPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJSdkInitSubscriber> _Nonnull subscriber)
     {
        [subscriber ccOnSdkInitWithClientConfigData:self.clientConfigData];
    }];
}

- (nullable id<ADJClientActionsAPI>)sdkStartClientActionAPI {
    if (self.hasMeasurementSessionStart) {
        return self;
    } else {
        return nil;
    }
}

#pragma mark - Subscriptions
- (void)ccSubscribeToPublishersWithMeasurementSessionStartPublisher:(nonnull ADJMeasurementSessionStartPublisher *)measurementSessionStartPublisher {
    [measurementSessionStartPublisher addSubscriber:self];
}

#pragma mark - ADJMeasurementSessionStartPublisher
- (void)ccMeasurementSessionStartWithStatus:(nonnull NSString *)measurementSessionStartStatus {
    self.hasMeasurementSessionStart = YES;
}

#pragma mark - ADJClientActionsAPI
- (void)ccTrackAdRevenueWithClientData:(nonnull ADJClientAdRevenueData *)clientAdRevenueData {
    [self.adRevenueController ccTrackAdRevenueWithClientData:clientAdRevenueData];
}

/*
 - (void)ccTrackBillingSubscriptionWithClientData:
 (nonnull ADJClientBillingSubscriptionData *)clientBillingSubscriptionData
 {
 [self.billingSubscriptionController
 ccTrackBillingSubscriptionWithClientData:clientBillingSubscriptionData];
 }

 - (void)ccTrackLaunchedDeeplinkWithClientData:
 (nonnull ADJClientLaunchedDeeplinkData *)clientLaunchedDeeplinkData;
 {
 [self.launchedDeeplinkController
 ccTrackLaunchedDeeplinkWithClientData:clientLaunchedDeeplinkData];
 }
 */

- (void)ccTrackEventWithClientData:(nonnull ADJClientEventData *)clientEventData {
    [self.eventController ccTrackEventWithClientData:clientEventData];
}

/*
 - (void)ccTrackPushTokenWithClientData:(nonnull ADJClientPushTokenData *)clientPushTokenData {
 [self.pushTokenController ccTrackPushTokenWithClientData:clientPushTokenData];
 }

 - (void)ccTrackThirdPartySharingWithClientData:
 (nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData
 {
 [self.thirdPartySharingController
 ccTrackThirdPartySharingWithClientData:clientThirdPartySharingData];
 }
*/
- (void)ccAddGlobalCallbackParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalCallbackParameterActionData {
    [self.globalCallbackParametersController
     ccAddGlobalCallbackParameterWithClientData:clientAddGlobalCallbackParameterActionData];
}

- (void)ccRemoveGlobalCallbackParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalCallbackParameterActionData {
    [self.globalCallbackParametersController
     ccRemoveGlobalCallbackParameterWithClientData:
         clientRemoveGlobalCallbackParameterActionData];
}

- (void)ccClearGlobalCallbackParametersWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalCallbackParametersActionData {
    [self.globalCallbackParametersController
     ccClearGlobalCallbackParameterWithClientData:
         clientClearGlobalCallbackParametersActionData];
}

- (void)ccAddGlobalPartnerParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalPartnerParameterActionData{
    [self.globalPartnerParametersController
     ccAddGlobalPartnerParameterWithClientData:clientAddGlobalPartnerParameterActionData];
}

- (void)ccRemoveGlobalPartnerParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalPartnerParameterActionData {
    [self.globalPartnerParametersController
     ccRemoveGlobalPartnerParameterWithClientData:clientRemoveGlobalPartnerParameterActionData];
}
- (void)ccClearGlobalPartnerParametersWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalPartnerParametersActionData {
    [self.globalPartnerParametersController
     ccClearGlobalPartnerParameterWithClientData:clientClearGlobalPartnerParametersActionData];
}

#pragma mark Internal Methods
- (void)ccSubscribeAllWithEntryRoot:(nonnull ADJEntryRoot *)entryRoot
           preSdkInitRootController:(nonnull ADJPreSdkInitRootController *)preSdkInitRootController {

    [entryRoot ccSubscribeAndSetPostSdkInitDependenciesWithSdkInitPublisher:self.sdkInitPublisher
                                                    publishingGatePublisher:self.publishingGatePublisher];

    [preSdkInitRootController ccSubscribeAndSetPostSdkInitDependenciesWithEntryRoot:entryRoot
                                                          postSdkInitRootController:self
                                                                   sdkInitPublisher:self.sdkInitPublisher
                                                            publishingGatePublisher:self.publishingGatePublisher];

    [self ccSubscribeAndSetPostSdkInitDependenciesWithEntryRoot:entryRoot
                                       preSdkInitRootController:preSdkInitRootController];
}

- (void)ccSubscribeAndSetPostSdkInitDependenciesWithEntryRoot:(nonnull ADJEntryRoot *)entryRoot
                                     preSdkInitRootController:(nonnull ADJPreSdkInitRootController *)preSdkInitRootController {
    /*
     // subscribe controllers to publishers
     [self.attributionController
     ccSubscribeToPublishersWithPublishingGatePublisher:self.publishingGatePublisher
     measurementSessionStartPublisher:self.measurementSessionController.measurementSessionStartPublisher
     sdkResponsePublisher:self.sdkPackageSenderController.sdkResponsePublisher
     pausingPublisher:self.pausingController.pausingPublisher];

     [self.asaAttributionController
     ccSubscribeToPublishersWithKeepAlivePublisher:self.keepAliveController.keepAlivePublisher
     preFirstMeasurementSessionStartPublisher:self.measurementSessionController.preFirstMeasurementSessionStartPublisher
     sdkResponsePublisher:self.sdkPackageSenderController.sdkResponsePublisher
     attributionPublisher:self.attributionController.attributionPublisher
     sdkPackageSendingPublisher:self.sdkPackageSenderController.sdkPackageSendingPublisher];

     [self.clientSubscriptionsController
     ccSubscribeToPublishersWithAttributionPublisher:
     self.attributionController.attributionPublisher
     logPublisher:entryRoot.logController.logPublisher];

     [self.keepAliveController
     ccSubscribeToPublishersWithMeasurementSessionStartPublisher:
     self.measurementSessionController.measurementSessionStartPublisher
     lifecyclePublisher:preSdkInitRootController.lifecycleController.lifecyclePublisher];

     [self.logQueueController
     ccSubscribeToPublishersWithSdkInitPublisher:self.sdkInitPublisher
     pausingPublisher:self.pausingController.pausingPublisher];
     */
    [self.mainQueueController
     ccSubscribeToPublishersWithSdkInitPublisher:self.sdkInitPublisher
     pausingPublisher:self.pausingController.pausingPublisher
     offlinePublisher:preSdkInitRootController.offlineController.offlinePublisher];

    [self.pausingController
     ccSubscribeToPublishersWithPublishingGate:self.publishingGatePublisher
     offlinePublisher:preSdkInitRootController.offlineController.offlinePublisher
     reachabilityPublisher:self.reachabilityController.reachabilityPublisher
     lifecyclePublisher:preSdkInitRootController.lifecycleController.lifecyclePublisher
     measurementSessionStartPublisher:self.measurementSessionController.measurementSessionStartPublisher
     sdkActivePublisher:preSdkInitRootController.sdkActivePublisher];
    /*
     [self.reachabilityController
     ccSubscribeToPublishersWithmeasurementSessionStartPublisher:
     self.measurementSessionController.measurementSessionStartPublisher];
     */
    [self.measurementSessionController ccSubscribeToPublishersWithSdkActivePublisher:preSdkInitRootController.sdkActivePublisher
                                                                    sdkInitPublisher:self.sdkInitPublisher
                                                                  keepAlivePublisher:nil //self.keepAliveController.keepAlivePublisher
                                                                  lifecyclePublisher:preSdkInitRootController.lifecycleController.lifecyclePublisher];

    // subscribe self to publishers
    [self.measurementSessionController.measurementSessionStartPublisher addSubscriber:self];
}

/*
 // inject post sdk init dependencies
 sdkPackageBuilder.setDependenciesAtSdkInit(
 eventController,
 measurementSessionController);

 // subscribe controllers to publishers
 // clientSubscriptionsController.subscribeToPublishers();

 sdkResponseAggregator.subscribeToPublishers(
 mainQueueController.adRevenueResponsePublisher(),
 attributionController.attributionResponsePublisher(),
 mainQueueController.billingSubscriptionResponsePublisher(),
 mainQueueController.clickResponsePublisher(),
 mainQueueController.eventResponsePublisher(),
 preSdkInitRootController.gdprForgetController.gdprForgetResponsePublisher(),
 mainQueueController.infoResponsePublisher(),
 mainQueueController.sessionResponsePublisher(),
 mainQueueController.thirdPartySharingResponsePublisher());

 sendingController.subscribeToPublishers(
 publishingGatePublisher,
 preAppContextInitController.offlineController.offlinePublisher(),
 connectivityController.connectivityPublisher(),
 preAppContextInitController.lifecycleController.lifecyclePublisher(),
 measurementSessionController.sdkStartPublisher(),
 preSdkInitRootController.sdkActivePublisher());

 connectivityController.subscribeToPublishers(
 measurementSessionController.sdkStartPublisher());

 googlePlayInstallReferrerController.subscribeToPublishers(
 measurementSessionController.sdkStartPublisher());

 huaweiInstallReferrerController.subscribeToPublishers(
 measurementSessionController.sdkStartPublisher());

 */
- (void)ccOpenPubSubGates {
    [self.subscribingGatePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJSubscribingGateSubscriber> _Nonnull subscriber)
     {
        [subscriber ccAllowedToReceiveNotifications];
    }];

    [self.publishingGatePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJPublishingGateSubscriber> _Nonnull subscriber)
     {
        [subscriber ccAllowedToPublishNotifications];
    }];
}

@end
