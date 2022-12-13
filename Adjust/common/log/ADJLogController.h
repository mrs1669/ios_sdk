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
#import "ADJSdkConfigData.h"

@interface ADJLogController : NSObject<
    ADJLogCollector,
    ADJLoggerFactory,
    // subscriptions
    ADJSdkInitSubscriber,
    ADJPublishingGateSubscriber
>
- (void)ccSubscribeToPublishersWithSdkInitPublisher:(nonnull ADJSdkInitPublisher *)sdkInitPublisher
                            publishingGatePublisher:(nonnull ADJPublishingGatePublisher *)publishingGatePublisher;

// publishers
@property (nonnull, readonly, strong, nonatomic) ADJLogPublisher *logPublisher;

// instantiation
- (nonnull instancetype)initWithInstanceId:(nullable NSString *)instanceId
                             sdkConfigData:(nonnull ADJSdkConfigData *)sdkConfigData
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)injectDependeciesWithCommonExecutor:(nonnull ADJSingleThreadExecutor *)commonExecutor;

@end
