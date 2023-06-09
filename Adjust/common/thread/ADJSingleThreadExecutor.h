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

@interface ADJSingleThreadExecutor : ADJCommonBase<ADJTeardownFinalizer>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             sourceLoggerName:(nonnull NSString *)sourceLoggerName;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (BOOL)scheduleInSequenceWithBlock:(nonnull void (^)(void))blockToSchedule
                     delayTimeMilli:(nonnull ADJTimeLengthMilli *)delayTimeMilli
                               from:(nonnull NSString *)from;

- (BOOL)executeInSequenceWithBlock:(nonnull void (^)(void))blockToExecute
                              from:(nonnull NSString *)from;

- (BOOL)executeInSequenceSkippingTraceWithBlock:(nonnull void (^)(void))blockToExecute;

- (BOOL)executeAsyncWithBlock:(nonnull void (^)(void))blockToExecute
                         from:(nonnull NSString *)from;

- (BOOL)executeSynchronouslyWithTimeout:(nonnull ADJTimeLengthMilli *)timeout
                         blockToExecute:(nonnull void (^)(void))blockToExecute
                                   from:(nonnull NSString *)from;

@end

