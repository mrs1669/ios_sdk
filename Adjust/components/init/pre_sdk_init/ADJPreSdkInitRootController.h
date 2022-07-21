//
//  ADJPreSdkInitRootController.h
//  AdjustV5
//
//  Created by Pedro S. on 24.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJClientAPI.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJPublishingGateSubscriber.h"
//#import "ADJGdprForgetSubscriber.h"
#import "ADJClock.h"
#import "ADJStorageRootController.h"
//#import "ADJGdprForgetController.h"
//#import "ADJLifecycleController.h"
//#import "ADJOfflineController.h"
//#import "ADJClientActionController.h"
//#import "ADJDeviceController.h"
#import "ADJSdkActiveSubscriber.h"
//#import "ADJClientCallbacksController.h"
//#import "ADJPluginController.h"

//#import "ADJPostSdkInitRootController.h"
//@class ADJPostSdkInitRootController;
//#import "ADJEntryRoot.h"
@class ADJEntryRoot;

@interface ADJPreSdkInitRootController : ADJCommonBase<
    ADJClientAPI,
    // subscriptions
    ADJPublishingGateSubscriber
//    ADJGdprForgetSubscriber
>
//- (void)
//    ccSubscribeAndSetPostSdkInitDependenciesWithEntryRoot:(nonnull ADJEntryRoot *) entryRoot
//    postSdkInitRootController:(nonnull ADJPostSdkInitRootController *)postSdkInitRootController
//    sdkInitPublisher:(nonnull ADJSdkInitPublisher *)sdkInitPublisher
//    publishingGatePublisher:(nonnull ADJPublishingGatePublisher *)publishingGatePublisher;
// publishers
@property (nonnull, readonly, strong, nonatomic)
    ADJSdkActivePublisher *sdkActivePublisher;

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                    entryRoot:(nonnull ADJEntryRoot *)entryRoot;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJClock *clock;
//@property (nonnull, readonly, strong, nonatomic)
//    ADJStorageRootController *storageRootController;
//@property (nonnull, readonly, strong, nonatomic)
//    ADJGdprForgetController *gdprForgetController;
//@property (nonnull, readonly, strong, nonatomic)
//    ADJLifecycleController *lifecycleController;
//@property (nonnull, readonly, strong, nonatomic)
//    ADJOfflineController *offlineController;
//@property (nonnull, readonly, strong, nonatomic)
//    ADJClientActionController *clientActionController;
//@property (nonnull, readonly, strong, nonatomic)
//    ADJDeviceController *deviceController;
//@property (nonnull, readonly, strong, nonatomic)
//    ADJClientCallbacksController *clientCallbacksController;
//@property (nonnull, readonly, strong, nonatomic) ADJPluginController *pluginController;

@end
