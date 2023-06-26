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
#import "ADJResultFail.h"
#import "ADJLogger.h"

@interface ADJSingleThreadExecutor : ADJCommonBase<ADJTeardownFinalizer>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             sourceLoggerName:(nonnull NSString *)sourceLoggerName;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (nullable ADJResultFail *)scheduleInSequenceFrom:(nonnull NSString *)from
                                    delayTimeMilli:(nonnull ADJTimeLengthMilli *)delayTimeMilli
                                             block:(nonnull void (^)(void))blockToSchedule;
- (void)scheduleInSequenceWithLogger:(nonnull ADJLogger *)logger
                                from:(nonnull NSString *)from
                      delayTimeMilli:(nonnull ADJTimeLengthMilli *)delayTimeMilli
                               block:(nonnull void (^)(void))blockToSchedule;

- (nullable ADJResultFail *)executeInSequenceFrom:(nonnull NSString *)from
                                            block:(nonnull void (^)(void))blockToExecute;
- (void)executeInSequenceWithLogger:(nonnull ADJLogger *)logger
                               from:(nonnull NSString *)from
                              block:(nonnull void (^)(void))blockToExecute;

- (nullable ADJResultFail *)
    executeInSequenceSkippingTraceWithBlock:(nonnull void (^)(void))block;

- (nullable ADJResultFail *)executeAsyncFrom:(nonnull NSString *)from
                                       block:(nonnull void (^)(void))blockToExecute;
- (void)executeAsyncWithLogger:(nonnull ADJLogger *)logger
                          from:(nonnull NSString *)from
                         block:(nonnull void (^)(void))blockToExecute;

- (nullable ADJResultFail *)executeSynchronouslyFrom:(nonnull NSString *)from
                                             timeout:(nonnull ADJTimeLengthMilli *)timeout
                                               block:(nonnull void (^)(void))blockToExecute;
- (void)executeSynchronouslyWithLogger:(nonnull ADJLogger *)logger
                                  from:(nonnull NSString *)from
                               timeout:(nonnull ADJTimeLengthMilli *)timeout
                                 block:(nonnull void (^)(void))blockToExecute;

@end
