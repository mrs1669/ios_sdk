//
//  ADJMeasurementSessionController.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJMeasurementLifecycleSubscriber.h"
#import "ADJKeepAlivePingSubscriber.h"
#import "ADJLifecycleSubscriber.h"
#import "ADJTimeLengthMilli.h"
#import "ADJSingleThreadExecutor.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJMeasurementSessionStateStorage.h"
#import "ADJMainQueueController.h"
#import "ADJClock.h"
#import "ADJMeasurementSessionStateData.h"
#import "ADJLogger.h"
#import "ADJPublisherController.h"
#import "ADJClientActionController.h"

@interface ADJMeasurementSessionController : ADJCommonBase<
    // subscriptions
    ADJMeasurementLifecycleSubscriber,
    ADJKeepAlivePingSubscriber
>

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                minMeasurementSessionInterval:(nonnull ADJTimeLengthMilli *)minMeasurementSessionInterval
     overwriteFirstMeasurementSessionInterval:(nullable ADJTimeLengthMilli *)overwriteFirstMeasurementSessionInterval
                               clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
               measurementSessionStateStorage:(nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
                                        clock:(nonnull ADJClock *)clock
                       clientActionController:(nonnull ADJClientActionController *)clientActionController;

// public api
- (BOOL)ccTryStartSdk;

@end
