//
//  ADJPostSdkInitRoot.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJInstanceRootBag.h"
#import "ADJPreSdkInitRootBag.h"
#import "ADJPostSdkInitRootBag.h"
#import "ADJAdidController.h"
#import "ADJClientSubscriptionsController.h"
#import "ADJPausingController.h"
#import "ADJLogQueueController.h"
#import "ADJAttributionController.h"
#import "ADJAsaAttributionController.h"
#import "ADJMeasurementSessionController.h"
#import "ADJReachabilityController.h"
#import "ADJMeasurementLifecycleController.h"
#import "ADJPostSdkStartRoot.h"

@interface ADJPostSdkInitRoot : ADJCommonBase <ADJPostSdkInitRootBag>

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJClientConfigData *clientConfig;
@property (nonnull, readonly, strong, nonatomic) ADJAdidController *adidController;
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

// instantiation
- (nonnull instancetype)initWithClientConfig:(nonnull ADJClientConfigData *)clientConfig
                             instanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag
                           preSdkInitRootBag:(nonnull id<ADJPreSdkInitRootBag>)preSdkInitRootBag;

- (nullable instancetype)init NS_UNAVAILABLE;

- (void)ccSubscribeToPublishers:(nonnull ADJPublisherController *)publisherController;

- (void)ccCompletePostSdkInit;

// public api
- (void)finalizeAtTeardownWithBlock:(nullable void (^)(void))closeStorageBlock;

@end
