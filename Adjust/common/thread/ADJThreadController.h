//
//  ADJThreadController.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJThreadPool.h"
#import "ADJThreadExecutorFactory.h"
#import "ADJTeardownFinalizer.h"
#import "ADJClientReturnExecutor.h"
#import "ADJTimeLengthMilli.h"

@interface ADJThreadController : ADJCommonBase<
    ADJThreadPool,
    ADJThreadExecutorFactory,
    ADJClientReturnExecutor,
    ADJTeardownFinalizer
>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)executeInMainThreadWithBlock:(nonnull void (^)(void))blockToExecute;

@end

