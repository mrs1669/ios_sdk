//
//  ADJSdkConfigDataBuilder.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkConfigDataBuilder.h"

#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readwrite, strong, nonatomic) ADJNetworkEndpointData *networkEndpointData;
 @property (nonnull, readwrite, strong, nonatomic) ADJExternalConfigData *sessionDeviceIdsConfigData;
 @property (nonnull, readwrite, strong, nonatomic) ADJExternalConfigData *asaAttributionConfigData;
 @property (nonnull, readwrite, strong, nonatomic) ADJBackoffStrategy *attributionBackoffStrategy;
 @property (nonnull, readwrite, strong, nonatomic) ADJBackoffStrategy *gdprForgetBackoffStrategy;
 @property (nonnull, readwrite, strong, nonatomic) ADJBackoffStrategy *mainQueueBackoffStrategy;
 @property (nonnull, readwrite, strong, nonatomic) ADJTimeLengthMilli *minMeasurementSessionIntervalMilli;
 @property (nullable, readwrite, strong, nonatomic) ADJTimeLengthMilli *overwriteFirstMeasurementSessionIntervalMilli;
 @property (nonnull, readwrite, strong, nonatomic) ADJTimeLengthMilli *foregroundTimerStartMilli;
 @property (nonnull, readwrite, strong, nonatomic) ADJTimeLengthMilli *foregroundTimerIntervalMilli;
 @property (readwrite, assign, nonatomic) BOOL assumeSandboxEnvironmentForLogging;
 @property (readwrite, assign, nonatomic) BOOL assumeTraceLogLevel;
 @property (readwrite, assign, nonatomic) BOOL doNotReadCurrentLifecycleStatus;
 @property (readwrite, assign, nonatomic) BOOL doNotInitiateAttributionFromSdk;
 */

@implementation ADJSdkConfigDataBuilder
#pragma mark Instantiation
- (nonnull instancetype)initWithDefaultValues {
    self = [super init];

    _networkEndpointData = [[ADJNetworkEndpointData alloc]
                            initWithExtraPath:nil
                            urlOverwrite:nil
                            timeoutMilli:[[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
                                          [[ADJNonNegativeInt alloc] initWithUIntegerValue:ADJOneMinuteMilli]]];

    ADJTimeLengthMilli *_Nonnull twoSecondsLength = [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
                                                     [[ADJNonNegativeInt alloc] initWithUIntegerValue:ADJOneSecondMilli * 2]];

    _sessionDeviceIdsConfigData = [[ADJExternalConfigData alloc]
                                   initWithTimeoutPerAttempt:twoSecondsLength
                                   libraryMaxReadAttempts:nil
                                   delayBetweenAttempts:nil
                                   cacheValidityPeriod:nil];

    ADJTimeLengthMilli *_Nonnull oneSecondLength = [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
                                                    [[ADJNonNegativeInt alloc] initWithUIntegerValue:ADJOneSecondMilli]];
    ADJTimeLengthMilli *_Nonnull fiveSecondsLength = [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
                                                      [[ADJNonNegativeInt alloc] initWithUIntegerValue:ADJOneSecondMilli * 5]];

    ADJTimeLengthMilli *_Nonnull oneMinuteLength = [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
                                                    [[ADJNonNegativeInt alloc] initWithUIntegerValue:ADJOneMinuteMilli]];

    _asaAttributionConfigData = [[ADJExternalConfigData alloc]
                                 initWithTimeoutPerAttempt:oneSecondLength
                                 libraryMaxReadAttempts:[[ADJNonNegativeInt alloc] initWithUIntegerValue:2]
                                 delayBetweenAttempts:fiveSecondsLength
                                 cacheValidityPeriod:nil];

    _attributionBackoffStrategy = [[ADJBackoffStrategy alloc] initWithMediumWait];

    _gdprForgetBackoffStrategy = [[ADJBackoffStrategy alloc] initWithShortWait];

    _mainQueueBackoffStrategy = [[ADJBackoffStrategy alloc] initWithLongWait];

    _clientReturnExecutorOverwrite = nil;

    ADJTimeLengthMilli *_Nonnull thirtyMinutesLength = [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
                                                        [[ADJNonNegativeInt alloc] initWithUIntegerValue:ADJThirtyMinutesMilli]];

    _minMeasurementSessionIntervalMilli = thirtyMinutesLength;
    _overwriteFirstSdkSessionInterval = nil;

    _foregroundTimerStartMilli = oneMinuteLength;

    _foregroundTimerIntervalMilli = oneMinuteLength;

    _assumeSandboxEnvironmentForLogging = NO;

    _assumeTraceLogLevel = NO;

    _doNotReadCurrentLifecycleStatus = NO;

    _doNotInitiateAttributionFromSdk = NO;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end




