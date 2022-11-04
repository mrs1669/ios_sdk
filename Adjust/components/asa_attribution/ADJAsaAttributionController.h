//
//  ADJAsaAttributionController.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJKeepAliveSubscriber.h"
#import "ADJPreFirstMeasurementSessionStartSubscriber.h"
#import "ADJSdkResponseSubscriber.h"
#import "ADJAttributionSubscriber.h"
#import "ADJSdkPackageSendingSubscriber.h"

#import "ADJThreadExecutorFactory.h"
#import "ADJLogQueueController.h"
#import "ADJMainQueueController.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJAsaAttributionStateStorage.h"
#import "ADJClock.h"
#import "ADJClientConfigData.h"
#import "ADJExternalConfigData.h"
#import "ADJAttributionStateStorage.h"

@interface ADJAsaAttributionController : ADJCommonBase<
    // subscriptions
    ADJKeepAliveSubscriber,
    ADJPreFirstMeasurementSessionStartSubscriber,
    ADJSdkResponseSubscriber,
    ADJAttributionSubscriber,
    ADJSdkPackageSendingSubscriber
>
- (void)ccSubscribeToPublishersWithKeepAlivePublisher:(nonnull ADJKeepAlivePublisher *)keepAlivePublisher
                     preFirstMeasurementSessionStartPublisher:(nonnull ADJPreFirstMeasurementSessionStartPublisher *)preFirstMeasurementSessionStartPublisher
                                 sdkResponsePublisher:(nonnull ADJSdkResponsePublisher *)sdkResponsePublisher
                                 attributionPublisher:(nonnull ADJAttributionPublisher *)attributionPublisher
                           sdkPackageSendingPublisher:(nonnull ADJSdkPackageSendingPublisher *)sdkPackageSendingPublisher;

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                        threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                   asaAttributionStateStorage:(nonnull ADJAsaAttributionStateStorage *)asaAttributionStateStorage
                                        clock:(nonnull ADJClock *)clock
                             clientConfigData:(nonnull ADJClientConfigData *)clientConfigData
                         asaAttributionConfig:(nonnull ADJExternalConfigData *)asaAttributionConfig
                           logQueueController:(nonnull ADJLogQueueController *)logQueueController
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
                adjustAttributionStateStorage:(nonnull ADJAttributionStateStorage *)adjustAttributionStateStorage;

@end
