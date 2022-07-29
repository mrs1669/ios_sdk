//
//  ADJClientActionController.h
//  Adjust
//
//  Created by Genady Buchatsky on 29.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJClientActionsAPI.h"
#import "ADJPreFirstMeasurementSessionStartSubscriber.h"
#import "ADJMeasurementSessionStartSubscriber.h"
#import "ADJClientActionStorage.h"
#import "ADJClock.h"

//#import "ADJPostSdkInitRootController.h"
@class ADJPostSdkInitRootController;

@interface ADJClientActionController : ADJCommonBase<ADJClientActionsAPI,
// subscriptions
ADJPreFirstMeasurementSessionStartSubscriber,
ADJMeasurementSessionStartSubscriber
>
// subscriptions and dependencies
- (void)ccSetDependenciesAtSdkInitWithPostSdkInitRootController: (nonnull ADJPostSdkInitRootController *)postSdkInitRootController;
- (void)ccSubscribeToPublishersWithPreFirstSdkSessionStartPublisher:(nonnull ADJPreFirstMeasurementSessionStartPublisher *)preFirstSdkSessionStartPublisher
                                           sdkSessionStartPublisher:(nonnull ADJMeasurementSessionStartPublisher *)measurementSessionStartPublisher;

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                          clientActionStorage:(nonnull ADJClientActionStorage *)clientActionStorage
                                        clock:(nonnull ADJClock *)clock;

/*
 public void ccSetDependenciesAtSdkInit(
 @NonNull final PostSdkInitRootController postSdkInitRootController)
 {
 postSdkInitControllerWeakRef = new WeakReference<>(postSdkInitRootController);
 }

 */
@end
