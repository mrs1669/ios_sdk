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

#import "ADJInstanceRootBag.h"
#import "ADJPreSdkInitRoot.h"

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
#import "ADJMeasurementLifecycleController.h"

@interface ADJPostSdkInitRoot : ADJCommonBase
// instantiation
+ (nonnull instancetype)
    ccInstanceWhenSdkInitWithClientConfig:(nonnull ADJClientConfigData *)clientConfig
    instanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag
    preSdkInitRoot:(nonnull ADJPreSdkInitRoot *)preSdkInitRoot;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJClientConfigData *clientConfig;
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
@property (nonnull, readonly, strong, nonatomic) ADJPostSdkStartRoot *postSdkStartRoot;
@property (nonnull, readonly, strong, nonatomic) ADJReachabilityController *reachabilityController;
@property (nonnull, readonly, strong, nonatomic)
    ADJMeasurementSessionController *measurementSessionController;
@property (nonnull, readonly, strong, nonatomic)
    ADJMeasurementLifecycleController *measurementLifecycleController;

// public api
- (void)finalizeAtTeardownWithBlock:(nullable void (^)(void))closeStorageBlock;

@end
