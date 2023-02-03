//
//  ADJPreSdkInitRoot.m
//  AdjustV5
//
//  Created by Pedro S. on 24.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJPreSdkInitRoot.h"

#import "ADJPostSdkInitRoot.h"

#pragma mark Fields
@interface ADJPreSdkInitRoot ()
#pragma mark - Internal variables
@property (nullable, readwrite, strong, nonatomic) ADJPostSdkInitRoot *postSdkInitRoot;

@end

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
- (void)ccSdkInitWithClientConfg:(nonnull ADJClientConfigData *)clientConfig
                 instanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag
{
    self.postSdkInitRoot = [ADJPostSdkInitRoot
                            ccInstanceWhenSdkInitWithClientConfig:clientConfig
                            instanceRootBag:instanceRootBag
                            preSdkInitRoot:self];
}

- (void)
    ccSetDependenciesAtSdkInitWithInstanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder*)sdkPackageBuilder
    sdkPackageSenderController:(nonnull ADJSdkPackageSenderController *)sdkPackageSenderController
{
    [self.gdprForgetController
         ccSetDependenciesAtSdkInitWithSdkPackageBuilder:sdkPackageBuilder
         clock:instanceRootBag.clock
         loggerFactory:instanceRootBag.logController
         threadExecutorFactory:instanceRootBag.threadController
         sdkPackageSenderFactory:sdkPackageSenderController];
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

    if (self.postSdkInitRoot != nil) {
        [self.postSdkInitRoot finalizeAtTeardownWithBlock:closeStorageBlock];
    }
}

@end
