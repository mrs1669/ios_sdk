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

NS_ASSUME_NONNULL_BEGIN

@interface ADJSdkActiveController : ADJCommonBase <
    // subscriptions
    ADJPublishingGateSubscriber,
    ADJGdprForgetSubscriber
>

- (instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                   activeStateStorage:(ADJSdkActiveStateStorage *)activeStateStorage
                       clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
                          isForgotten:(BOOL)isForgotten
                  publisherController:(nonnull ADJPublisherController *)publisherController;
- (nullable instancetype)init NS_UNAVAILABLE;

- (BOOL)ccTrySdkInit;
- (BOOL)ccCanPerformActionWithSource:(nonnull NSString *)source
                        errorMessage:(NSString * _Nullable * _Nullable)errorMessage;
- (void)ccInactivateSdk;
- (void)ccReactivateSdk;
- (BOOL)ccGdprForgetDevice;

@end

NS_ASSUME_NONNULL_END
