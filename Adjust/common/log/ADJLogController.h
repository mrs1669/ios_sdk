//
//  ADJLogController.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJLogCollector.h"
#import "ADJLoggerFactory.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJPublishingGateSubscriber.h"
#import "ADJLogSubscriber.h"
#import "ADJLogger.h"
#import "ADJSingleThreadExecutor.h"

@interface ADJLogController : NSObject <
    ADJLogCollector,
    ADJLoggerFactory,
    // subscriptions
    ADJSdkInitSubscriber,
    ADJPublishingGateSubscriber
>
- (void)
    ccSubscribeToPublishersWithSdkInitPublisher:(nonnull ADJSdkInitPublisher *)sdkInitPublisher
    publishingGatePublisher:(nonnull ADJPublishingGatePublisher *)publishingGatePublisher;

// publishers
@property (nonnull, readonly, strong, nonatomic) ADJLogPublisher *logPublisher;

// instantiation
- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;

// public api
- (void)injectDependeciesWithCommonExecutor:(nonnull ADJSingleThreadExecutor *)commonExecutor;
- (void)setEnvironmentToSandbox;

@end
