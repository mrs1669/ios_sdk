//
//  ADJGdprForgetController.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSdkPackageSenderFactory.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJPublishingGateSubscriber.h"
#import "ADJLifecycleSubscriber.h"
#import "ADJThreadExecutorFactory.h"
#import "ADJSdkResponseSubscriber.h"
#import "ADJGdprForgetStateStorage.h"
#import "ADJBackoffStrategy.h"
#import "ADJGdprForgetSubscriber.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJClock.h"
#import "ADJNetworkEndpointData.h"
#import "ADJPublishersRegistry.h"

@interface ADJGdprForgetController : ADJCommonBase<
    ADJSdkResponseCallbackSubscriber,
    // subscriptions
    ADJSdkInitSubscriber,
    ADJPublishingGateSubscriber,
    ADJLifecycleSubscriber,
    ADJSdkResponseSubscriber
>

// publishers
@property (nonnull, readonly, strong, nonatomic) ADJGdprForgetPublisher *gdprForgetPublisher;

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                       gdprForgetStateStorage:(nonnull ADJGdprForgetStateStorage *)gdprForgetStateStorage
                        threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
                    gdprForgetBackoffStrategy:(nonnull ADJBackoffStrategy *)gdprForgetBackoffStrategy
                           publishersRegistry:(nonnull ADJPublishersRegistry *)pubRegistry;

- (void)ccSetDependenciesAtSdkInitWithSdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                                                  clock:(nonnull ADJClock *)clock
                                          loggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                  threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
                                sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory;

// public api
- (BOOL)isForgotten;

- (void)forgetDevice;

@end

