//
//  ADJPostSdkInitRootController.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//
#import "ADJPostSdkInitRootController.h"
#import "ADJConstantsSys.h"
#import "ADJSubscribingGateSubscriber.h"
#import "ADJPublishingGateSubscriber.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJAttributionController.h"
#import "ADJKeepAliveController.h"
#import "ADJPausingController.h"
#import "ADJClientSubscriptionsController.h"
#import "ADJLogQueueController.h"
#import "ADJAsaAttributionController.h"

#pragma mark Private class
@implementation ADJSubscribingGatePublisher @end
@implementation ADJPublishingGatePublisher @end
@implementation ADJSdkInitPublisher @end

#pragma mark Fields
#pragma mark - Public properties
/* .h
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
 */

@interface ADJPostSdkInitRootController ()
// publishers
@property (nonnull, readonly, strong, nonatomic) ADJSubscribingGatePublisher *subscribingGatePublisher;
@property (nonnull, readonly, strong, nonatomic) ADJPublishingGatePublisher *publishingGatePublisher;
@property (nonnull, readonly, strong, nonatomic) ADJSdkInitPublisher *sdkInitPublisher;
@property (nonnull, readonly, strong, nonatomic) ADJClientConfigData *clientConfigData;
@property (nonnull, readonly, strong, nonatomic) ADJMainQueueController *mainQueueController;
@property (nonnull, readonly, strong, nonatomic) ADJAttributionController *attributionController;
@property (nonnull, readonly, strong, nonatomic) ADJKeepAliveController *keepAliveController;
@property (nonnull, readonly, strong, nonatomic) ADJPausingController *pausingController;
@property (nonnull, readonly, strong, nonatomic) ADJClientSubscriptionsController *clientSubscriptionsController;
@property (nonnull, readonly, strong, nonatomic) ADJLogQueueController *logQueueController;
@property (nonnull, readonly, strong, nonatomic) ADJAsaAttributionController *asaAttributionController;
#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL hasMeasurementSessionStart;
@end

@implementation ADJPostSdkInitRootController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadFactory:(nonnull ADJThreadController *)threadFactory
    clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
    clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
    storageRootController:(nonnull ADJStorageRootController *)storageRootController
    deviceController:(nonnull ADJDeviceController *)deviceController
    clientConfigData:(nonnull ADJClientConfigData *)clientConfigData
    sdkConfigData:(nonnull ADJSdkConfigData *)sdkConfigData
    sdkPrefix:(nullable NSString *)sdkPrefix
    clock:(nonnull ADJClock *)clock
    publisherController:(nonnull ADJPublisherController *)publisherController
{
    self = [super initWithLoggerFactory:loggerFactory source:@"PostSdkInitRootController"];
    _clientConfigData = clientConfigData;

    _hasMeasurementSessionStart = NO;

    _subscribingGatePublisher = [[ADJSubscribingGatePublisher alloc]
                                 initWithSubscriberProtocol:@protocol(ADJSubscribingGateSubscriber)
                                 controller:publisherController];

    _publishingGatePublisher = [[ADJPublishingGatePublisher alloc]
                                initWithSubscriberProtocol:@protocol(ADJPublishingGateSubscriber)
                                controller:publisherController];

    _sdkInitPublisher = [[ADJSdkInitPublisher alloc]
                         initWithSubscriberProtocol:@protocol(ADJSdkInitSubscriber)
                         controller:publisherController];

    _globalCallbackParametersController = [[ADJGlobalCallbackParametersController alloc] initWithLoggerFactory:loggerFactory
                                                                                                       storage:storageRootController.globalCallbackParametersStorage];

    _globalPartnerParametersController = [[ADJGlobalPartnerParametersController alloc] initWithLoggerFactory:loggerFactory
                                                                                                     storage:storageRootController.globalPartnerParametersStorage];

    _sdkPackageBuilder =
        [[ADJSdkPackageBuilder alloc]
         initWithLoggerFactory:loggerFactory
         clock:clock
         sdkPrefix:sdkPrefix
         clientConfigData:clientConfigData
         deviceController:deviceController
         globalCallbackParametersStorage:storageRootController.globalCallbackParametersStorage
         globalPartnerParametersStorage:storageRootController.globalPartnerParametersStorage
         eventStateStorage:storageRootController.eventStateStorage
         measurementSessionStateStorage:storageRootController.measurementSessionStateStorage
         publisherController:publisherController];

    _sdkPackageSenderController =
        [[ADJSdkPackageSenderController alloc]
         initWithLoggerFactory:loggerFactory
         networkEndpointData:sdkConfigData.networkEndpointData
         adjustUrlStrategy:clientConfigData.urlStrategy
         clientCustomEndpointData:clientConfigData.clientCustomEndpointData
         publisherController:publisherController];

    _mainQueueController =
        [[ADJMainQueueController alloc]
         initWithLoggerFactory:loggerFactory
         mainQueueStorage:storageRootController.mainQueueStorage
         threadController:threadFactory
         clock:clock
         backoffStrategy:sdkConfigData.mainQueueBackoffStrategy
         sdkPackageSenderFactory:self.sdkPackageSenderController];

    _measurementSessionController =
        [[ADJMeasurementSessionController alloc]
         initWithLoggerFactory:loggerFactory
         minMeasurementSessionIntervalMilli:sdkConfigData.minMeasurementSessionIntervalMilli
         overwriteFirstMeasurementSessionIntervalMilli:sdkConfigData.overwriteFirstMeasurementSessionIntervalMilli
         clientExecutor:clientExecutor
         sdkPackageBuilder:self.sdkPackageBuilder
         measurementSessionStateStorage:storageRootController.measurementSessionStateStorage
         mainQueueController:self.mainQueueController
         clock:clock
         publisherController:publisherController];

    _adRevenueController = [[ADJAdRevenueController alloc]
                            initWithLoggerFactory:loggerFactory
                            sdkPackageBuilder:self.sdkPackageBuilder
                            mainQueueController:self.mainQueueController];


    _attributionController =
        [[ADJAttributionController alloc]
         initWithLoggerFactory:loggerFactory
         attributionStateStorage:storageRootController.attributionStateStorage
         clock:clock
         sdkPackageBuilder:self.sdkPackageBuilder
         threadController:threadFactory
         attributionBackoffStrategy:sdkConfigData.attributionBackoffStrategy
         sdkPackageSenderFactory:self.sdkPackageSenderController
         mainQueueController:self.mainQueueController
         doNotInitiateAttributionFromSdk:sdkConfigData.doNotInitiateAttributionFromSdk
         publisherController:publisherController];

    _billingSubscriptionController = [[ADJBillingSubscriptionController alloc] initWithLoggerFactory:loggerFactory
                                                                                   sdkPackageBuilder:self.sdkPackageBuilder
                                                                                 mainQueueController:self.mainQueueController];

    _launchedDeeplinkController = [[ADJLaunchedDeeplinkController alloc] initWithLoggerFactory:loggerFactory
                                                                             sdkPackageBuilder:self.sdkPackageBuilder
                                                                           mainQueueController:self.mainQueueController];

    _eventController = [[ADJEventController alloc] initWithLoggerFactory:loggerFactory
                                                       sdkPackageBuilder:self.sdkPackageBuilder
                                                       eventStateStorage:storageRootController.eventStateStorage
                                               eventDeduplicationStorage:storageRootController.eventDeduplicationStorage
                                                     mainQueueController:self.mainQueueController
                                           maxCapacityEventDeduplication:clientConfigData.eventIdDeduplicationMaxCapacity];

    _pushTokenController = [[ADJPushTokenController alloc] initWithLoggerFactory:loggerFactory
                                                               sdkPackageBuilder:self.sdkPackageBuilder
                                                           pushTokenStateStorage:storageRootController.pushTokenStorage
                                                             mainQueueController:self.mainQueueController];

    _keepAliveController = [[ADJKeepAliveController alloc]
                            initWithLoggerFactory:loggerFactory
                            threadExecutorFactory:threadFactory
                            foregroundTimerStartMilli:sdkConfigData.foregroundTimerStartMilli
                            foregroundTimerIntervalMilli:sdkConfigData.foregroundTimerIntervalMilli
                            publisherController:publisherController];

    _reachabilityController = [[ADJReachabilityController alloc]
                               initWithLoggerFactory:loggerFactory
                               threadController:threadFactory
                               targetEndpoint:[self.mainQueueController defaultTargetUrl]
                               publisherController:publisherController];

    _pausingController = [[ADJPausingController alloc]
                          initWithLoggerFactory:loggerFactory
                          threadExecutorFactory:threadFactory
                          canSendInBackground:clientConfigData.canSendInBackground
                          publisherController:publisherController];

    _clientSubscriptionsController = [[ADJClientSubscriptionsController alloc] initWithLoggerFactory:loggerFactory
                                                                                    threadController:threadFactory
                                                                                clientReturnExecutor:clientReturnExecutor
                                                                         adjustAttributionSubscriber:clientConfigData.adjustAttributionSubscriber
                                                                                 adjustLogSubscriber:clientConfigData.adjustLogSubscriber
                                                                           doNotOpenDeferredDeeplink:clientConfigData.doNotOpenDeferredDeeplink];

    _thirdPartySharingController = [[ADJThirdPartySharingController alloc] initWithLoggerFactory:loggerFactory
                                                                               sdkPackageBuilder:self.sdkPackageBuilder
                                                                             mainQueueController:self.mainQueueController];


    _logQueueController = [[ADJLogQueueController alloc] initWithLoggerFactory:loggerFactory
                                                                       storage:storageRootController.logQueueStorage
                                                              threadController:threadFactory
                                                                         clock:clock
                                                               backoffStrategy:sdkConfigData.mainQueueBackoffStrategy
                                                       sdkPackageSenderFactory:self.sdkPackageSenderController];


    _asaAttributionController =
        [[ADJAsaAttributionController alloc]
            initWithLoggerFactory:loggerFactory
            threadExecutorFactory:threadFactory
            sdkPackageBuilder:self.sdkPackageBuilder
            asaAttributionStateStorage:storageRootController.asaAttributionStateStorage
            clock:clock
            clientConfigData:clientConfigData
            asaAttributionConfig:sdkConfigData.asaAttributionConfigData
            logQueueController:self.logQueueController
            mainQueueController:self.mainQueueController
            adjustAttributionStateStorage:storageRootController.attributionStateStorage];

    return self;
}

#pragma mark Public API
- (void)subscribeToPublishers:(nonnull ADJPublisherController *)publisherController {
    // subscribe controllers to publishers
    [publisherController subscribeToPublisher:self.attributionController];
    [publisherController subscribeToPublisher:self.keepAliveController];
    [publisherController subscribeToPublisher:self.clientSubscriptionsController];
    [publisherController subscribeToPublisher:self.asaAttributionController];
    [publisherController subscribeToPublisher:self.logQueueController];
    [publisherController subscribeToPublisher:self.mainQueueController];
    [publisherController subscribeToPublisher:self.pausingController];
    [publisherController subscribeToPublisher:self.reachabilityController];
    [publisherController subscribeToPublisher:self.measurementSessionController];
    // subscribe self to publishers
    [publisherController subscribeToPublisher:self];
}

- (void)startSdk {

    // Open publishers / subscribers gates
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

    // Send Sdk Init to all subscribers
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

#pragma mark - ADJMeasurementSessionStartPublisher
- (void)ccMeasurementSessionStartWithStatus:(nonnull NSString *)measurementSessionStartStatus {
    self.hasMeasurementSessionStart = YES;
}

#pragma mark - ADJClientActionsAPI
- (void)ccTrackAdRevenueWithClientData:(nonnull ADJClientAdRevenueData *)clientAdRevenueData {
    [self.adRevenueController ccTrackAdRevenueWithClientData:clientAdRevenueData];
}

- (void)ccTrackBillingSubscriptionWithClientData:(nonnull ADJClientBillingSubscriptionData *)clientBillingSubscriptionData {
    [self.billingSubscriptionController ccTrackBillingSubscriptionWithClientData:clientBillingSubscriptionData];
}

- (void)ccTrackLaunchedDeeplinkWithClientData:(nonnull ADJClientLaunchedDeeplinkData *)clientLaunchedDeeplinkData {
    [self.launchedDeeplinkController ccTrackLaunchedDeeplinkWithClientData:clientLaunchedDeeplinkData];
}

- (void)ccTrackEventWithClientData:(nonnull ADJClientEventData *)clientEventData {
    [self.eventController ccTrackEventWithClientData:clientEventData];
}

- (void)ccTrackPushTokenWithClientData:(nonnull ADJClientPushTokenData *)clientPushTokenData {
    [self.pushTokenController ccTrackPushTokenWithClientData:clientPushTokenData];
}

- (void)ccTrackThirdPartySharingWithClientData:(nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData {
    [self.thirdPartySharingController ccTrackThirdPartySharingWithClientData:clientThirdPartySharingData];
}

#pragma mark - ADJGlobalCallbackParameter
- (void)ccAddGlobalCallbackParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalCallbackParameterActionData {
    [self.globalCallbackParametersController ccAddGlobalCallbackParameterWithClientData:clientAddGlobalCallbackParameterActionData];
}

- (void)ccRemoveGlobalCallbackParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalCallbackParameterActionData {
    [self.globalCallbackParametersController ccRemoveGlobalCallbackParameterWithClientData:clientRemoveGlobalCallbackParameterActionData];
}

- (void)ccClearGlobalCallbackParametersWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalCallbackParametersActionData {
    [self.globalCallbackParametersController ccClearGlobalCallbackParameterWithClientData:clientClearGlobalCallbackParametersActionData];
}

#pragma mark - ADJGlobalPartnerParameter
- (void)ccAddGlobalPartnerParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalPartnerParameterActionData{
    [self.globalPartnerParametersController ccAddGlobalPartnerParameterWithClientData:clientAddGlobalPartnerParameterActionData];
}

- (void)ccRemoveGlobalPartnerParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalPartnerParameterActionData {
    [self.globalPartnerParametersController ccRemoveGlobalPartnerParameterWithClientData:clientRemoveGlobalPartnerParameterActionData];
}

- (void)ccClearGlobalPartnerParametersWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalPartnerParametersActionData {
    [self.globalPartnerParametersController ccClearGlobalPartnerParameterWithClientData:clientClearGlobalPartnerParametersActionData];
}

@end
