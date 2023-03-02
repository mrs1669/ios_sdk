//
//  ADJMeasurementLifecycleController.h
//  Adjust
//
//  Created by Pedro Silva on 01.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJLifecycleSubscriber.h"
#import "ADJSdkActiveSubscriber.h"
#import "ADJMeasurementLifecycleSubscriber.h"
#import "ADJSdkStartSubscriber.h"
#import "ADJSingleThreadExecutor.h"
#import "ADJMeasurementSessionController.h"
#import "ADJThreadExecutorFactory.h"
#import "ADJKeepAlivePingSubscriber.h"
#import "ADJPublisherController.h"

@interface ADJMeasurementLifecycleController : ADJCommonBase<
    // subscriptions
    ADJSdkActiveSubscriber,
    ADJLifecycleSubscriber
>
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
    measurementSessionController:
        (nonnull ADJMeasurementSessionController *)measurementSessionController
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    resumedSessionTimerStart:(nonnull ADJTimeLengthMilli *)resumedSessionTimerStart
    resumedSessionTimerInterval:(nonnull ADJTimeLengthMilli *)resumedSessionTimerInterval
    publisherController:(nonnull ADJPublisherController *)publisherController;

// public api
- (void)ccPostSdkInit;

@end
