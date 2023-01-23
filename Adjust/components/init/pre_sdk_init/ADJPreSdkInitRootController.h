//
//  ADJPreSdkInitRootController.h
//  AdjustV5
//
//  Created by Pedro S. on 24.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJClock.h"
#import "ADJStorageRootController.h"
#import "ADJGdprForgetController.h"
#import "ADJLifecycleController.h"
#import "ADJOfflineController.h"
#import "ADJClientActionController.h"
#import "ADJDeviceController.h"
#import "ADJClientCallbacksController.h"
#import "ADJPluginController.h"
#import "ADJSdkConfigData.h"
#import "ADJPublisherController.h"
#import "ADJThreadController.h"
#import "ADJLogController.h"
#import "ADJSdkActiveController.h"

@interface ADJPreSdkInitRootController : ADJCommonBase
@property (nonnull, readonly, strong, nonatomic) ADJSdkActiveController *sdkActiveController;
@property (nonnull, readonly, strong, nonatomic) ADJStorageRootController *storageRootController;
@property (nonnull, readonly, strong, nonatomic) ADJDeviceController *deviceController;
@property (nonnull, readonly, strong, nonatomic) ADJClientActionController *clientActionController;
@property (nonnull, readonly, strong, nonatomic) ADJGdprForgetController *gdprForgetController;
@property (nonnull, readonly, strong, nonatomic) ADJLifecycleController *lifecycleController;
@property (nonnull, readonly, strong, nonatomic) ADJOfflineController *offlineController;
@property (nonnull, readonly, strong, nonatomic) ADJClientCallbacksController *clientCallbacksController;
@property (nonnull, readonly, strong, nonatomic) ADJPluginController *pluginController;
@property (nonnull, readonly, strong, nonatomic) id<ADJClientReturnExecutor> clientReturnExecutor;

- (nonnull instancetype)
    initWithInstanceId:(nonnull ADJInstanceIdData *)instanceId
    clock:(nonnull ADJClock *)clock
    sdkConfigData:(nonnull ADJSdkConfigData *)sdkConfigData
    threadController:(nonnull ADJThreadController *)threadController
    loggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
    publisherController:(nonnull ADJPublisherController *)publisherController;

- (void)
    setDependenciesWithPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    clock:(nonnull ADJClock *)clock
    loggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory;

- (void)subscribeToPublishers:(nonnull ADJPublisherController *)publisherController;

@end
