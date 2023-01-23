//
//  ADJPreSdkInitRootController.m
//  AdjustV5
//
//  Created by Pedro S. on 24.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJPreSdkInitRootController.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
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
*/

@implementation ADJPreSdkInitRootController
#pragma mark Instantiation

- (nonnull instancetype)
    initWithInstanceId:(nonnull ADJInstanceIdData *)instanceId
    clock:(nonnull ADJClock *)clock
    sdkConfigData:(nonnull ADJSdkConfigData *)sdkConfigData
    threadController:(nonnull ADJThreadController *)threadController
    loggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
    publisherController:(nonnull ADJPublisherController *)publisherController
{
    self = [super initWithLoggerFactory:loggerFactory source:@"PreSdkInitRootController"];
    
    _storageRootController = [[ADJStorageRootController alloc]
                              initWithLoggerFactory:loggerFactory
                              threadExecutorFactory:threadController
                              instanceId:instanceId];

    _gdprForgetController = [[ADJGdprForgetController alloc]
                             initWithLoggerFactory:loggerFactory
                             gdprForgetStateStorage:_storageRootController.gdprForgetStateStorage
                             threadExecutorFactory:threadController
                             gdprForgetBackoffStrategy:sdkConfigData.gdprForgetBackoffStrategy
                             publisherController:publisherController];

    _lifecycleController = [[ADJLifecycleController alloc]
                            initWithLoggerFactory:loggerFactory
                            threadController:threadController
                            doNotReadCurrentLifecycleStatus:
                                sdkConfigData.doNotReadCurrentLifecycleStatus
                            publisherController:publisherController];

    _offlineController = [[ADJOfflineController alloc] initWithLoggerFactory:loggerFactory
                                                          publisherController:publisherController];

    _clientActionController = [[ADJClientActionController alloc]
                               initWithLoggerFactory:loggerFactory
                               clientActionStorage:_storageRootController.clientActionStorage
                               clock:clock];

    _deviceController = [[ADJDeviceController alloc]
                         initWithLoggerFactory:loggerFactory
                         threadExecutorFactory:threadController
                         clock:clock
                         deviceIdsStorage:_storageRootController.deviceIdsStorage
                         keychainStorage:_storageRootController.keychainStorage
                         deviceIdsConfigData:sdkConfigData.sessionDeviceIdsConfigData];

    _clientReturnExecutor =
        (sdkConfigData.clientReturnExecutorOverwrite) ? : threadController;

    _clientCallbacksController = [[ADJClientCallbacksController alloc]
                                  initWithLoggerFactory:loggerFactory];

    _pluginController = [[ADJPluginController alloc] initWithLoggerFactory:loggerFactory];

    _sdkActiveController = [[ADJSdkActiveController alloc]
                            initWithLoggerFactory:loggerFactory
                            activeStateStorage:_storageRootController.sdkActiveStateStorage
                            clientExecutor:clientExecutor
                            isForgotten:[_gdprForgetController isForgotten]
                            publisherController:publisherController];
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
