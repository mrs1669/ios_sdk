//
//  ADJSingleThreadExecutor.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJTimeLengthMilli.h"
#import "ADJTeardownFinalizer.h"
#import "ADJThreadPool.h"

@interface ADJSingleThreadExecutor : ADJCommonBase<ADJTeardownFinalizer>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sourceDescription:(nonnull NSString *)sourceDescription
                                   threadPool:(nonnull id<ADJThreadPool>)threadPool;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (BOOL)scheduleInSequenceWithBlock:(nonnull void (^)(void))blockToSchedule
                     delayTimeMilli:(nonnull ADJTimeLengthMilli *)delayTimeMilli;

- (BOOL)executeInSequenceWithBlock:(nonnull void (^)(void))blockToExecute;

@end

