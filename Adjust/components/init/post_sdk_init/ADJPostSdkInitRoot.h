//
//  ADJPostSdkInitRoot.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJClientActionsAPI.h"
#import "ADJMeasurementSessionStartSubscriber.h"

#import "ADJThreadController.h"
#import "ADJSingleThreadExecutor.h"
#import "ADJClientReturnExecutor.h"
#import "ADJStorageRoot.h"
#import "ADJDeviceController.h"
#import "ADJClientConfigData.h"
#import "ADJSdkConfigData.h"
#import "ADJClock.h"
#import "ADJPublisherController.h"

#import "ADJClientSubscriptionsController.h"
#import "ADJPausingController.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJSdkPackageSenderController.h"
#import "ADJLogQueueController.h"
#import "ADJMainQueueController.h"
#import "ADJAttributionController.h"
#import "ADJAsaAttributionController.h"
#import "ADJMeasurementSessionController.h"
#import "ADJPostSdkStartRoot.h"
#import "ADJReachabilityController.h"


@interface ADJPostSdkInitRoot : ADJCommonBase<
    // subscriptions
    ADJMeasurementSessionStartSubscriber
>

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
    publisherController:(nonnull ADJPublisherController *)publisherController;

- (void)subscribeToPublishers:(nonnull ADJPublisherController *)publisherController;
- (void)startSdk;

- (nullable id<ADJClientActionsAPI>)sdkStartClientActionAPI;

// public properties
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

@end
