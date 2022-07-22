//
//  ADJPreSdkInitRootController.m
//  AdjustV5
//
//  Created by Pedro S. on 24.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJPreSdkInitRootController.h"

#import "ADJSdkActiveState.h"
#import "ADJEntryRoot.h"
#import "ADJClientConfigData.h"
#import "ADJValueWO.h"
#import "ADJPostSdkInitRootController.h"

#pragma mark Private class
@implementation ADJSdkActivePublisher @end

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic)
    ADJSdkActiveStatePublisher *sdkActiveStatePublisher;

 @property (nonnull, readonly, strong, nonatomic) ADJClock *clock;
 @property (nonnull, readonly, strong, nonatomic)
    ADJStorageRootController *storageRootController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJGdprForgetController *gdprForgetController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJLifecycleController *lifecycleController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJOfflineController *offlineController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJClientActionController *clientActionController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJDeviceController *deviceController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJClientCallbacksController *clientCallbacksController;
 @property (nonnull, readonly, strong, nonatomic) ADJPluginController *pluginController;
*/

@interface ADJPreSdkInitRootController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJEntryRoot *entryRootWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSdkActiveState *sdkActiveState;

@end

@implementation ADJPreSdkInitRootController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                    entryRoot:(nonnull ADJEntryRoot *)entryRoot
{
    self = [super initWithLoggerFactory:loggerFactory source:@"PreSdkInitRootController"];
    _entryRootWeak = entryRoot;

    _sdkActivePublisher = [[ADJSdkActivePublisher alloc] init];

    _clock = [[ADJClock alloc] init];

    _storageRootController = [[ADJStorageRootController alloc]
                                initWithLoggerFactory:loggerFactory
                                threadExecutorFactory:entryRoot.threadController];

//    _gdprForgetController =
//        [[ADJGdprForgetController alloc]
//            initWithLoggerFactory:loggerFactory
//            gdprForgetStateStorage:self.storageRootController.gdprForgetStateStorage
//            threadExecutorFactory:entryRoot.threadController
//            gdprForgetBackoffStrategy:entryRoot.sdkConfigData.gdprForgetBackoffStrategy];
//
//    _lifecycleController = [[ADJLifecycleController alloc]
//                                initWithLoggerFactory:loggerFactory
//                                threadController:entryRoot.threadController
//                                doNotReadCurrentLifecycleStatus:
//                                    entryRoot.sdkConfigData.doNotReadCurrentLifecycleStatus];
//
//    _offlineController = [[ADJOfflineController alloc] initWithLoggerFactory:loggerFactory];
//
//    _clientActionController = [[ADJClientActionController alloc]
//                                    initWithLoggerFactory:loggerFactory
//                                    clientActionStorage:
//                                        self.storageRootController.clientActionStorage
//                                    clock:self.clock];
//
//    _deviceController = [[ADJDeviceController alloc]
//                            initWithLoggerFactory:loggerFactory
//                                threadPool:entryRoot.threadController
//                                clock:self.clock
//                                deviceIdsStorage:self.storageRootController.deviceIdsStorage
//                                keychainStorage:self.storageRootController.keychainStorage
//                                deviceIdsConfigData:entryRoot.sdkConfigData.sessionDeviceIdsConfigData];
//
//    _clientCallbacksController =
//        [[ADJClientCallbacksController alloc]
//            initWithLoggerFactory:loggerFactory
//            attributionStateStorage:self.storageRootController.attributionStateStorage
//            clientReturnExecutor:[entryRoot clientReturnExecutor]
//            deviceController:self.deviceController];
//
//    _sdkActiveState =
//        [[ADJSdkActiveState alloc]
//            initWithLoggerFactory:loggerFactory
//            isGdprForgotten:[self.gdprForgetController isForgotten]];
//
//    _pluginController = [[ADJPluginController alloc] initWithLoggerFactory:loggerFactory];

    return self;
}

#pragma mark Public API
#pragma mark - ADJClientAPI
- (void)ccSdkInitWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData {
    ADJEntryRoot *_Nullable entryRoot = self.entryRootWeak;

    if (entryRoot == nil) {
        [self.logger error:@"Cannot ccSdkInit without a reference to entry root"];
        return;
    }
/*
    ADJSdkActiveStateStorage *_Nonnull sdkActiveStateStorage =
        self.storageRootController.sdkActiveStateStorage;

    BOOL canSdkInit = [self.sdkActiveState
        sdkInitWithCurrentSdkActiveStateData:[sdkActiveStateStorage readOnlyStoredDataValue]
        adjustApiLogger:entryRoot.adjustApiLogger];

    if (! canSdkInit) {
        return;
    }
*/
    ADJPostSdkInitRootController *_Nonnull postSdkInitRootController =
        [entryRoot ccCreatePostSdkInitRootControllerWithClientConfigData:clientConfigData
                                                preSdkInitRootController:self];

    [postSdkInitRootController ccSdkInitWithEntryRoot:entryRoot
                                                    preSdkInitRootController:self];
}

//- (void)ccInactivateSdk {
//    ADJEntryRoot *_Nullable entryRoot = self.entryRootWeak;
//
//    if (entryRoot == nil) {
//        [self.logger error:@"Cannot ccInactivateSdk without a reference to entry root"];
//        return;
//    }
//
//    ADJSdkActiveStateStorage *_Nonnull sdkActiveStateStorage =
//        self.storageRootController.sdkActiveStateStorage;
//
//    ADJValueWO<ADJSdkActiveStateData *> *_Nonnull changedSdkActiveStateDataWO =
//        [[ADJValueWO alloc] init];
//    ADJValueWO<NSString *> *_Nonnull sdkActiveStatusEventWO = [[ADJValueWO alloc] init];
//
//    [self.sdkActiveState
//        inactivateSdkWithCurrentSdkActiveStateData:
//            [sdkActiveStateStorage readOnlyStoredDataValue]
//        sdkActiveStatusEventWO:sdkActiveStatusEventWO
//        changedSdkActiveStateDataWO:changedSdkActiveStateDataWO
//        adjustApiLogger:entryRoot.adjustApiLogger];
//
//    [self
//        handleStateSideEffectsWithSdkActiveStateStorage:sdkActiveStateStorage
//        changedSdkActiveStateData:changedSdkActiveStateDataWO.changedValue
//        sdkActiveStatusEvent:sdkActiveStatusEventWO.changedValue
//        source:@"ccInactivateSdk"];
//}
//
//- (void)ccReactivateSdk {
//    ADJEntryRoot *_Nullable entryRoot = self.entryRootWeak;
//    if (entryRoot == nil) {
//        [self.logger error:@"Cannot ccReactivateSdk without a reference to entry root"];
//        return;
//    }
//
//    ADJSdkActiveStateStorage *_Nonnull sdkActiveStateStorage =
//        self.storageRootController.sdkActiveStateStorage;
//
//    ADJValueWO<ADJSdkActiveStateData *> *_Nonnull changedSdkActiveStateDataWO =
//        [[ADJValueWO alloc] init];
//    ADJValueWO<NSString *> *_Nonnull sdkActiveStatusEventWO = [[ADJValueWO alloc] init];
//
//    [self.sdkActiveState
//        reactivateSdkWithCurrentSdkActiveStateData:
//            [sdkActiveStateStorage readOnlyStoredDataValue]
//        sdkActiveStatusEventWO:sdkActiveStatusEventWO
//        changedSdkActiveStateDataWO:changedSdkActiveStateDataWO
//        adjustApiLogger:entryRoot.adjustApiLogger];
//
//    [self
//        handleStateSideEffectsWithSdkActiveStateStorage:sdkActiveStateStorage
//        changedSdkActiveStateData:changedSdkActiveStateDataWO.changedValue
//        sdkActiveStatusEvent:sdkActiveStatusEventWO.changedValue
//        source:@"ccReactivateSdk"];
//}
//
//- (void)ccGdprForgetDevice {
//    ADJEntryRoot *_Nullable entryRoot = self.entryRootWeak;
//    if (entryRoot == nil) {
//        [self.logger error:@"Cannot ccGdprForgetDevice without a reference to entry root"];
//        return;
//    }
//
//    ADJSdkActiveStateStorage *_Nonnull sdkActiveStateStorage =
//        self.storageRootController.sdkActiveStateStorage;
//
//    ADJValueWO<NSString *> *_Nonnull sdkActiveStatusEventWO = [[ADJValueWO alloc] init];
//
//    BOOL forgetDevice =
//        [self.sdkActiveState
//            tryForgetDeviceWithCurrentSdkActiveStateData:
//                [sdkActiveStateStorage readOnlyStoredDataValue]
//            sdkActiveStatusEventWO:sdkActiveStatusEventWO
//            adjustApiLogger:entryRoot.adjustApiLogger];
//
//    if (forgetDevice) {
//        [self.gdprForgetController forgetDevice];
//    }
//
//    [self handleSdkActiveStatusEvent:[sdkActiveStatusEventWO changedValue]
//                              source:@"ccGdprForgetDevice"];
//}
//
//- (void)ccPutSdkOffline {
//    ADJSdkActiveStateStorage *_Nonnull sdkActiveStateStorage =
//        self.storageRootController.sdkActiveStateStorage;
//
//    NSString *_Nullable cannotPerformActionMessage =
//        [self.sdkActiveState
//            canPerformActiveActionWithCurrentSdkActiveStateData:
//                [sdkActiveStateStorage readOnlyStoredDataValue]
//            source:@"switchToOfflineMode"];
//
//    if (cannotPerformActionMessage != nil) {
//        ADJEntryRoot *_Nullable entryRoot = self.entryRootWeak;
//        if (entryRoot == nil) {
//            [self.logger error:@"%@", cannotPerformActionMessage];
//        } else {
//            [entryRoot.adjustApiLogger error:@"%@", cannotPerformActionMessage];
//        }
//
//        return;
//    }
//
//    [self.offlineController ccPutSdkOffline];
//}
//
//- (void)ccPutSdkOnline {
//    ADJSdkActiveStateStorage *_Nonnull sdkActiveStateStorage =
//        self.storageRootController.sdkActiveStateStorage;
//
//    NSString *_Nullable cannotPerformActionMessage =
//        [self.sdkActiveState
//            canPerformActiveActionWithCurrentSdkActiveStateData:
//                [sdkActiveStateStorage readOnlyStoredDataValue]
//            source:@"switchBackToOnlineMode"];
//
//    if (cannotPerformActionMessage != nil) {
//        ADJEntryRoot *_Nullable entryRoot = self.entryRootWeak;
//        if (entryRoot == nil) {
//            [self.logger error:@"%@", cannotPerformActionMessage];
//        } else {
//            [entryRoot.adjustApiLogger error:@"%@", cannotPerformActionMessage];
//        }
//
//        return;
//    }
//
//    [self.offlineController ccPutSdkOnline];
//}
//
//- (void)ccForeground {
//    [self.lifecycleController ccForeground];
//
//    ADJEntryRoot *_Nullable entryRoot = self.entryRootWeak;
//    if (entryRoot == nil) {
//        return;
//    }
//
//    if (entryRoot.postSdkInitRootController == nil) {
//        return;
//    }
//
//    [entryRoot.postSdkInitRootController.sdkSessionController ccForeground];
//}
//
//- (void)ccBackground {
//    [self.lifecycleController ccBackground];
//
//    ADJEntryRoot *_Nullable entryRoot = self.entryRootWeak;
//    if (entryRoot == nil) {
//        return;
//    }
//
//    if (entryRoot.postSdkInitRootController == nil) {
//        return;
//    }
//
//    [entryRoot.postSdkInitRootController.sdkSessionController ccBackground];
//}
//
//- (void)ccAttributionWithCallback:
//    (nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback
//{
//    [self.clientCallbacksController ccAttributionWithCallback:adjustAttributionCallback];
//}
//
//- (void)ccDeviceIdsWithCallback:
//    (nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback
//{
//    [self.clientCallbacksController ccDeviceIdsWithCallback:adjustDeviceIdsCallback];
//}
//
//- (nullable id<ADJClientActionsAPI>)ccClientActionsWithSource:(nonnull NSString *)source {
//    ADJSdkActiveStateStorage *_Nonnull sdkActiveStateStorage =
//        self.storageRootController.sdkActiveStateStorage;
//
//    NSString *_Nullable cannotPerformActionMessage =
//        [self.sdkActiveState
//            canPerformActiveActionWithCurrentSdkActiveStateData:
//                [sdkActiveStateStorage readOnlyStoredDataValue]
//            source:source];
//
//    if (cannotPerformActionMessage != nil) {
//        ADJEntryRoot *_Nullable entryRoot = self.entryRootWeak;
//
//        if (entryRoot == nil) {
//            [self.logger error:@"%@", cannotPerformActionMessage];
//        } else {
//            [entryRoot.adjustApiLogger error:@"%@", cannotPerformActionMessage];
//        }
//
//        return nil;
//    }
//
//    id<ADJClientActionsAPI> _Nullable sdkStartClientActionAPI =
//        [self sdkStartClientActionAPIwithSource:source];
//
//    if (sdkStartClientActionAPI != nil) {
//        return sdkStartClientActionAPI;
//    } else {
//        return self.clientActionController;
//    }
//}

#pragma mark - Subscriptions
- (void)
    ccSubscribeAndSetPostSdkInitDependenciesWithEntryRoot:(nonnull ADJEntryRoot *)entryRoot
    postSdkInitRootController:(nonnull ADJPostSdkInitRootController *)postSdkInitRootController
    sdkInitPublisher:(nonnull ADJSdkInitPublisher *)sdkInitPublisher
    publishingGatePublisher:(nonnull ADJPublishingGatePublisher *)publishingGatePublisher
{
    /*
    // inject post sdk init dependencies
    [self.clientActionController
        ccSetDependenciesAtSdkInitWithPostSdkInitRootController:postSdkInitRootController];

    [self.gdprForgetController
        ccSetDependenciesAtSdkInitWithSdkPackageBuilder:
            postSdkInitRootController.sdkPackageBuilder
        clock:self.clock
        loggerFactory:entryRoot.logController
        threadpool:entryRoot.threadController
        sdkPackageSenderFactory:postSdkInitRootController.sdkPackageSenderController];

    // subscribing to publishers
    [self.lifecycleController
        ccSubscribeToPublishersWithPublishingGatePublisher:publishingGatePublisher];

    [self.offlineController
        ccSubscribeToPublishersWithPublishingGatePublisher:publishingGatePublisher];

    [self.clientActionController
        ccSubscribeToPublishersWithPreFirstSdkSessionStartPublisher:
            postSdkInitRootController.sdkSessionController.preFirstSdkSessionStartPublisher
        sdkSessionStartPublisher:
            postSdkInitRootController.sdkSessionController.sdkSessionStartPublisher];

    [self.deviceController ccSubscribeToPublishersWithLifecylePublisher:
        self.lifecycleController.lifecyclePublisher];

    [self.gdprForgetController
        ccSubscribeToPublishersWithSdkInitPublisher:postSdkInitRootController.sdkInitPublisher
        publishingGatePublisher:publishingGatePublisher
        lifecyclePublisher:self.lifecycleController.lifecyclePublisher
        sdkResponsePublisher:postSdkInitRootController.sdkPackageSenderController.sdkResponsePublisher];

    [self.pluginController
        ccSubscribeToPublishersWithSdkPackageSendingPublisher:
            postSdkInitRootController.sdkPackageSenderController.sdkPackageSendingPublisher
        lifecyclePublisher:self.lifecycleController.lifecyclePublisher];

    // subscribe self to publishers
    [publishingGatePublisher addSubscriber:self];

    [self.gdprForgetController.gdprForgetPublisher addSubscriber:self];
     */
}

#pragma mark - ADJPublishingGateSubscriber
- (void)ccAllowedToPublishNotifications {
    /*
    ADJSdkActiveStateStorage *_Nonnull sdkActiveStateStorage =
        self.storageRootController.sdkActiveStateStorage;

    ADJValueWO<NSString *> *_Nonnull sdkActiveStatusEventWO = [[ADJValueWO alloc] init];

    [self.sdkActiveState
         canNowPublishWithCurrentSdkActiveStateData:[sdkActiveStateStorage readOnlyStoredDataValue]
         sdkActiveStatusEventWO:sdkActiveStatusEventWO];

    [self handleSdkActiveStatusEvent:sdkActiveStatusEventWO.changedValue
                              source:@"ccAllowedToPublishNotifications"];
     */
}

//#pragma mark - ADJGdprForgetSubscriber
//- (void)didGdprForget {
//    ADJEntryRoot *_Nullable entryRoot = self.entryRootWeak;
//
//    if (entryRoot == nil) {
//        [self.logger error:@"Cannot process gdpr forget event"
//            " without a reference to entry root"];
//        return;
//    }
//
//    __typeof(self) __weak weakSelf = self;
//    [entryRoot.clientExecutor executeInSequenceWithBlock:^{
//        __typeof(weakSelf) __strong strongSelf = weakSelf;
//        if (strongSelf == nil) { return; }
//
//        [strongSelf processGdprForgetEvent];
//    }];
//}
//
//#pragma mark Internal Methods
//- (void)processGdprForgetEvent {
//    ADJValueWO<NSString *> *_Nonnull sdkActiveStatusEventWO = [[ADJValueWO alloc] init];
//
//    [self.sdkActiveState
//        gdprForgetEventReceivedWithSdkActiveStatusEventWO:sdkActiveStatusEventWO];
//
//    [self handleSdkActiveStatusEvent:[sdkActiveStatusEventWO changedValue]
//                              source:@"GdprForgetEvent"];
//}
//
//- (void)
//    handleStateSideEffectsWithSdkActiveStateStorage:
//        (nonnull ADJSdkActiveStateStorage *)sdkActiveStateStorage
//    changedSdkActiveStateData:(nullable ADJSdkActiveStateData *)changedSdkActiveStateData
//    sdkActiveStatusEvent:(nullable NSString *)sdkActiveStatusEvent
//    source:(nonnull NSString *)source
//{
//    if (changedSdkActiveStateData != nil) {
//        [sdkActiveStateStorage updateWithNewDataValue:changedSdkActiveStateData];
//    }
//
//    [self handleSdkActiveStatusEvent:sdkActiveStatusEvent
//                              source:source];
//}
//
//- (void)handleSdkActiveStatusEvent:(nullable NSString *)sdkActiveStatusEvent
//                            source:(nonnull NSString *)source
//{
//    if (sdkActiveStatusEvent == nil) {
//        return;
//    }
//
//    [self.sdkActivePublisher notifySubscribersWithSubscriberBlock:
//     ^(id<ADJSdkActiveSubscriber> _Nonnull subscriber)
//    {
//        [subscriber ccSdkActiveWithStatus:sdkActiveStatusEvent];
//    }];
//}
//
//- (nullable id<ADJClientActionsAPI>)sdkStartClientActionAPIwithSource:(nonnull NSString *)source {
//    ADJEntryRoot *_Nullable entryRoot = self.entryRootWeak;
//
//    if (entryRoot == nil) {
//        [self.logger error:@"Cannot %@ without a reference to entry root", source];
//        return nil;
//    }
//
//    ADJPostSdkInitRootController *_Nullable postSdkInitRootController =
//        entryRoot.postSdkInitRootController;
//
//    if (postSdkInitRootController == nil) {
//        return nil;
//    }
//
//    return [postSdkInitRootController sdkStartClientActionAPI];
//}

@end
