//
//  ADJPreSdkInitRoot.m
//  AdjustV5
//
//  Created by Pedro S. on 24.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJPreSdkInitRoot.h"

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
- (nonnull instancetype)initWithInstanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag {
    
    self = [super initWithLoggerFactory:instanceRootBag.logController source:@"PreSdkInitRoot"];

    ADJSdkConfigData *_Nonnull sdkConfig = instanceRootBag.sdkConfigData;
    id<ADJLoggerFactory> _Nonnull loggerFactory = instanceRootBag.logController;

    // without local dependencies
    _clientCallbacksController =
        [[ADJClientCallbacksController alloc] initWithLoggerFactory:loggerFactory];

    _clientReturnExecutor =
        (sdkConfig.clientReturnExecutorOverwrite) ? : instanceRootBag.threadController;

    _lifecycleController = [[ADJLifecycleController alloc]
                            initWithLoggerFactory:loggerFactory
                            threadController:instanceRootBag.threadController
                            doNotReadCurrentLifecycleStatus:
                                sdkConfig.doNotReadCurrentLifecycleStatus
                            clientExecutor:instanceRootBag.clientExecutor
                            publisherController:instanceRootBag.publisherController];

    _offlineController = [[ADJOfflineController alloc]
                          initWithLoggerFactory:loggerFactory
                          publisherController:instanceRootBag.publisherController];


    _pluginController = [[ADJPluginController alloc]
                         initWithLoggerFactory:loggerFactory];

    _storageRoot = [[ADJStorageRoot alloc]
                              initWithLoggerFactory:loggerFactory
                              threadExecutorFactory:instanceRootBag.threadController
                              instanceId:instanceRootBag.instanceId];

    // local dependencies 1
    _clientActionController = [[ADJClientActionController alloc]
                               initWithLoggerFactory:loggerFactory
                               clientActionStorage:_storageRoot.clientActionStorage
                               clock:instanceRootBag.clock];

    _deviceController = [[ADJDeviceController alloc]
                         initWithLoggerFactory:loggerFactory
                         threadExecutorFactory:instanceRootBag.threadController
                         clock:instanceRootBag.clock
                         deviceIdsStorage:_storageRoot.deviceIdsStorage
                         keychainStorage:_storageRoot.keychainStorage
                         deviceIdsConfigData:sdkConfig.sessionDeviceIdsConfigData];

    _gdprForgetController = [[ADJGdprForgetController alloc]
                             initWithLoggerFactory:loggerFactory
                             gdprForgetStateStorage:_storageRoot.gdprForgetStateStorage
                             threadExecutorFactory:instanceRootBag.threadController
                             gdprForgetBackoffStrategy:sdkConfig.gdprForgetBackoffStrategy
                             publisherController:instanceRootBag.publisherController];

    _sdkActiveController = [[ADJSdkActiveController alloc]
                            initWithLoggerFactory:loggerFactory
                            activeStateStorage:_storageRoot.sdkActiveStateStorage
                            clientExecutor:instanceRootBag.clientExecutor
                            isForgotten:[_gdprForgetController isForgotten]
                            publisherController:instanceRootBag.publisherController];
    return self;
}

#pragma mark Public API
- (void)ccSetDependenciesAtSdkInitWithInstanceRootBag:(id<ADJInstanceRootBag>)instanceRootBag
                                   postSdkInitRootBag:(id<ADJPostSdkInitRootBag>)postSdkInitRootBag
                            clientActionsPostSdkStart:(nonnull id<ADJClientActionsAPIPostSdkStart>)clientActionsPostSdkStart {
    [self.gdprForgetController
         ccSetDependenciesAtSdkInitWithSdkPackageBuilder:postSdkInitRootBag.sdkPackageBuilder
         clock:instanceRootBag.clock
         loggerFactory:instanceRootBag.logController
         threadExecutorFactory:instanceRootBag.threadController
         sdkPackageSenderFactory:postSdkInitRootBag.sdkPackageSenderController];
    
    [self.clientActionController ccSetDependencyClientActionsPostSdkStart:clientActionsPostSdkStart];
}

- (void)ccSubscribeToPublishers:(ADJPublisherController *)publisherController {
    [publisherController subscribeToPublisher:self.lifecycleController];
    [publisherController subscribeToPublisher:self.offlineController];
    [publisherController subscribeToPublisher:self.clientActionController];
    [publisherController subscribeToPublisher:self.deviceController];
    [publisherController subscribeToPublisher:self.gdprForgetController];
    [publisherController subscribeToPublisher:self.pluginController];
    [publisherController subscribeToPublisher:self.sdkActiveController];
}

- (void)finalizeAtTeardownWithBlock:(nullable void (^)(void))closeStorageBlock {
    [self.storageRoot finalizeAtTeardownWithCloseStorageBlock:closeStorageBlock];
    [self.lifecycleController finalizeAtTeardown];
}

@end
