//
//  ADJAttributionController.h
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSdkPackageSenderFactory.h"
#import "ADJSdkStartSubscriber.h"
#import "ADJSdkResponseSubscriber.h"
#import "ADJPausingSubscriber.h"
#import "ADJAttributionStateStorage.h"
#import "ADJClock.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJThreadController.h"
#import "ADJAttributionSubscriber.h"
#import "ADJBackoffStrategy.h"
#import "ADJNetworkEndpointData.h"
#import "ADJClientConfigData.h"
#import "ADJPublisherController.h"
#import "ADJMainQueueTrackedPackages.h"

@interface ADJAttributionController : ADJCommonBase<
    ADJSdkResponseCallbackSubscriber,
    // subscriptions
    ADJSdkStartSubscriber,
    ADJSdkResponseSubscriber,
    ADJPausingSubscriber
>

// instantiation
+ (nonnull ADJAttributionController *)
    instanceWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    attributionStateStorage:(nonnull ADJAttributionStateStorage *)attributionStateStorage
    clock:(nonnull ADJClock *)clock
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    threadController:(nonnull ADJThreadController *)threadController
    attributionBackoffStrategy:(nonnull ADJBackoffStrategy *)attributionBackoffStrategy
    sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory
    mainQueueTrackedPackages:
        (nonnull ADJMainQueueTrackedPackages *)mainQueueTrackedPackages
    doNotInitiateAttributionFromSdk:(BOOL)doNotInitiateAttributionFromSdk
    publisherController:(nonnull ADJPublisherController *)publisherController;

@end

