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
                            sourceDescription:(nonnull NSString *)sourceDescription;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (BOOL)scheduleInSequenceWithBlock:(nonnull void (^)(void))blockToSchedule
                     delayTimeMilli:(nonnull ADJTimeLengthMilli *)delayTimeMilli
                             source:(nonnull NSString *)source;

- (BOOL)executeInSequenceWithBlock:(nonnull void (^)(void))blockToExecute
                            source:(nonnull NSString *)source;

- (BOOL)executeInSequenceSkippingTraceWithBlock:(nonnull void (^)(void))blockToExecute;

- (BOOL)executeAsyncWithBlock:(nonnull void (^)(void))blockToExecute
                       source:(nonnull NSString *)source;

- (BOOL)executeSynchronouslyWithTimeout:(nonnull ADJTimeLengthMilli *)timeout
                         blockToExecute:(nonnull void (^)(void))blockToExecute
                                 source:(nonnull NSString *)source;


// temporary
- (BOOL)scheduleInSequenceWithBlock:(nonnull void (^)(void))blockToSchedule
                     delayTimeMilli:(nonnull ADJTimeLengthMilli *)delayTimeMilli;

- (BOOL)executeInSequenceWithBlock:(nonnull void (^)(void))blockToExecute;

- (BOOL)executeAsyncWithBlock:(nonnull void (^)(void))blockToExecute;

- (BOOL)executeSynchronouslyWithTimeout:(nonnull ADJTimeLengthMilli *)timeout
                         blockToExecute:(nonnull void (^)(void))blockToExecute;

@end

