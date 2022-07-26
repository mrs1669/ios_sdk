//
//  ADJTimerCycle.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJTimerCycle.h"

#import "ADJUtilSys.h"

#pragma mark Fields
@implementation ADJTimerCycle {
#pragma mark - Unmanaged variables
    dispatch_source_t _dispatchSource;
}

#pragma mark Instantiation
- (nonnull instancetype)init {
    self = [super init];

    _dispatchSource = nil;

    return self;
}

#pragma mark Public API
- (void)cycleWithDelayTimeMilli:(nonnull ADJTimeLengthMilli *)delayTimeMilli
                  cycleInterval:(nonnull ADJTimeLengthMilli *)cycleIntervalMilli
                          block:(nonnull dispatch_block_t)block
{
    @synchronized (self) {
        [self cancelDelayAndCycleI];

        self->_dispatchSource =
            dispatch_source_create
                (DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
                 dispatch_get_global_queue
                    (DISPATCH_QUEUE_PRIORITY_LOW, 0));

        if (!self->_dispatchSource) {
            return;
        }

        dispatch_source_set_timer
            (self->_dispatchSource,
             [ADJUtilSys dispatchTimeWithMilli:delayTimeMilli.millisecondsSpan.uIntegerValue],
             [ADJUtilSys convertMilliToNano:cycleIntervalMilli.millisecondsSpan.uIntegerValue],
             100ull * NSEC_PER_SEC);

        dispatch_source_set_event_handler(self->_dispatchSource, block);

        dispatch_resume(self->_dispatchSource);
    }
}

- (BOOL)cancelDelayAndCycle {
    @synchronized (self) {
        return [self cancelDelayAndCycleI];
    }
}

- (BOOL)cancelDelayAndCycleI {
    if (!self->_dispatchSource) {
        return NO;
    }
    dispatch_source_cancel(self->_dispatchSource);
    self->_dispatchSource = nil;
    return YES;
}

@end
