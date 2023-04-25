//
//  ADJMainQueueStateAndTracker.m
//  Adjust
//
//  Created by Pedro S. on 03.03.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJMainQueueStateAndTracker.h"

#import "ADJTallyCounter.h"
#import "ADJConstants.h"

#pragma mark Fields
@interface ADJMainQueueStateAndTracker()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJBackoffStrategy *backoffStrategy;

#pragma mark - Internal variables
@property (nonnull, readwrite, strong, nonatomic) ADJTallyCounter *retriesCounter;
@property (readwrite, assign, nonatomic) BOOL isInDelay;
@property (readwrite, assign, nonatomic) BOOL isSending;
@property (readwrite, assign, nonatomic) BOOL isPaused;

@end

@implementation ADJMainQueueStateAndTracker
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    backoffStrategy:(nonnull ADJBackoffStrategy *)backoffStrategy
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"MainQueueStateAndTracker"];
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
                                                  from:@"when sdk init"];
}

- (BOOL)sendWhenPackageAddedWithPackage:(nonnull id<ADJSdkPackageData>)sdkPackageAdded
               mainQueueSdkPackageCount:(nonnull ADJNonNegativeInt *)mainQueueSdkPackageCount
                      hasPackageAtFront:(BOOL)hasPackageAtFront
{
    [self.logger debugWithMessage:@"Added package"
                     builderBlock:^(ADJLogBuilder * _Nonnull logBuilder) {
        [logBuilder withKey:@"queue count" stringValue:mainQueueSdkPackageCount.description];
        [logBuilder sdkPackageParams:[sdkPackageAdded foundationStringMap]];
    }];

    if (mainQueueSdkPackageCount.uIntegerValue == 1) {
        [self.logger debugDev:@"New added package is the one now at the front"];
    }

    return [self sendPackageAtFrontWithHasPackageAtFront:hasPackageAtFront
                                                  from:@"when adding package"];
}

- (BOOL)sendWhenResumeSendingWithHasPackageAtFront:(BOOL)hasPackageAtFront {
    self.isPaused = NO;

    return [self sendPackageAtFrontWithHasPackageAtFront:hasPackageAtFront
                                                  from:@"when resuming sending"];
}

- (void)pauseSending {
    self.isPaused = YES;
}

- (BOOL)sendWhenDelayEndedWithHasPackageAtFront:(BOOL)hasPackageAtFront {
    self.isInDelay = NO;

    return [self sendPackageAtFrontWithHasPackageAtFront:hasPackageAtFront
                                                  from:@"when delay ended"];
}

- (nonnull ADJMainQueueResponseProcessingData *) processReceivedSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponse {
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
                         from:delayData.from];
    } else {
        [self.logger debugDev:
         @"Not delaying try to send next package when processing received sdk response"];
    }

    return [[ADJMainQueueResponseProcessingData alloc]
                initWithRemovePackageAtFront:removePackageAtFront
                delayData:delayData];
}

- (BOOL)sendAfterProcessingSdkResponseWithHasPackageAtFront:(BOOL)hasPackageAtFront {
    return [self sendPackageAtFrontWithHasPackageAtFront:hasPackageAtFront
                                                    from:@"after processing sdk response"];
}

- (nonnull ADJNonNegativeInt *)retriesSinceLastSuccessSend {
    return self.retriesCounter.countValue;
}

#pragma mark Internal Methods
- (BOOL)sendPackageAtFrontWithHasPackageAtFront:(BOOL)hasPackageAtFront
                                           from:(nonnull NSString *)from
{
    if (! hasPackageAtFront) {
        [self.logger debugDev:@"There are no more packages to send"
                         from: from];
        return NO;
    }
    
    [self.logger debugDev:@"There is at least one package to send"
                     from:from];

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

    self.isSending = YES;

    return YES;
}

- (nullable ADJDelayData *)delayTrackingWhenReceivedSdkResponseWithData:
    (nonnull id<ADJSdkResponseData>)sdkResponse
{
    if (sdkResponse.shouldRetry) {
        return [self delayTrackingWhenRetryingWithSdkResponseData:sdkResponse];
    }

    // reset the number of retries from the sdk side
    self.retriesCounter = [ADJTallyCounter instanceStartingAtZero];

    if (sdkResponse.continueIn != nil) {
        return [[ADJDelayData alloc] initWithDelay:sdkResponse.continueIn
                                              from:@"continue in"];
    }

    return nil;
}

- (nonnull ADJDelayData *)delayTrackingWhenRetryingWithSdkResponseData:
    (nonnull id<ADJSdkResponseData>)sdkResponse
{
    if (sdkResponse.retryIn != nil) {
        return [[ADJDelayData alloc] initWithDelay:sdkResponse.retryIn
                                              from:@"retry in"];
    }

    // increase the number of retries from the sdk side
    self.retriesCounter = [self.retriesCounter generateIncrementedCounter];

    ADJTimeLengthMilli *_Nonnull backoffDelay =
        [self.backoffStrategy calculateBackoffTimeWithRetries:self.retriesCounter.countValue];

    return [[ADJDelayData alloc] initWithDelay:backoffDelay
                                          from:@"backoff"];
}

@end

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (readonly, assign, nonatomic) BOOL removePackageAtFront;
 @property (nonnull, readonly, strong, nonatomic) ADJDelayData *delayData;
 */

@implementation ADJMainQueueResponseProcessingData
#pragma mark Instantiation
- (nonnull instancetype)initWithRemovePackageAtFront:(BOOL)removePackageAtFront
                                           delayData:(nonnull ADJDelayData *)delayData
{
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
