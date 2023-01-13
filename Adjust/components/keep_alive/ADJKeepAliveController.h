//
//  ADJKeepAliveController.h
//  Adjust
//
//  Created by Pedro S. on 16.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJMeasurementSessionStartSubscriber.h"
#import "ADJLifecycleSubscriber.h"
#import "ADJKeepAliveSubscriber.h"
#import "ADJThreadExecutorFactory.h"
#import "ADJPublisherController.h"

@interface ADJKeepAliveController : ADJCommonBase<
    // subscriptions
    ADJMeasurementSessionStartSubscriber,
    ADJLifecycleSubscriber
>

// publishers
@property (nonnull, readonly, strong, nonatomic)ADJKeepAlivePublisher *keepAlivePublisher;

// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    foregroundTimerStartMilli:(nonnull ADJTimeLengthMilli *)foregroundTimerStartMilli
    foregroundTimerIntervalMilli:(nonnull ADJTimeLengthMilli *)foregroundTimerIntervalMilli
    publisherController:(nonnull ADJPublisherController *)publisherController;

@end

