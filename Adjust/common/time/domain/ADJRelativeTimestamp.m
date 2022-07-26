//
//  ADJRelativeTimestamp.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJRelativeTimestamp.h"

#import "ADJConstants.h"

@implementation ADJRelativeTimestamp {
#pragma mark - Unmanaged variables
    struct timespec * _timespecPtr;
    struct timeval * _timevalPtr;
}

- (nonnull instancetype)initWithTimespec:(struct timespec)timespecValue {
    return [self initWithTimespec:&timespecValue timeval:NULL];
}

- (nonnull instancetype)initWithTimeval:(struct timeval)timevalValue {
    return [self initWithTimespec:NULL timeval:&timevalValue];
}

- (nonnull instancetype)initWithTimespec:(struct timespec *_Nullable)timespecPtr
                                 timeval:(struct timeval *_Nullable)timevalPtr {
    self = [super init];
    
    if (timespecPtr) {
        *_timespecPtr = *timespecPtr;
        _timevalPtr = NULL;
    } else {
        _timespecPtr = NULL;
        *_timevalPtr = *timevalPtr;
    }
    
    return self;
}

#pragma mark Public API
- (BOOL)hasEnoughTimePassedSince:(nonnull ADJRelativeTimestamp *)sinceTime
                enoughTimeLength:(nonnull ADJTimeLengthMilli *)enoughTimeLength {
    NSNumber *_Nullable millisecondsDiffSinceUIntegerNumber = [self millisecondsDiffSince:sinceTime];
    if (millisecondsDiffSinceUIntegerNumber == nil) {
        return NO;
    }
    
    return millisecondsDiffSinceUIntegerNumber.unsignedIntegerValue
    >= enoughTimeLength.millisecondsSpan.uIntegerValue;
}

#pragma mark Internal Methods
- (nullable NSNumber *)millisecondsDiffSince:(nonnull ADJRelativeTimestamp *)sinceTime {
    if (_timespecPtr) {
        if (_timespecPtr->tv_sec < sinceTime->_timespecPtr->tv_sec) {
            return nil;
        }
        if (_timespecPtr->tv_sec == sinceTime->_timespecPtr->tv_sec
            && _timespecPtr->tv_nsec < sinceTime->_timespecPtr->tv_nsec)
        {
            return nil;
        }
        
        struct timespec diff = {
            _timespecPtr->tv_sec - sinceTime->_timespecPtr->tv_sec,
            _timespecPtr->tv_nsec - sinceTime->_timespecPtr->tv_nsec
        };
        
        return @(
        ((NSUInteger)diff.tv_sec) * ADJOneSecondMilli +
        ((NSUInteger)diff.tv_nsec) / ADJMilliToNano
        );
    } else {
        if (_timevalPtr->tv_sec < sinceTime->_timevalPtr->tv_sec) {
            return nil;
        }
        if (_timevalPtr->tv_sec == sinceTime->_timevalPtr->tv_sec
            && _timevalPtr->tv_usec < sinceTime->_timevalPtr->tv_usec)
        {
            return nil;
        }
        
        struct timeval diff = {
            _timevalPtr->tv_sec - sinceTime->_timevalPtr->tv_sec,
            _timevalPtr->tv_usec - sinceTime->_timevalPtr->tv_usec
        };
        
        return @(
        ((NSUInteger)diff.tv_sec) * ADJOneSecondMilli +
        ((NSUInteger)diff.tv_usec) / ADJMilliToMicro
        );
    }
}

@end

