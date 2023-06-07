//
//  ADJLogQueueStateAndTracker.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLogQueueStateAndTracker.h"

#import "ADJTallyCounter.h"
#import "ADJConstants.h"

#pragma mark Fields
@interface ADJLogQueueStateAndTracker()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJBackoffStrategy *backoffStrategy;

#pragma mark - Internal variables
@property (nonnull, readwrite, strong, nonatomic) ADJTallyCounter *retriesCounter;
@property (readwrite, assign, nonatomic) BOOL isInDelay;
@property (readwrite, assign, nonatomic) BOOL isSending;
@property (readwrite, assign, nonatomic) BOOL isPaused;

@end

@implementation ADJLogQueueStateAndTracker
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              backoffStrategy:(nonnull ADJBackoffStrategy *)backoffStrategy {
    self = [super initWithLoggerFactory:loggerFactory source:@"LogQueueStateAndTracker"];
    _backoffStrategy = backoffStrategy;

    _retriesCounter = [ADJTallyCounter instanceStartingAtZero];

    _isInDelay = NO;

    _isSending = NO;

    _isPaused = ADJIsSdkPausedWhenStarting;

    return self;
}

#pragma mark Public API
- (BOOL)sendWhenSdkInitWithHasPackageAtFront:(BOOL)hasPackageAtFront {
    return [self sendPackageAtFrontWithHasPackageAtFront:hasPackageAtFront
                             source:@"when sdk init"];
}

- (BOOL)sendWhenLogPackageAddedWithData:(nonnull ADJLogPackageData *)logPackageDataToAdd
                      packageQueueCount:(nonnull ADJNonNegativeInt *)queueSdkPackageCount
                      hasPackageAtFront:(BOOL)hasPackageAtFront
{
    [self.logger debugWithMessage:@"Added package"
                     builderBlock:^(ADJLogBuilder * _Nonnull logBuilder) {
        [logBuilder withKey:@"queue count" value:queueSdkPackageCount.description];
        [logBuilder sdkPackageParams:[logPackageDataToAdd foundationStringMap]];
    }];

    if (queueSdkPackageCount.uIntegerValue == 1) {
        [self.logger debugDev:@"New added package is the one now at the front"];
    }

    return [self sendPackageAtFrontWithHasPackageAtFront:hasPackageAtFront
                                                  source:@"when adding package"];
}

- (BOOL)sendWhenResumeSendingWithHasPackageAtFront:(BOOL)hasPackageAtFront {
    self.isPaused = NO;

    return [self sendPackageAtFrontWithHasPackageAtFront:hasPackageAtFront
                                                  source:@"when resuming sending"];
}

- (void)pauseSending {
    self.isPaused = YES;
}

- (BOOL)sendWhenDelayEndedWithHasPackageAtFront:(BOOL)hasPackageAtFront {
    self.isInDelay = NO;

    return [self sendPackageAtFrontWithHasPackageAtFront:hasPackageAtFront
                                                  source:@"when delay ended"];
}

- (nonnull ADJQueueResponseProcessingData *)
    processReceivedSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponse
{
    // received sdk response implies that is no longer sending
    self.isSending = NO;

    BOOL removePackageAtFront = ! sdkResponse.shouldRetry;

    if (removePackageAtFront) {
        [self.logger debugDev:@"Removing package at front when processing received sdk response"];
    } else {
        [self.logger debugDev:
            @"Not removing package at front when processing received sdk response"];
    }

    ADJDelayData *_Nullable delayData =
    [self delayTrackingWhenReceivedSdkResponseWithData:sdkResponse];

    if (delayData != nil) {
        self.isInDelay = YES;

        [self.logger debugDev:
         @"Delaying try to send next package, when processing received sdk response"
                         from:delayData.source];

    } else {
        [self.logger debugDev:
         @"Not delaying try to send next package when processing received sdk response"];
    }

    return [[ADJQueueResponseProcessingData alloc]
            initWithRemovePackageAtFront:removePackageAtFront
            delayData:delayData];
}

- (BOOL)sendAfterProcessingSdkResponseWithHasPackageAtFront:(BOOL)hasPackageAtFront {
    return [self sendPackageAtFrontWithHasPackageAtFront:hasPackageAtFront
                                                  source:@"after processing sdk response"];
}

- (nonnull ADJNonNegativeInt *)retriesSinceLastSuccessSend {
    return self.retriesCounter.countValue;
}

#pragma mark Internal Methods
- (BOOL)sendPackageAtFrontWithHasPackageAtFront:(BOOL)hasPackageAtFront
                                         source:(nonnull NSString *)source {
    if (hasPackageAtFront) {
        [self.logger debugDev:@"There is at least one package to send"
                         from:source];
    } else {
        [self.logger debugDev:@"There are no more packages to send"
                         from:source];
    }

    if (self.isInDelay) {
        [self.logger debugDev:@"Cannot send package at front because it's in delay"];
        return NO;
    }

    if (self.isSending) {
        [self.logger debugDev:@"Cannot send package at front because it's already sending"];
        return NO;
    }

    if (self.isPaused) {
        [self.logger debugDev:@"Cannot send package at front because it's paused"];
        return NO;
    }

    if (! hasPackageAtFront) {
        [self.logger debugDev:@"Cannot send package at front because it's empty"];
        return NO;
    }

    self.isSending = YES;

    return YES;
}

- (nullable ADJDelayData *)delayTrackingWhenReceivedSdkResponseWithData:
(nonnull id<ADJSdkResponseData>)sdkResponse {
    if (sdkResponse.shouldRetry) {
        return [self delayTrackingWhenRetryingWithSdkResponseData:sdkResponse];
    }

    // reset the number of retries from the sdk side
    self.retriesCounter = [ADJTallyCounter instanceStartingAtZero];

    if (sdkResponse.continueIn != nil) {
        return [[ADJDelayData alloc] initWithDelay:sdkResponse.continueIn
                                            source:@"continue in"];
    }

    return nil;
}

- (nonnull ADJDelayData *)delayTrackingWhenRetryingWithSdkResponseData:(nonnull id<ADJSdkResponseData>)sdkResponse {
    if (sdkResponse.retryIn != nil) {
        return [[ADJDelayData alloc] initWithDelay:sdkResponse.retryIn
                                            source:@"retry in"];
    }

    // increase the number of retries from the sdk side
    self.retriesCounter = [self.retriesCounter generateIncrementedCounter];

    ADJTimeLengthMilli *_Nonnull backoffDelay =
    [self.backoffStrategy calculateBackoffTimeWithRetries:self.retriesCounter.countValue];

    return [[ADJDelayData alloc] initWithDelay:backoffDelay
                                        source:@"backoff"];
}

@end

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (readonly, assign, nonatomic) BOOL removePackageAtFront;
 @property (nonnull, readonly, strong, nonatomic) ADJDelayData *delayData;
 */

@implementation ADJQueueResponseProcessingData
#pragma mark Instantiation
- (nonnull instancetype)initWithRemovePackageAtFront:(BOOL)removePackageAtFront
                                           delayData:(nonnull ADJDelayData *)delayData {
    self = [super init];

    _removePackageAtFront = removePackageAtFront;
    _delayData = delayData;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

