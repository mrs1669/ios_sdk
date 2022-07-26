//
//  ADJBackoffStrategy.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJBackoffStrategy.h"

#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Private constants
static NSUInteger kShortMilliMultiplier = 100;
static NSUInteger kShortMaxHourCount = 1;

static NSUInteger kMediumSecondsMultiplier = 2;
static NSUInteger kMediumMaxHourCount = 1;

static NSUInteger kLongMinutesMultiplier = 1;
static NSUInteger kLongMaxWaitHours = 24;


@interface ADJBackoffStrategy ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJNonNegativeInt *minRetriesBeforeBackoff;
@property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *multiplier;
@property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *maxWait;

@end

@implementation ADJBackoffStrategy
#pragma mark Instantiation
- (nonnull instancetype)initWithShortWait {
    ADJTimeLengthMilli *_Nonnull milliMultiplier =
    [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
     [[ADJNonNegativeInt alloc] initWithUIntegerValue:kShortMilliMultiplier]];
    
    ADJTimeLengthMilli *_Nonnull maxWaitMilli =
    [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
     [[ADJNonNegativeInt alloc] initWithUIntegerValue:
      kShortMaxHourCount * ADJOneHourMilli]];
    
    return [self initWithMinRetriesBeforeBackoff:[ADJNonNegativeInt instanceAtOne]
                                      multiplier:milliMultiplier
                                         maxWait:maxWaitMilli];
}

- (nonnull instancetype)initWithMediumWait {
    ADJTimeLengthMilli *_Nonnull milliMultiplier =
    [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
     [[ADJNonNegativeInt alloc] initWithUIntegerValue:
      kMediumSecondsMultiplier * ADJOneSecondMilli]];
    
    ADJTimeLengthMilli *_Nonnull maxWaitMilli =
    [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
     [[ADJNonNegativeInt alloc] initWithUIntegerValue:
      kMediumMaxHourCount * ADJOneHourMilli]];
    
    return [self initWithMinRetriesBeforeBackoff:[ADJNonNegativeInt instanceAtOne]
                                      multiplier:milliMultiplier
                                         maxWait:maxWaitMilli];
}

- (nonnull instancetype)initWithLongWait {
    ADJTimeLengthMilli *_Nonnull milliMultiplier =
    [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
     [[ADJNonNegativeInt alloc] initWithUIntegerValue:
      kLongMinutesMultiplier * ADJOneMinuteMilli]];
    
    ADJTimeLengthMilli *_Nonnull maxWaitMilli =
    [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
     [[ADJNonNegativeInt alloc] initWithUIntegerValue:
      kLongMaxWaitHours * ADJOneHourMilli]];
    
    return [self initWithMinRetriesBeforeBackoff:[ADJNonNegativeInt instanceAtOne]
                                      multiplier:milliMultiplier
                                         maxWait:maxWaitMilli];
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithMinRetriesBeforeBackoff:(nonnull ADJNonNegativeInt *)minRetriesBeforeBackoff
                                             multiplier:(nonnull ADJTimeLengthMilli *)multiplier
                                                maxWait:(nonnull ADJTimeLengthMilli *)maxWait {
    self = [super init];
    
    _minRetriesBeforeBackoff = minRetriesBeforeBackoff;
    _multiplier = multiplier;
    _maxWait = maxWait;
    
    return self;
}

#pragma mark Public API
- (nonnull ADJTimeLengthMilli *)calculateBackoffTimeWithRetries:(nonnull ADJNonNegativeInt *)retries {
    if (retries.uIntegerValue < self.minRetriesBeforeBackoff.uIntegerValue) {
        return [ADJTimeLengthMilli instanceWithoutTimeSpan];
    }
    
    // start with base 0 and increment by 1 for each call
    NSUInteger exponentBase =
    retries.uIntegerValue - self.minRetriesBeforeBackoff.uIntegerValue;
    
    // get the exponential time from the power of 2: 1, 2, 4, 8, 16, ...
    double powerMultipler = powl(2.0, (long) exponentBase);
    
    // calculate exponential time by multiplying the power value * with the multiplier
    NSUInteger exponentialMili =
    self.multiplier.millisecondsSpan.uIntegerValue * (NSUInteger)powerMultipler;
    
    // return max allowed time to wait if calculated exponential time is already larger
    if (exponentialMili > self.maxWait.millisecondsSpan.uIntegerValue) {
        return self.maxWait;
    }
    
    // generate jitter value from 1 to exponentialMili
    unsigned int randomJitterToAdd = arc4random_uniform((unsigned int)exponentialMili) + 1;
    
    NSUInteger waitingTimeWithJitter = exponentialMili + (NSUInteger)randomJitterToAdd;
    
    if (waitingTimeWithJitter > self.maxWait.millisecondsSpan.uIntegerValue) {
        return self.maxWait;
    }
    
    return [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
            [[ADJNonNegativeInt alloc] initWithUIntegerValue:waitingTimeWithJitter]];
}

@end
