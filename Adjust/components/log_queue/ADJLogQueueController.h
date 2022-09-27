//
//  ADJLogQueueController.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSdkPackageSender.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJPausingSubscriber.h"
#import "ADJLogQueueStorage.h"
#import "ADJThreadController.h"
#import "ADJClock.h"
#import "ADJBackoffStrategy.h"
#import "ADJSdkPackageSenderFactory.h"
#import "ADJLogPackageData.h"

@interface ADJLogQueueController : ADJCommonBase<
    ADJSdkResponseCallbackSubscriber,
    // subscriptions
    ADJSdkInitSubscriber,
    ADJPausingSubscriber
>
- (void)ccSubscribeToPublishersWithSdkInitPublisher:(nonnull ADJSdkInitPublisher *)sdkInitPublisher
                                   pausingPublisher:(nonnull ADJPausingPublisher *)pausingPublisher;

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                      storage:(nonnull ADJLogQueueStorage *)storage
                             threadController:(nonnull ADJThreadController *)threadController
                                        clock:(nonnull ADJClock *)clock
                              backoffStrategy:(nonnull ADJBackoffStrategy *)backoffStrategy
                      sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory;

- (void)addLogPackageDataToSendWithData:(nonnull ADJLogPackageData *)logPackageData;

@end
