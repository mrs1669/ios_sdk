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
@property (readwrite, assign, nonatomic) BOOL isPaused;
@property (readwrite, assign, nonatomic) BOOL askedToSend;
@property (nonnull, readwrite, strong, nonatomic) ADJTallyCounter *retriesSinceLastSuccessSend;

@end

@implementation ADJGdprForgetTracker
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    gdprForgetBackoffStrategy:(nonnull ADJBackoffStrategy *)gdprForgetBackoffStrategy
    startsAsking:(BOOL)startsAsking
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"GdprForgetTracker"];
    _gdprForgetBackoffStrategy = gdprForgetBackoffStrategy;

    _isInDelay = NO;

    _isSending = NO;

    _isPaused = ADJIsSdkPausedWhenStarting;

    _askedToSend = startsAsking;

    _retriesSinceLastSuccessSend = [ADJTallyCounter instanceStartingAtZero];

    return self;
}

#pragma mark Public API
- (BOOL)sendWhenStartTracking {
    self.askedToSend = YES;

    return [self tryToSend];
}

- (BOOL)resumeSendingWhenAppWentToForeground {
    self.isPaused = NO;

    return [self tryToSend];
}

- (void)pauseSendingWhenAppWentToBackground {
    self.isPaused = YES;
}

- (BOOL)sendWhenDelayEnded {
    self.isInDelay = NO;

    return [self tryToSend];
}

- (nullable ADJDelayData *)
    delayTrackingWhenReceivedGdprForgetResponseWithData:
        (nonnull ADJGdprForgetResponseData *)gdprForgetResponse
{
    if (! self.isSending || ! self.askedToSend) {
        [self.logger debugDev:@"Should have been sending and asked when receiving response"
                    issueType:ADJIssueUnexpectedInput];
    }

    // received gdpr forget response implies that is no longer sending
    self.isSending = NO;

    if (gdprForgetResponse.shouldRetry) {
        self.isInDelay = YES;

        return [self delayWithRetryIn:gdprForgetResponse.retryIn];
    }

    self.retriesSinceLastSuccessSend = [ADJTallyCounter instanceStartingAtZero];

    self.askedToSend = NO;

    // no delay to retry
    return nil;
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

    if (! self.askedToSend) {
        [self.logger debugDev:@"Cannot track GDPR forget because it was not asked to send"];
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
        return [[ADJDelayData alloc] initWithDelay:retryIn from:@"retry_in"];
    }

    self.retriesSinceLastSuccessSend =
        [self.retriesSinceLastSuccessSend generateIncrementedCounter];

    ADJTimeLengthMilli *_Nonnull backoffDelay =
        [self.gdprForgetBackoffStrategy
         calculateBackoffTimeWithRetries:self.retriesSinceLastSuccessSend.countValue];

    return [[ADJDelayData alloc] initWithDelay:backoffDelay from:@"backoff"];
}

@end
