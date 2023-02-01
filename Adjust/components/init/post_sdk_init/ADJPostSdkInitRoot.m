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
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadController:(nonnull ADJThreadController *)threadController
    clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
    clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
    storageRoot:(nonnull ADJStorageRoot *)storageRoot
    deviceController:(nonnull ADJDeviceController *)deviceController
    clientConfigData:(nonnull ADJClientConfigData *)clientConfigData
    sdkConfigData:(nonnull ADJSdkConfigData *)sdkConfigData
    sdkPrefix:(nullable NSString *)sdkPrefix
    clock:(nonnull ADJClock *)clock
    publisherController:(nonnull ADJPublisherController *)publisherController
{
    self = [super initWithLoggerFactory:loggerFactory source:@"PostSdkInitRoot"];
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

    // without local dependencies
    _clientSubscriptionsController =
        [[ADJClientSubscriptionsController alloc]
         initWithLoggerFactory:loggerFactory
         threadController:threadController
         clientReturnExecutor:clientReturnExecutor
         adjustAttributionSubscriber:clientConfigData.adjustAttributionSubscriber
         adjustLogSubscriber:clientConfigData.adjustLogSubscriber
         doNotOpenDeferredDeeplink:clientConfigData.doNotOpenDeferredDeeplink];

    _keepAliveController = [[ADJKeepAliveController alloc]
                            initWithLoggerFactory:loggerFactory
                            threadExecutorFactory:threadController
                            foregroundTimerStartMilli:sdkConfigData.foregroundTimerStartMilli
                            foregroundTimerIntervalMilli:sdkConfigData.foregroundTimerIntervalMilli
                            publisherController:publisherController];

    _pausingController = [[ADJPausingController alloc]
                          initWithLoggerFactory:loggerFactory
                          threadExecutorFactory:threadController
                          canSendInBackground:clientConfigData.canSendInBackground
                          publisherController:publisherController];

    _sdkPackageBuilder =
        [[ADJSdkPackageBuilder alloc]
         initWithLoggerFactory:loggerFactory
         clock:clock
         sdkPrefix:sdkPrefix
         clientConfigData:clientConfigData
         deviceController:deviceController
         globalCallbackParametersStorage:storageRoot.globalCallbackParametersStorage
         globalPartnerParametersStorage:storageRoot.globalPartnerParametersStorage
         eventStateStorage:storageRoot.eventStateStorage
         measurementSessionStateStorage:storageRoot.measurementSessionStateStorage
         publisherController:publisherController];

    _sdkPackageSenderController =
        [[ADJSdkPackageSenderController alloc]
         initWithLoggerFactory:loggerFactory
         networkEndpointData:sdkConfigData.networkEndpointData
         adjustUrlStrategy:clientConfigData.urlStrategy
         clientCustomEndpointData:clientConfigData.clientCustomEndpointData
         publisherController:publisherController];

    // local dependencies 1
    _logQueueController = [[ADJLogQueueController alloc]
                           initWithLoggerFactory:loggerFactory
                           storage:storageRoot.logQueueStorage
                           threadController:threadController
                           clock:clock
                           backoffStrategy:sdkConfigData.mainQueueBackoffStrategy
                           sdkPackageSenderFactory:_sdkPackageSenderController];

    _mainQueueController =
        [[ADJMainQueueController alloc]
         initWithLoggerFactory:loggerFactory
         mainQueueStorage:storageRoot.mainQueueStorage
         threadController:threadController
         clock:clock
         backoffStrategy:sdkConfigData.mainQueueBackoffStrategy
         sdkPackageSenderFactory:_sdkPackageSenderController];

    // local dependencies 2
    _attributionController =
        [[ADJAttributionController alloc]
         initWithLoggerFactory:loggerFactory
         attributionStateStorage:storageRoot.attributionStateStorage
         clock:clock
         sdkPackageBuilder:_sdkPackageBuilder
         threadController:threadController
         attributionBackoffStrategy:sdkConfigData.attributionBackoffStrategy
         sdkPackageSenderFactory:_sdkPackageSenderController
         mainQueueTrackedPackagesProvider:[_mainQueueController trackedPackagesProvider]
         doNotInitiateAttributionFromSdk:sdkConfigData.doNotInitiateAttributionFromSdk
         publisherController:publisherController];

    _asaAttributionController =
        [[ADJAsaAttributionController alloc]
            initWithLoggerFactory:loggerFactory
            threadExecutorFactory:threadController
            sdkPackageBuilder:_sdkPackageBuilder
            asaAttributionStateStorage:storageRoot.asaAttributionStateStorage
            clock:clock
            clientConfigData:clientConfigData
            asaAttributionConfig:sdkConfigData.asaAttributionConfigData
            logQueueController:_logQueueController
            mainQueueController:_mainQueueController
            adjustAttributionStateStorage:storageRoot.attributionStateStorage];

    _measurementSessionController =
        [[ADJMeasurementSessionController alloc]
         initWithLoggerFactory:loggerFactory
         minMeasurementSessionIntervalMilli:sdkConfigData.minMeasurementSessionIntervalMilli
         overwriteFirstMeasurementSessionIntervalMilli:sdkConfigData.overwriteFirstMeasurementSessionIntervalMilli
         clientExecutor:clientExecutor
         sdkPackageBuilder:_sdkPackageBuilder
         measurementSessionStateStorage:storageRoot.measurementSessionStateStorage
         mainQueueController:_mainQueueController
         clock:clock
         publisherController:publisherController];

    _postSdkStartRoot = [[ADJPostSdkStartRoot alloc]
                         initWithClientConfigData:clientConfigData
                         loggerFactory:loggerFactory
                         storageRoot:storageRoot
                         sdkPackageBuilder:_sdkPackageBuilder
                         mainQueueController:_mainQueueController];

    _reachabilityController = [[ADJReachabilityController alloc]
                               initWithLoggerFactory:loggerFactory
                               threadController:threadController
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
        [subscriber ccOnSdkInitWithClientConfigData:self.clientConfigData];
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
