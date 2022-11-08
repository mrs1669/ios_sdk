//
//  ADJThreadController.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJThreadExecutorFactory.h"
#import "ADJClientReturnExecutor.h"
#import "ADJConcurrentThreadExecutor.h"
#import "ADJTeardownFinalizer.h"
#import "ADJTimeLengthMilli.h"

@interface ADJThreadController : ADJCommonBase<
    ADJThreadExecutorFactory,
    ADJClientReturnExecutor,
    ADJConcurrentThreadExecutor,
    ADJTeardownFinalizer
>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)executeInMainThreadWithBlock:(nonnull void (^)(void))blockToExecute;

@end

