//
//  ADJAttributionTracker.m
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAttributionTracker.h"

#import "ADJConstants.h"
#import "ADJConstantsParam.h"
#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJTallyCounter *retriesSinceLastSuccessSend;
 */

@interface ADJAttributionTracker ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJBackoffStrategy *backoffStrategy;

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL isInDelay;
@property (readwrite, assign, nonatomic) BOOL isSending;
@property (readwrite, assign, nonatomic) BOOL isSdkPaused;
@property (readwrite, assign, nonatomic) BOOL askedToSend;
@property (nonnull, readwrite, strong, nonatomic) ADJTallyCounter *retriesSinceLastSuccessSend;

@end

@implementation ADJAttributionTracker
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    attributionBackoffStrategy:(nonnull ADJBackoffStrategy *)attributionBackoffStrategy
    startsAsking:(BOOL)startsAsking
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"AttributionTracker"];
    _backoffStrategy = attributionBackoffStrategy;

    _isInDelay = NO;

    _isSending = NO;

    _isSdkPaused = ADJIsSdkPausedWhenStarting;

    _askedToSend = startsAsking;

    _retriesSinceLastSuccessSend = [ADJTallyCounter instanceStartingAtZero];

    return self;
}

#pragma mark Public API
- (BOOL)sendWhenStartAsking {
    self.askedToSend = YES;

    return [self tryToSend];
}

- (BOOL)sendWhenSdkResumingSending {
    self.isSdkPaused = NO;

    return [self tryToSend];
}

- (void)pauseSending {
    self.isSdkPaused = YES;
}

- (BOOL)sendWhenDelayEnded {
    self.isInDelay = NO;

    return [self tryToSend];
}

- (nullable ADJDelayData *)
    delaySendingWhenReceivedAttributionResponseWithData:
        (nonnull ADJAttributionResponseData *)attributionResponse
{
    if (! self.isSending || ! self.askedToSend) {
        [self.logger debugDev:@"Should have been sending and asked when receiving response"
                    issueType:ADJIssueUnexpectedInput];
    }

    // received attribution response implies that is no longer sending
    self.isSending = NO;
    
    if (attributionResponse.shouldRetry) {
        // Unlike other 'Tracker' classes it won't be in delay here
        //  since, it could be in delay from the state due to ask_in
        // Instead, just returned the expected delay to retry and check later at
        //  tryToDelay: if it can use that delay
        [self.logger debugDev:@"Retry with delay because of not accepted attribution response"];
        return [self delayDataWithRetryIn:attributionResponse.retryIn];
    }
    
    [self.logger debugDev:@"Not retrying because of accepted attribution response"];
    
    self.askedToSend = NO;

    self.retriesSinceLastSuccessSend = [ADJTallyCounter instanceStartingAtZero];

    return nil;
}

// reason to delay
//  - request should retry
//  - state detected ask_in
- (BOOL)tryToDelay {
    if (self.isInDelay) {
        [self.logger debugDev:@"Cannot delay when it's already in delay"];
        return NO;
    }

    if (self.isSending) {
        [self.logger debugDev:@"Cannot delay when it's already sending"];
        return NO;
    }

    self.isInDelay = YES;

    return YES;
}

#pragma mark Internal Methods
- (BOOL)tryToSend {
    if (self.isInDelay) {
        [self.logger debugDev:@"Cannot send attribution because it's in delay"];
        return NO;
    }

    if (self.isSending) {
        [self.logger debugDev:@"Cannot send attribution because it's already sending"];
        return NO;
    }

    if (! self.askedToSend) {
        [self.logger debugDev:@"Cannot send attribution because it was not asked to send"];
        return NO;
    }

    if (self.isSdkPaused) {
        [self.logger debugDev:@"Cannot send attribution because the sdk is paused"];
        return NO;
    }

    self.isSending = YES;

    return YES;
}

- (nullable ADJDelayData *)delayDataWithRetryIn:(nullable ADJTimeLengthMilli *)retryIn {
    // when retry_in is present, use it without backoff calculations
    if (retryIn != nil) {
        return [[ADJDelayData alloc] initWithDelay:retryIn from:@"retry_in"];
    }

    // increase the number of retries for backoff calculation
    self.retriesSinceLastSuccessSend =
        [self.retriesSinceLastSuccessSend generateIncrementedCounter];

    ADJTimeLengthMilli *_Nonnull backoffTime =
        [self.backoffStrategy
         calculateBackoffTimeWithRetries:self.retriesSinceLastSuccessSend.countValue];

    return [[ADJDelayData alloc] initWithDelay:backoffTime from:@"backoff"];
}

@end
