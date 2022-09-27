//
//  ADJPluginController.h
//  Adjust
//
//  Created by Pedro S. on 16.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSdkPackageCreatingSubscriber.h"
#import "ADJSdkPackageSendingSubscriber.h"
#import "ADJLifecycleSubscriber.h"

@interface ADJPluginController : ADJCommonBase<
    // subscriptions
    ADJSdkPackageSendingSubscriber,
    ADJLifecycleSubscriber
>
- (void)ccSubscribeToPublishersWithSdkPackageSendingPublisher:(nonnull ADJSdkPackageSendingPublisher *)sdkPackageSendingPublisher
                                           lifecyclePublisher:(nonnull ADJLifecyclePublisher *)lifecyclePublisher;

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory;

@end

