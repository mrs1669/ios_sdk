//
//  ADJMeasurementSessionController.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSdkActiveSubscriber.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJKeepAliveSubscriber.h"
#import "ADJLifecycleSubscriber.h"
#import "ADJMeasurementSessionStartSubscriber.h"
#import "ADJPreFirstMeasurementSessionStartSubscriber.h"
#import "ADJTimeLengthMilli.h"
#import "ADJSingleThreadExecutor.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJMeasurementSessionStateStorage.h"
#import "ADJMainQueueController.h"
#import "ADJClock.h"
#import "ADJMeasurementSessionStateData.h"
#import "ADJLogger.h"
#import "ADJPublisherController.h"

@interface ADJMeasurementSessionController : ADJCommonBase<
    // subscriptions
    ADJSdkActiveSubscriber,
    ADJSdkInitSubscriber,
    ADJKeepAliveSubscriber,
    ADJLifecycleSubscriber
>

// publishers
@property (nonnull, readonly, strong, nonatomic) ADJMeasurementSessionStartPublisher *measurementSessionStartPublisher;
@property (nonnull, readonly, strong, nonatomic) ADJPreFirstMeasurementSessionStartPublisher *preFirstMeasurementSessionStartPublisher;

// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    minMeasurementSessionIntervalMilli:
        (nonnull ADJTimeLengthMilli *)minMeasurementSessionIntervalMilli
    overwriteFirstMeasurementSessionIntervalMilli:
        (nullable ADJTimeLengthMilli *)overwriteFirstMeasurementSessionIntervalMilli
    clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    measurementSessionStateStorage:
        (nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage
    mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
    clock:(nonnull ADJClock *)clock
    publisherController:(nonnull ADJPublisherController *)publisherController;

// public api
- (nullable ADJMeasurementSessionStateData *)currentMeasurementSessionStateDataWithLogger:(nonnull ADJLogger *)logger;

@end
