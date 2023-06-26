//
//  ADJClientSubscriptionsController.h
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJAttributionSubscriber.h"
#import "ADJLogSubscriber.h"
#import "ADJThreadController.h"
#import "ADJAttributionStateStorage.h"
#import "ADJClientReturnExecutor.h"
#import "ADJAdjustLogSubscriber.h"
#import "ADJAdjustAttributionSubscriber.h"
#import "ADJAdjustInternal.h"

@interface ADJClientSubscriptionsController : ADJCommonBase<
    // subscriptions
    ADJSdkInitSubscriber,
    ADJAttributionSubscriber,
    ADJLogSubscriber
>

// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadController:(nonnull ADJThreadController *)threadController
    attributionStateStorage:(nonnull ADJAttributionStateStorage *)attributionStateStorage
    clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
    adjustAttributionSubscriber:
        (nullable id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber
    adjustLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustLogSubscriber
    internalConfigSubscriptions:
        (nullable NSDictionary<NSString *, id<ADJInternalCallback>> *)internalConfigSubscriptions
    doNotOpenDeferredDeeplink:(BOOL)doNotOpenDeferredDeeplink;

@end
