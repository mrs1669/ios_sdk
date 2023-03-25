//
//  ADJSdkActiveController.h
//  Adjust
//
//  Created by Genady Buchatsky on 11.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJCommonBase.h"
#import "ADJPublishingGateSubscriber.h"
#import "ADJGdprForgetSubscriber.h"
#import "ADJSdkActiveStateStorage.h"
#import "ADJPublisherController.h"

@interface ADJSdkActiveController : ADJCommonBase<
    // subscriptions
    ADJPublishingGateSubscriber,
    ADJGdprForgetSubscriber
>
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    activeStateStorage:(nonnull ADJSdkActiveStateStorage *)activeStateStorage
    clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
    isForgotten:(BOOL)isForgotten
    publisherController:(nonnull ADJPublisherController *)publisherController;
- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (BOOL)ccTrySdkInit;

- (nullable ADJResultFail *)ccCanPerformClientAction;

- (void)ccInactivateSdk;
- (void)ccReactivateSdk;

- (BOOL)ccGdprForgetDevice;

@end
