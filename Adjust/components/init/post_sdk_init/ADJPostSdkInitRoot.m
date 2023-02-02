//
//  ADJPostSdkInitRoot.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//
#import "ADJPostSdkInitRoot.h"

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
 @property (nonnull, readonly, strong, nonatomic) ADJClientConfigData *clientConfigData;
 @property (nonnull, readonly, strong, nonatomic)
     ADJClientSubscriptionsController *clientSubscriptionsController;
 @property (nonnull, readonly, strong, nonatomic) ADJPausingController *pausingController;
 @property (nonnull, readonly, strong, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilder;
 @property (nonnull, readonly, strong, nonatomic)
     ADJSdkPackageSenderController *sdkPackageSenderController;
 @property (nonnull, readonly, strong, nonatomic) ADJLogQueueController *logQueueController;
 @property (nonnull, readonly, strong, nonatomic) ADJMainQueueController *mainQueueController;
 @property (nonnull, readonly, strong, nonatomic) ADJAttributionController *attributionController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJAsaAttributionController *asaAttributionController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJMeasurementSessionController *measurementSessionController;
 @property (nonnull, readonly, strong, nonatomic) ADJPostSdkStartRoot *postSdkStartRoot;
 @property (nonnull, readonly, strong, nonatomic) ADJReachabilityController *reachabilityController;
 */

@interface ADJPostSdkInitRoot ()

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL hasMeasurementSessionStart;
@property (nonnull, readonly, strong, nonatomic)
    ADJSubscribingGatePublisher *subscribingGatePublisher;
@property (nonnull, readonly, strong, nonatomic)
    ADJPublishingGatePublisher *publishingGatePublisher;
@property (nonnull, readonly, strong, nonatomic) ADJSdkInitPublisher *sdkInitPublisher;
@property (nonnull, readonly, strong, nonatomic) ADJKeepAliveController *keepAliveController;

@end

@implementation ADJPostSdkInitRoot
#pragma mark Instantiation
- (nonnull instancetype)
    initWithClientConfig:(nonnull ADJClientConfigData *)clientConfig
    instanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag
    preSdkInitRootBag:(nonnull id<ADJPreSdkInitRootBag>)preSdkInitRootBag
{
    self = [super initWithLoggerFactory:instanceRootBag.logController source:@"PostSdkInitRoot"];
    _clientConfig = clientConfig;

    _hasMeasurementSessionStart = NO;

    _subscribingGatePublisher = [[ADJSubscribingGatePublisher alloc]
                                 initWithSubscriberProtocol:@protocol(ADJSubscribingGateSubscriber)
                                 controller:instanceRootBag.publisherController];

    _publishingGatePublisher = [[ADJPublishingGatePublisher alloc]
                                initWithSubscriberProtocol:@protocol(ADJPublishingGateSubscriber)
                                controller:instanceRootBag.publisherController];

    _sdkInitPublisher = [[ADJSdkInitPublisher alloc]
                         initWithSubscriberProtocol:@protocol(ADJSdkInitSubscriber)
                         controller:instanceRootBag.publisherController];

    // without local dependencies
    _clientSubscriptionsController =
        [[ADJClientSubscriptionsController alloc]
         initWithLoggerFactory:instanceRootBag.logController
         threadController:instanceRootBag.threadController
         clientReturnExecutor:preSdkInitRootBag.clientReturnExecutor
         adjustAttributionSubscriber:clientConfig.adjustAttributionSubscriber
         adjustLogSubscriber:clientConfig.adjustLogSubscriber
         doNotOpenDeferredDeeplink:clientConfig.doNotOpenDeferredDeeplink];

    _keepAliveController = [[ADJKeepAliveController alloc]
                            initWithLoggerFactory:instanceRootBag.logController
                            threadExecutorFactory:instanceRootBag.threadController
                            foregroundTimerStartMilli:
                                instanceRootBag.sdkConfigData.foregroundTimerStartMilli
                            foregroundTimerIntervalMilli:
                                instanceRootBag.sdkConfigData.foregroundTimerIntervalMilli
                            publisherController:instanceRootBag.publisherController];

    _pausingController = [[ADJPausingController alloc]
                          initWithLoggerFactory:instanceRootBag.logController
                          threadExecutorFactory:instanceRootBag.threadController
                          canSendInBackground:clientConfig.canSendInBackground
                          publisherController:instanceRootBag.publisherController];

    _sdkPackageBuilder =
        [[ADJSdkPackageBuilder alloc]
         initWithLoggerFactory:instanceRootBag.logController
         clock:instanceRootBag.clock
         sdkPrefix:instanceRootBag.sdkPrefix
         clientConfigData:clientConfig
         deviceController:preSdkInitRootBag.deviceController
         globalCallbackParametersStorage:
             preSdkInitRootBag.storageRoot.globalCallbackParametersStorage
         globalPartnerParametersStorage:
             preSdkInitRootBag.storageRoot.globalPartnerParametersStorage
         eventStateStorage:preSdkInitRootBag.storageRoot.eventStateStorage
         measurementSessionStateStorage:
             preSdkInitRootBag.storageRoot.measurementSessionStateStorage
         publisherController:instanceRootBag.publisherController];

    _sdkPackageSenderController =
        [[ADJSdkPackageSenderController alloc]
         initWithLoggerFactory:instanceRootBag.logController
         networkEndpointData:instanceRootBag.sdkConfigData.networkEndpointData
         adjustUrlStrategy:clientConfig.urlStrategy
         clientCustomEndpointData:clientConfig.clientCustomEndpointData
         publisherController:instanceRootBag.publisherController];

    // local dependencies 1
    _logQueueController = [[ADJLogQueueController alloc]
                           initWithLoggerFactory:instanceRootBag.logController
                           storage:preSdkInitRootBag.storageRoot.logQueueStorage
                           threadController:instanceRootBag.threadController
                           clock:instanceRootBag.clock
                           backoffStrategy:instanceRootBag.sdkConfigData.mainQueueBackoffStrategy
                           sdkPackageSenderFactory:_sdkPackageSenderController];

    _mainQueueController =
        [[ADJMainQueueController alloc]
         initWithLoggerFactory:instanceRootBag.logController
         mainQueueStorage:preSdkInitRootBag.storageRoot.mainQueueStorage
         threadController:instanceRootBag.threadController
         clock:instanceRootBag.clock
         backoffStrategy:instanceRootBag.sdkConfigData.mainQueueBackoffStrategy
         sdkPackageSenderFactory:_sdkPackageSenderController];

    // local dependencies 2
    _attributionController =
        [[ADJAttributionController alloc]
         initWithLoggerFactory:instanceRootBag.logController
         attributionStateStorage:preSdkInitRootBag.storageRoot.attributionStateStorage
         clock:instanceRootBag.clock
         sdkPackageBuilder:_sdkPackageBuilder
         threadController:instanceRootBag.threadController
         attributionBackoffStrategy:instanceRootBag.sdkConfigData.attributionBackoffStrategy
         sdkPackageSenderFactory:_sdkPackageSenderController
         mainQueueTrackedPackagesProvider:[_mainQueueController trackedPackagesProvider]
         doNotInitiateAttributionFromSdk:
             instanceRootBag.sdkConfigData.doNotInitiateAttributionFromSdk
         publisherController:instanceRootBag.publisherController];

    _asaAttributionController =
        [[ADJAsaAttributionController alloc]
            initWithLoggerFactory:instanceRootBag.logController
            threadExecutorFactory:instanceRootBag.threadController
            sdkPackageBuilder:_sdkPackageBuilder
            asaAttributionStateStorage:preSdkInitRootBag.storageRoot.asaAttributionStateStorage
            clock:instanceRootBag.clock
            clientConfigData:clientConfig
            asaAttributionConfig:instanceRootBag.sdkConfigData.asaAttributionConfigData
            logQueueController:_logQueueController
            mainQueueController:_mainQueueController
            adjustAttributionStateStorage:preSdkInitRootBag.storageRoot.attributionStateStorage];

    _measurementSessionController =
        [[ADJMeasurementSessionController alloc]
         initWithLoggerFactory:instanceRootBag.logController
         minMeasurementSessionIntervalMilli:
             instanceRootBag.sdkConfigData.minMeasurementSessionIntervalMilli
         overwriteFirstMeasurementSessionIntervalMilli:
             instanceRootBag.sdkConfigData.overwriteFirstMeasurementSessionIntervalMilli
         clientExecutor:instanceRootBag.clientExecutor
         sdkPackageBuilder:_sdkPackageBuilder
         measurementSessionStateStorage:preSdkInitRootBag.storageRoot.measurementSessionStateStorage
         mainQueueController:_mainQueueController
         clock:instanceRootBag.clock
         publisherController:instanceRootBag.publisherController];

    _postSdkStartRoot = [[ADJPostSdkStartRoot alloc]
                         initWithClientConfigData:clientConfig
                         loggerFactory:instanceRootBag.logController
                         storageRoot:preSdkInitRootBag.storageRoot
                         sdkPackageBuilder:_sdkPackageBuilder
                         mainQueueController:_mainQueueController];

    _reachabilityController = [[ADJReachabilityController alloc]
                               initWithLoggerFactory:instanceRootBag.logController
                               threadController:instanceRootBag.threadController
                               targetEndpoint:[_mainQueueController defaultTargetUrl]
                               publisherController:publisherController];

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
        [subscriber ccOnSdkInitWithClientConfigData:self.clientConfig];
    }];
}

- (nullable id<ADJClientActionsAPI>)sdkStartClientActionAPI {
    if (self.hasMeasurementSessionStart) {
        return self.postSdkStartRoot;
    } else {
        return nil;
    }
}

#pragma mark - ADJMeasurementSessionStartPublisher
- (void)ccMeasurementSessionStartWithStatus:(nonnull NSString *)measurementSessionStartStatus {
    self.hasMeasurementSessionStart = YES;
}

@end
