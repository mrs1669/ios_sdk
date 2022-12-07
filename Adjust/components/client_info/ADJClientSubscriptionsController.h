//
//  ADJClientSubscriptionsController.h
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJAttributionSubscriber.h"
#import "ADJLogSubscriber.h"
#import "ADJThreadController.h"
#import "ADJClientReturnExecutor.h"
#import "ADJAdjustLogSubscriber.h"
#import "ADJAdjustAttributionSubscriber.h"

@interface ADJClientSubscriptionsController : ADJCommonBase<
    // subscriptions
    ADJAttributionSubscriber,
    ADJLogSubscriber
>

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             threadController:(nonnull ADJThreadController *)threadController
                         clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
                  adjustAttributionSubscriber:(nullable id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber
                          adjustLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustLogSubscriber
                    doNotOpenDeferredDeeplink:(BOOL)doNotOpenDeferredDeeplink;

@end
