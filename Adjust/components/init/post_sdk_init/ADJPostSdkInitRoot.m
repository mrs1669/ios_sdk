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
 @property (nonnull, readonly, strong, nonatomic) ADJClientConfigData *clientConfig;
 @property (nonnull, readonly, strong, nonatomic)
     ADJClientSubscriptionsController *clientSubscriptionsController;
 @property (nonnull, readonly, strong, nonatomic) ADJPausingController *pausingController;
 @property (nonnull, readonly, strong, nonatomic) ADJLogQueueController *logQueueController;
 @property (nonnull, readonly, strong, nonatomic) ADJAttributionController *attributionController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJAsaAttributionController *asaAttributionController;
 @property (nonnull, readonly, strong, nonatomic) ADJPostSdkStartRoot *postSdkStartRoot;
 @property (nonnull, readonly, strong, nonatomic) ADJReachabilityController *reachabilityController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJMeasurementSessionController *measurementSessionController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJMeasurementLifecycleController *measurementLifecycleController;
 */

@interface ADJPostSdkInitRoot ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSubscribingGatePublisher *subscribingGatePublisher;
@property (nonnull, readonly, strong, nonatomic) ADJPublishingGatePublisher *publishingGatePublisher;
@property (nonnull, readonly, strong, nonatomic) ADJSdkInitPublisher *sdkInitPublisher;
@end

@implementation ADJPostSdkInitRoot
#pragma mark - Synthesize protocol properties
@synthesize sdkPackageBuilder = _sdkPackageBuilder;
@synthesize sdkPackageSenderController = _sdkPackageSenderController;
@synthesize mainQueueController = _mainQueueController;

#pragma mark Instantiation
- (nonnull instancetype)
    initWithClientConfig:(nonnull ADJClientConfigData *)clientConfig
    instanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag
    preSdkInitRootBag:(nonnull id<ADJPreSdkInitRootBag>)preSdkInitRootBag
{
    self = [super initWithLoggerFactory:instanceRootBag.logController
                             loggerName:@"PostSdkInitRoot"];
    _clientConfig = clientConfig;

    _subscribingGatePublisher = [[ADJSubscribingGatePublisher alloc]
                                 initWithSubscriberProtocol:@protocol(ADJSubscribingGateSubscriber)
                                 controller:instanceRootBag.publisherController];

    _publishingGatePublisher = [[ADJPublishingGatePublisher alloc]
                                initWithSubscriberProtocol:@protocol(ADJPublishingGateSubscriber)
                                controller:instanceRootBag.publisherController];

    _sdkInitPublisher = [[ADJSdkInitPublisher alloc]
                         initWithSubscriberProtocol:@protocol(ADJSdkInitSubscriber)
                         controller:instanceRootBag.publisherController];

    ADJStorageRoot *_Nonnull storageRoot = preSdkInitRootBag.storageRoot;
    ADJSdkConfigData *_Nonnull sdkConfig = instanceRootBag.sdkConfigData;
    id<ADJLoggerFactory> _Nonnull loggerFactory = instanceRootBag.logController;

    // [INDEPENDENT] Independent objects initialization section.
    _clientSubscriptionsController =
        [[ADJClientSubscriptionsController alloc]
         initWithLoggerFactory:loggerFactory
         threadController:instanceRootBag.threadController
         attributionStateStorage:storageRoot.attributionStateStorage
         clientReturnExecutor:preSdkInitRootBag.clientReturnExecutor
         adjustAttributionSubscriber:clientConfig.adjustAttributionSubscriber
         adjustLogSubscriber:clientConfig.adjustLogSubscriber
         doNotOpenDeferredDeeplink:clientConfig.doNotOpenDeferredDeeplink];

    _pausingController = [[ADJPausingController alloc]
                          initWithLoggerFactory:loggerFactory
                          threadExecutorFactory:instanceRootBag.threadController
                          canSendInBackground:clientConfig.canSendInBackground
                          publisherController:instanceRootBag.publisherController];

    _sdkPackageBuilder =
        [[ADJSdkPackageBuilder alloc]
         initWithLoggerFactory:loggerFactory
         clock:instanceRootBag.clock
         sdkPrefix:instanceRootBag.sdkPrefix
         clientConfigData:clientConfig
         deviceController:preSdkInitRootBag.deviceController
         globalCallbackParametersStorage:storageRoot.globalCallbackParametersStorage
         globalPartnerParametersStorage:storageRoot.globalPartnerParametersStorage
         eventStateStorage:preSdkInitRootBag.storageRoot.eventStateStorage
         measurementSessionStateStorage:storageRoot.measurementSessionStateStorage
         publisherController:instanceRootBag.publisherController];

    _sdkPackageSenderController =
        [[ADJSdkPackageSenderController alloc]
         initWithLoggerFactory:loggerFactory
         networkEndpointData:sdkConfig.networkEndpointData
         urlStrategyBaseDomain:clientConfig.urlStrategyBaseDomain
         dataResidency:clientConfig.dataResidency
         clientCustomEndpointData:clientConfig.clientCustomEndpointData
         publisherController:instanceRootBag.publisherController];

    // [DEPENDENT-1] The following objects initialization is dependent on [INDEPENDENT] section objects.
    // IMPORTANT: DON'T CHANGE THE INITIALIZATION ORDER.
    _logQueueController = [[ADJLogQueueController alloc]
                           initWithLoggerFactory:loggerFactory
                           storage:storageRoot.logQueueStorage
                           threadController:instanceRootBag.threadController
                           clock:instanceRootBag.clock
                           backoffStrategy:sdkConfig.mainQueueBackoffStrategy
                           sdkPackageSenderFactory:_sdkPackageSenderController];

    _mainQueueController =
        [[ADJMainQueueController alloc]
         initWithLoggerFactory:loggerFactory
         mainQueueStorage:storageRoot.mainQueueStorage
         threadController:instanceRootBag.threadController
         clock:instanceRootBag.clock
         backoffStrategy:sdkConfig.mainQueueBackoffStrategy
         sdkPackageSenderFactory:_sdkPackageSenderController];

    // [DEPENDENT-2] The following objects initialization is dependent on [DEPENDENT-1] section objects.
    // IMPORTANT: DON'T CHANGE THE INITIALIZATION ORDER.
    _attributionController =
        [ADJAttributionController
         instanceWithLoggerFactory:loggerFactory
         attributionStateStorage:storageRoot.attributionStateStorage
         clock:instanceRootBag.clock
         sdkPackageBuilder:_sdkPackageBuilder
         threadController:instanceRootBag.threadController
         attributionBackoffStrategy:sdkConfig.attributionBackoffStrategy
         sdkPackageSenderFactory:_sdkPackageSenderController
         mainQueueTrackedPackages:_mainQueueController.trackedPackages
         doNotInitiateAttributionFromSdk:sdkConfig.doNotInitiateAttributionFromSdk
         publisherController:instanceRootBag.publisherController];

    _asaAttributionController =
        [[ADJAsaAttributionController alloc]
            initWithLoggerFactory:loggerFactory
            threadExecutorFactory:instanceRootBag.threadController
            sdkPackageBuilder:_sdkPackageBuilder
            asaAttributionStateStorage:storageRoot.asaAttributionStateStorage
            clock:instanceRootBag.clock
            clientConfigData:clientConfig
            asaAttributionConfig:sdkConfig.asaAttributionConfigData
            logQueueController:_logQueueController
            mainQueueController:_mainQueueController
            adjustAttributionStateStorage:storageRoot.attributionStateStorage];

    _postSdkStartRoot =
        [[ADJPostSdkStartRoot alloc] initWithClientConfigData:clientConfig
                                              instanceRootBag:instanceRootBag
                                            preSdkInitRootBag:preSdkInitRootBag
                                            sdkPackageBuilder:_sdkPackageBuilder
                                          mainQueueController:_mainQueueController];

    _reachabilityController = [[ADJReachabilityController alloc]
                               initWithLoggerFactory:loggerFactory
                               threadController:instanceRootBag.threadController
                               targetEndpoint:[_mainQueueController defaultTargetUrl]
                               publisherController:instanceRootBag.publisherController];

    // [DEPENDENT-3] The following objects initialization is dependent on [DEPENDENT-3] section objects.
    // IMPORTANT: DON'T CHANGE THE INITIALIZATION ORDER.
    _measurementSessionController =
        [[ADJMeasurementSessionController alloc]
         initWithLoggerFactory:loggerFactory
         minMeasurementSessionInterval:sdkConfig.minMeasurementSessionIntervalMilli
         overwriteFirstMeasurementSessionInterval:
             sdkConfig.overwriteFirstMeasurementSessionIntervalMilli
         clientExecutor:instanceRootBag.clientExecutor
         sdkPackageBuilder:_sdkPackageBuilder
         measurementSessionStateStorage:storageRoot.measurementSessionStateStorage
         mainQueueController:_mainQueueController
         clock:instanceRootBag.clock
         clientActionController:preSdkInitRootBag.clientActionController
         postSdkStart:_postSdkStartRoot];

    // [DEPENDENT-4] The following objects initialization is dependent on [DEPENDENT-3] section objects.
    // IMPORTANT: DON'T CHANGE THE INITIALIZATION ORDER.
    _measurementLifecycleController =
        [[ADJMeasurementLifecycleController alloc]
         initWithLoggerFactory:loggerFactory
         clientExecutor:instanceRootBag.clientExecutor
         measurementSessionController:_measurementSessionController
         threadExecutorFactory:instanceRootBag.threadController
         resumedSessionTimerStart:sdkConfig.foregroundTimerStartMilli
         resumedSessionTimerInterval:sdkConfig.foregroundTimerIntervalMilli
         publisherController:instanceRootBag.publisherController];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API

- (void)ccCompletePostSdkInit {
    // announce that all can receive events
    [self.subscribingGatePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJSubscribingGateSubscriber> _Nonnull subscriber) {
        [subscriber ccAllowedToReceiveNotifications];
    }];

    // announce that all can publish events
    [self.publishingGatePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJPublishingGateSubscriber> _Nonnull subscriber) {
        [subscriber ccAllowedToPublishNotifications];
    }];

    // announce sdk init
    [self.sdkInitPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJSdkInitSubscriber> _Nonnull subscriber) {
        [subscriber ccOnSdkInitWithClientConfigData:self.clientConfig];
    }];

    // call post sdk init
    //  to ensure that if the sdk were to start from that
    //  it would happen only *after* all sdk init subscribers received their notification
    [self.measurementLifecycleController ccPostSdkInit];
}

- (void)finalizeAtTeardownWithBlock:(nullable void (^)(void))closeStorageBlock {
    [self.reachabilityController finalizeAtTeardown];
}

- (void)ccSubscribeToPublishers:(nonnull ADJPublisherController *)publisherController {
    // subscribe controllers to publishers
    [publisherController subscribeToPublisher:self.attributionController];
    [publisherController subscribeToPublisher:self.clientSubscriptionsController];
    [publisherController subscribeToPublisher:self.asaAttributionController];
    [publisherController subscribeToPublisher:self.logQueueController];
    [publisherController subscribeToPublisher:self.mainQueueController];
    [publisherController subscribeToPublisher:self.pausingController];
    [publisherController subscribeToPublisher:self.reachabilityController];
    [publisherController subscribeToPublisher:self.measurementSessionController];
    [publisherController subscribeToPublisher:self.measurementLifecycleController];
}

@end
