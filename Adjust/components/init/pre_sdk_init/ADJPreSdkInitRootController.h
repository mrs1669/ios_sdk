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
#import "ADJPublishersRegistry.h"
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

- (nonnull instancetype)initWithInstanceId:(nonnull NSString *)instanceId
                                     clock:(nonnull ADJClock *)clock
                             sdkConfigData:(nonnull ADJSdkConfigData *)sdkConfigData
                             threadFactory:(nonnull ADJThreadController *)threadFactory
                             loggerFactory:(nonnull ADJLogController *)loggerFactory
                            clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
                      clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
                        publishersRegistry:(nonnull ADJPublishersRegistry *)pubRegistry;


- (void)
    setDependenciesWithPackageBuilder:(ADJSdkPackageBuilder *)sdkPackageBuilder
    clock:(ADJClock *)clock
    loggerFactory:(id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    sdkPackageSenderFactory:(id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory;

- (void)subscribeToPublishers:(nonnull ADJPublishersRegistry *)pubRegistry;

@end
