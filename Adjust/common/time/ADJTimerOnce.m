//
//  ADJTimerOnce.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJTimerOnce.h"

#import "ADJUtilSys.h"

#pragma mark Fields
@implementation ADJTimerOnce {
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
- (void)executeWithDelayTimeMilli:(nonnull ADJTimeLengthMilli *)delayTimeMilli
                            block:(nonnull dispatch_block_t)block
{
    @synchronized (self) {
        [self cancelDelaySync];

        _dispatchSource =
            dispatch_source_create
                (DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
                 dispatch_get_global_queue
                    (DISPATCH_QUEUE_PRIORITY_LOW, 0));

        if (! _dispatchSource) {
            return;
        }

        dispatch_source_set_timer
            (_dispatchSource,
             [ADJUtilSys dispatchTimeWithMilli:delayTimeMilli.millisecondsSpan.uIntegerValue],
             DISPATCH_TIME_FOREVER,
             100ull * NSEC_PER_SEC);

        __typeof(self) __weak weakSelf = self;

        dispatch_source_set_event_handler(_dispatchSource, ^{
            block();

            __typeof(weakSelf) __strong strongSelf = weakSelf;
            if (strongSelf == nil) { return; }

            [strongSelf cancelDelay];
        });

        dispatch_resume(_dispatchSource);
    }
}

- (BOOL)cancelDelay {
    @synchronized (self) {
        return [self cancelDelaySync];
    }
}

- (BOOL)isInDelay {
    @synchronized (self) {
        return _dispatchSource != NULL;
    }
}

#pragma mark Internal Methods
- (BOOL)cancelDelaySync {
    if (! _dispatchSource) {
        return NO;
    }
    dispatch_source_cancel(_dispatchSource);
    _dispatchSource = nil;
    return YES;
}

@end
