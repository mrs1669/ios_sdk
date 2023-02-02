//
//  ADJPreSdkInitRoot.m
//  AdjustV5
//
//  Created by Pedro S. on 24.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJPreSdkInitRoot.h"

#pragma mark Fields
@implementation ADJPreSdkInitRoot
#pragma mark - Synthesize protocol properties
@synthesize sdkActiveController = _sdkActiveController;
@synthesize storageRoot = _storageRoot;
@synthesize deviceController = _deviceController;
@synthesize clientActionController = _clientActionController;
@synthesize gdprForgetController = _gdprForgetController;
@synthesize lifecycleController = _lifecycleController;
@synthesize offlineController = _offlineController;
@synthesize clientCallbacksController = _clientCallbacksController;
@synthesize pluginController = _pluginController;
@synthesize clientReturnExecutor = _clientReturnExecutor;

#pragma mark Instantiation
- (nonnull instancetype)
    initWithInstanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag
{
    self = [super initWithLoggerFactory:instanceRootBag.logController source:@"PreSdkInitRoot"];

    // without local dependencies
    _clientCallbacksController = [[ADJClientCallbacksController alloc]
                                  initWithLoggerFactory:instanceRootBag.logController];

    _clientReturnExecutor =
        (instanceRootBag.sdkConfigData.clientReturnExecutorOverwrite)
        ? : instanceRootBag.threadController;

    _gdprForgetController = [[ADJGdprForgetController alloc]
                             initWithLoggerFactory:instanceRootBag.logController
                             gdprForgetStateStorage:_storageRoot.gdprForgetStateStorage
                             threadExecutorFactory:instanceRootBag.threadController
                             gdprForgetBackoffStrategy:
                                 instanceRootBag.sdkConfigData.gdprForgetBackoffStrategy
                             publisherController:instanceRootBag.publisherController];

    _lifecycleController = [[ADJLifecycleController alloc]
                            initWithLoggerFactory:instanceRootBag.logController
                            threadController:instanceRootBag.threadController
                            doNotReadCurrentLifecycleStatus:
                                instanceRootBag.sdkConfigData.doNotReadCurrentLifecycleStatus
                            clientExecutor:instanceRootBag.clientExecutor
                            publisherController:instanceRootBag.publisherController];

    _offlineController = [[ADJOfflineController alloc]
                          initWithLoggerFactory:instanceRootBag.logController
                          publisherController:instanceRootBag.publisherController];


    _pluginController = [[ADJPluginController alloc]
                         initWithLoggerFactory:instanceRootBag.logController];

    _storageRoot = [[ADJStorageRoot alloc]
                              initWithLoggerFactory:instanceRootBag.logController
                              threadExecutorFactory:instanceRootBag.threadController
                              instanceId:instanceRootBag.instanceId];

    // local dependencies 1
    _clientActionController = [[ADJClientActionController alloc]
                               initWithLoggerFactory:instanceRootBag.logController
                               clientActionStorage:_storageRoot.clientActionStorage
                               clock:instanceRootBag.clock];

    _deviceController = [[ADJDeviceController alloc]
                         initWithLoggerFactory:instanceRootBag.logController
                         threadExecutorFactory:instanceRootBag.threadController
                         clock:instanceRootBag.clock
                         deviceIdsStorage:_storageRoot.deviceIdsStorage
                         keychainStorage:_storageRoot.keychainStorage
                         deviceIdsConfigData:
                             instanceRootBag.sdkConfigData.sessionDeviceIdsConfigData];


    _sdkActiveController = [[ADJSdkActiveController alloc]
                            initWithLoggerFactory:instanceRootBag.logController
                            activeStateStorage:_storageRoot.sdkActiveStateStorage
                            clientExecutor:instanceRootBag.clientExecutor
                            isForgotten:[_gdprForgetController isForgotten]
                            publisherController:instanceRootBag.publisherController];
    return self;
}

- (void)
    setDependenciesWithPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    clock:(nonnull ADJClock *)clock
    loggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory
{

    [self.gdprForgetController
         ccSetDependenciesAtSdkInitWithSdkPackageBuilder:sdkPackageBuilder
         clock:clock
         loggerFactory:loggerFactory
         threadExecutorFactory:threadExecutorFactory
         sdkPackageSenderFactory:sdkPackageSenderFactory];
}

- (void)subscribeToPublishers:(ADJPublisherController *)publisherController {
    [publisherController subscribeToPublisher:self.lifecycleController];
    [publisherController subscribeToPublisher:self.offlineController];
    [publisherController subscribeToPublisher:self.clientActionController];
    [publisherController subscribeToPublisher:self.deviceController];
    [publisherController subscribeToPublisher:self.gdprForgetController];
    [publisherController subscribeToPublisher:self.pluginController];
    [publisherController subscribeToPublisher:self.sdkActiveController];
}

@end
