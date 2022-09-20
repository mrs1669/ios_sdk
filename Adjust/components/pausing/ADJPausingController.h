//
//  ADJPausingController.h
//  Adjust
//
//  Created by Pedro S. on 06.03.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJPublishingGateSubscriber.h"
#import "ADJOfflineSubscriber.h"
#import "ADJReachabilitySubscriber.h"
#import "ADJLifecycleSubscriber.h"
#import "ADJMeasurementSessionStartSubscriber.h"
#import "ADJSdkActiveSubscriber.h"
#import "ADJPausingSubscriber.h"
#import "ADJThreadExecutorFactory.h"

@interface ADJPausingController : ADJCommonBase<
    // subscriptions
    ADJPublishingGateSubscriber,
    ADJOfflineSubscriber,
    ADJReachabilitySubscriber,
    ADJLifecycleSubscriber,
    ADJMeasurementSessionStartSubscriber,
    ADJSdkActiveSubscriber
>
- (void)ccSubscribeToPublishersWithPublishingGate:(nonnull ADJPublishingGatePublisher *)publishingGatePublisher
                                 offlinePublisher:(nonnull ADJOfflinePublisher *)offlinePublisher
                            reachabilityPublisher:(nonnull ADJReachabilityPublisher *)reachabilityPublisher
                               lifecyclePublisher:(nonnull ADJLifecyclePublisher *)lifecyclePublisher
                 measurementSessionStartPublisher:(nonnull ADJMeasurementSessionStartPublisher *)measurementSessionStartPublisher
                               sdkActivePublisher:(nonnull ADJSdkActivePublisher *)sdkActivePublisher;

// publishers
@property (nonnull, readonly, strong, nonatomic) ADJPausingPublisher *pausingPublisher;

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                        threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
                          canSendInBackground:(BOOL)canSendInBackground;

@end

