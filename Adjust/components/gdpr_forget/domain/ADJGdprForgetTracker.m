//
//  ADJGdprForgetTracker.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGdprForgetTracker.h"

#import "ADJConstants.h"

#pragma mark Fields
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJTallyCounter *retriesSinceLastSuccessSend;
 */

@interface ADJGdprForgetTracker ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJBackoffStrategy *gdprForgetBackoffStrategy;

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL isInDelay;
@property (readwrite, assign, nonatomic) BOOL isSending;
@property (readwrite, assign, nonatomic) BOOL isStopped;
@property (readwrite, assign, nonatomic) BOOL isPaused;
@property (nonnull, readwrite, strong, nonatomic) ADJTallyCounter *retriesSinceLastSuccessSend;

@end

@implementation ADJGdprForgetTracker
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    gdprForgetBackoffStrategy:(nonnull ADJBackoffStrategy *)gdprForgetBackoffStrategy
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"GdprForgetTracker"];
    _gdprForgetBackoffStrategy = gdprForgetBackoffStrategy;

    _isInDelay = NO;

    _isSending = NO;

    _isStopped = YES;

    _isPaused = ADJIsSdkPausedWhenStarting;

    _retriesSinceLastSuccessSend = [ADJTallyCounter instanceStartingAtZero];

    return self;
}

#pragma mark Public API
- (BOOL)sendWhenStartTracking {
    self.isStopped = NO;

    return [self tryToSend];
}

- (void)stopTracking {
    self.isStopped = YES;
}

- (BOOL)sendWhenAppWentToForeground {
    self.isPaused = NO;

    return [self tryToSend];
}

- (void)pauseTrackingWhenAppWentToBackground {
    self.isPaused = YES;
}

- (BOOL)sendWhenDelayEnded {
    self.isInDelay = NO;

    return [self tryToSend];
}

- (nullable ADJDelayData *)delayTrackingWhenReceivedGdprForgetResponseWithData:(nonnull ADJGdprForgetResponseData *)gdprForgetResponse {
    // received gdpr forget response implies that is no longer sending
    self.isSending = NO;

    if (gdprForgetResponse.shouldRetry) {
        self.isInDelay = YES;

        return [self delayWithRetryIn:gdprForgetResponse.retryIn];
    } else {
        self.retriesSinceLastSuccessSend = [ADJTallyCounter instanceStartingAtZero];

        // no delay to retry
        return nil;
    }
}

#pragma mark Internal Methods
- (BOOL)tryToSend {
    if (self.isInDelay) {
        [self.logger debugDev:@"Cannot track GDPR forget because it's in delay"];
        return NO;
    }

    if (self.isSending) {
        [self.logger debugDev:@"Cannot track GDPR forget because it's already sending"];
        return NO;
    }

    if (self.isStopped) {
        [self.logger debugDev:@"Cannot track GDPR forget because it's stopped"];
        return NO;
    }

    if (self.isPaused) {
        [self.logger debugDev:@"Cannot track GDPR forget because it's paused"];
        return NO;
    }

    self.isSending = YES;

    return self.isSending;
}

- (nonnull ADJDelayData *)delayWithRetryIn:(nullable ADJTimeLengthMilli *)retryIn {
    if (retryIn != nil) {
        return [[ADJDelayData alloc] initWithDelay:retryIn
                                              from:@"retry_in"];
    }

    self.retriesSinceLastSuccessSend =
    [self.retriesSinceLastSuccessSend generateIncrementedCounter];

    ADJTimeLengthMilli *_Nonnull backoffDelay =
    [self.gdprForgetBackoffStrategy
     calculateBackoffTimeWithRetries:self.retriesSinceLastSuccessSend.countValue];

    return [[ADJDelayData alloc] initWithDelay:backoffDelay
                                          from:@"backoff"];
}

@end

