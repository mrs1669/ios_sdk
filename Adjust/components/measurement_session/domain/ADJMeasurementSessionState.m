//
//  ADJMeasurementSessionState.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMeasurementSessionState.h"

#import "ADJConstants.h"
#import "ADJMeasurementSessionDataBuilder.h"

#pragma mark Fields
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJMeasurementSessionStateData *changedStateData;
 @property (nullable, readonly, strong, nonatomic) ADJPackageSessionData *packageSessionData;
 */
@implementation ADJMeasurementSessionStateOutputData
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma mark - Private constructors
- (nonnull instancetype)
    initWithChangedStateData:(nullable ADJMeasurementSessionStateData *)changedStateData
    packageSessionData:(nullable ADJPackageSessionData *)packageSessionData
{
    self = [super init];
    _changedStateData = changedStateData;
    _packageSessionData = packageSessionData;

    return self;
}
@end

#pragma mark - Private constants
static NSString *const kPreSdkStartStatus = @"PreSdkStart";
static NSString *const kActiveSessionStatus = @"ActiveSession";
static NSString *const kPausedSessionStatus = @"PausedSession";

@interface ADJMeasurementSessionState ()
#pragma mark - Injected dependencies
@property (nonnull, readwrite, strong, nonatomic) ADJMeasurementSessionStateData *stateData;
@property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *minMeasurementSessionInterval;
@property (nullable, readwrite, strong, nonatomic)
    ADJTimeLengthMilli *overwriteFirstSdkSessionInterval;

#pragma mark - Internal variables
@property (nonnull, readwrite, strong, nonatomic) NSString *measurementSessionStatus;

@end

@implementation ADJMeasurementSessionState
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    initialMeasurementSessionStateData:
        (nonnull ADJMeasurementSessionStateData *)initialMeasurementSessionStateData
    overwriteFirstSdkSessionInterval:
        (nullable ADJTimeLengthMilli *)overwriteFirstSdkSessionInterval
    minMeasurementSessionInterval:
        (nonnull ADJTimeLengthMilli *)minMeasurementSessionInterval
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"MeasurementSessionState"];
    _stateData = initialMeasurementSessionStateData;
    _minMeasurementSessionInterval = minMeasurementSessionInterval;
    _overwriteFirstSdkSessionInterval = overwriteFirstSdkSessionInterval;

    _measurementSessionStatus = kPreSdkStartStatus;

    return self;
}

#pragma mark Public API
- (nullable ADJMeasurementSessionStateOutputData *)sdkStartWithNonMonotonicNowTimestamp:
    (nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp
{
    if (self.measurementSessionStatus != kPreSdkStartStatus) {
        [self.logger debugDev:@"Not in the expected status at sdk start"
                expectedValue:kPreSdkStartStatus
                  actualValue:self.measurementSessionStatus
                    issueType:ADJIssueUnexpectedInput];
        return nil;
    }

    return [self changeToActiveSessionWithExternalNonMonotonicNowTimestamp:nonMonotonicNowTimestamp
                                                            from:@"sdk start"];
}

- (nullable ADJMeasurementSessionStateOutputData *)resumeMeasurementWithNowTimestamp:
    (nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp
{
    if (self.measurementSessionStatus != kActiveSessionStatus) {
        [self.logger debugDev:@"Not in the expected status at resume measurement"
                expectedValue:kActiveSessionStatus
                  actualValue:self.measurementSessionStatus
                    issueType:ADJIssueUnexpectedInput];
        return nil;
    }

    return [self changeToActiveSessionWithExternalNonMonotonicNowTimestamp:nonMonotonicNowTimestamp
                                                                    from:@"resume measurement"];
}

- (nullable ADJMeasurementSessionStateOutputData *)pauseMeasurementWithNowTimestamp:
    (nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp
{
    if (self.measurementSessionStatus != kPausedSessionStatus) {
        [self.logger debugDev:@"Not in the expected status at pause measurement"
                expectedValue:kPausedSessionStatus
                  actualValue:self.measurementSessionStatus
                    issueType:ADJIssueUnexpectedInput];
        return nil;
    }

    return [self changeToPauseSessionWithNonMonotonicNowTimestamp:nonMonotonicNowTimestamp
                                                           from:@"pause measurement"];
}

- (nullable ADJMeasurementSessionStateOutputData *)keepAlivePingWithNonMonotonicNowTimestamp:
    (nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp
{
    return
        [self updateIntevalsInActiveSessionWithNonMonotonicNowTimestamp:nonMonotonicNowTimestamp
                                                                 from:@"keep alive ping"];
}

#pragma mark Internal Methods
- (nullable ADJMeasurementSessionStateOutputData *)
    changeToActiveSessionWithExternalNonMonotonicNowTimestamp:
        (nonnull ADJTimestampMilli *)externalNonMonotonicNowTimestamp
    from:(nonnull NSString *)from
{
    [self.logger debugDev:@"Changing to ActiveState"
                     from:from
                      key:@"status"
                    value:self.measurementSessionStatus];

    ADJTimestampMilli *_Nonnull nonMonotonicNowTimestamp =
        [self overwriteNowTimestampOnFirstSdkSession:externalNonMonotonicNowTimestamp];

    ADJMeasurementSessionDataBuilder *_Nonnull sessionDataBuilder;
    ADJPackageSessionData *_Nullable packageSessionData = nil;
    if (self.stateData.measurementSessionData == nil) {
        sessionDataBuilder = [[ADJMeasurementSessionDataBuilder alloc]
                              initWithPreFirstSessionData];

        packageSessionData =
            [self processFirstSessionWithPreFirstSessionDataBuilder:sessionDataBuilder
                                           nonMonotonicNowTimestamp:nonMonotonicNowTimestamp];
    } else {
        sessionDataBuilder =
            [self.stateData.measurementSessionData toMeasurementSessionDataBuilder];

        packageSessionData = [self processNonFirstSessionWithBuilder:sessionDataBuilder
                                            nonMonotonicNowTimestamp:nonMonotonicNowTimestamp];
    }

    ADJResult<ADJMeasurementSessionData *> *_Nonnull newMeasurementSessionDataResult =
        [ADJMeasurementSessionData instanceFromBuilder:sessionDataBuilder];
    if (newMeasurementSessionDataResult.fail != nil) {
        [self.logger debugDev:@"Cannot change to Active Session with invalid measurement session"
                   resultFail:newMeasurementSessionDataResult.fail
                    issueType:ADJIssueLogicError];
        return nil;
    }

    self.stateData = [[ADJMeasurementSessionStateData alloc]
                      initWithMeasurementSessionData:newMeasurementSessionDataResult.value];

    // changing at the end of the method to support NOT_NEW_SESSION_EVENT check
    //  ^- not needed anymore, but still fine to keep it here
    self.measurementSessionStatus = kActiveSessionStatus;

    return [[ADJMeasurementSessionStateOutputData alloc]
            initWithChangedStateData:self.stateData
            packageSessionData:packageSessionData];
}
- (nonnull ADJPackageSessionData *)
    processFirstSessionWithPreFirstSessionDataBuilder:
        (nonnull ADJMeasurementSessionDataBuilder *)preFirstSessionDataBuilder
    nonMonotonicNowTimestamp:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp
{
    ADJPackageSessionData *_Nonnull packageSessionData =
        [self processNewSessionWithBuilder:preFirstSessionDataBuilder];

    [preFirstSessionDataBuilder setLastActivityTimestampMilli:nonMonotonicNowTimestamp];

    return packageSessionData;
}

- (nullable ADJPackageSessionData *)
    processNonFirstSessionWithBuilder:(nonnull ADJMeasurementSessionDataBuilder *)builder
    nonMonotonicNowTimestamp:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp
{
    ADJTimestampMilli *_Nonnull currentLastActivityTimestamp =
        self.stateData.measurementSessionData.lastActivityTimestampMilli;

    ADJTimeLengthMilli *_Nonnull intervalSinceLastActivity =
        [currentLastActivityTimestamp
         timeLengthDifferenceWithNonMonotonicNowTimestamp:nonMonotonicNowTimestamp];

    ADJPackageSessionData *_Nullable packageSessionData = nil;

    if (intervalSinceLastActivity.millisecondsSpan.uIntegerValue
            >= self.minMeasurementSessionInterval.millisecondsSpan.uIntegerValue)
    {
        [self.logger debugDev:
         @"Create a new session, because there was enough interval since the last activity"
                         key1:@"intervalSinceLastActivity"
                       value1:intervalSinceLastActivity.description
                         key2:@"minMeasurementSessionInterval"
                       value2:self.minMeasurementSessionInterval.description];

        packageSessionData =
            [self processNewSessionWithBuilder:builder];
    } else {
        [self.logger debugDev:@"Will not create a new session,"
         " because there was not enough interval since the last activity"
                         key1:@"intervalSinceLastActivity"
                       value1:intervalSinceLastActivity.description
                         key2:@"minMeasurementSessionInterval"
                       value2:self.minMeasurementSessionInterval.description];

        [self increaseSessionLengthWithBuilder:builder
                     intervalSinceLastActivity:intervalSinceLastActivity];
    }

    // add time length instead of "= nowTimestamp"
    //  because of non monotonic clock
    [builder setLastActivityTimestampMilli:
     [currentLastActivityTimestamp generateTimestampWithAddedTimeLength:
      intervalSinceLastActivity]];

    return packageSessionData;
}

- (nonnull ADJPackageSessionData *)processNewSessionWithBuilder:
    (nonnull ADJMeasurementSessionDataBuilder *)builder
{
    [builder incrementSessionCountWithLogger:self.logger];

    // build session package with the incremented session count,
    //  but before resetting the intervals from the previous sessions
    //  which are read for the new session package
    ADJPackageSessionData *_Nonnull packageSessionData =
        [[ADJPackageSessionData alloc] initWithBuilder:builder];

    // reset session intervals after session package has been created
    [builder resetSessionIntervals];

    return packageSessionData;
}

- (nonnull ADJTimestampMilli *)overwriteNowTimestampOnFirstSdkSession:
    (nonnull ADJTimestampMilli *)externalNonMonotonicNowTimestamp
{
    if (self.overwriteFirstSdkSessionInterval == nil) {
        return externalNonMonotonicNowTimestamp;
    }

    [self.logger debugDev:@"Trying to overwrite First Sdk Session Interval"
                      key:@"overwriteFirstSdkSessionInterval"
                    value:self.overwriteFirstSdkSessionInterval.description];

    // no matter what, the overwrite value should be cleared after the first possible use
    ADJTimeLengthMilli *_Nonnull firstSdkSessionInterval = self.overwriteFirstSdkSessionInterval;
    self.overwriteFirstSdkSessionInterval = nil;

    if (self.stateData.measurementSessionData == nil) {
        [self.logger debugDev:
         @"Cannot overwrite First Sdk Session Inteval before first session start"];
        return externalNonMonotonicNowTimestamp;
    }

    ADJTimestampMilli *_Nonnull overwrittenNowTimestamp =
        [self.stateData.measurementSessionData.lastActivityTimestampMilli
         generateTimestampWithAddedTimeLength:firstSdkSessionInterval];

    [self.logger debugWithMessage:@"Now timestamp overwritten"
                     builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
     {
        [logBuilder withKey:@"externalNonMonotonicNowTimestamp"
                      value:externalNonMonotonicNowTimestamp.description];
        [logBuilder withKey:@"overwrittenNowTimestamp" value:overwrittenNowTimestamp.description];
        [logBuilder withKey:@"lastActivityTimestamp"
                      value:
         self.stateData.measurementSessionData.lastActivityTimestampMilli.description];
    }];

    return overwrittenNowTimestamp;
}

- (nullable ADJMeasurementSessionStateOutputData *)
    changeToPauseSessionWithNonMonotonicNowTimestamp:
        (nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp
    from:(nonnull NSString *)from
{
    ADJMeasurementSessionStateOutputData *_Nullable outputData =
        [self updateIntevalsInActiveSessionWithNonMonotonicNowTimestamp:nonMonotonicNowTimestamp
                                                                 from:from];
    if (outputData == nil) { return nil; }

    [self.logger debugDev:@"Changing to pause session from active"
                     from:from];

    self.measurementSessionStatus = kPausedSessionStatus;

    return outputData;
}

- (nullable ADJMeasurementSessionStateOutputData *)
    updateIntevalsInActiveSessionWithNonMonotonicNowTimestamp:
        (nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp
    from:(nonnull NSString *)from
{
    if (self.measurementSessionStatus != kActiveSessionStatus) {
        [self.logger debugDev:@"Cannot update intervals in non-active session"
                         from:from
                          key:@"status"
                        value:self.measurementSessionStatus];
        return nil;
    }

    if (self.stateData.measurementSessionData == nil) {
        [self.logger debugDev:
         @"There should be a valid measurementSessionData when the status is active"
                    issueType:ADJIssueLogicError];
        return nil;
    }

    ADJMeasurementSessionDataBuilder *_Nonnull measurementSessionDataBuilder =
        [self.stateData.measurementSessionData toMeasurementSessionDataBuilder];

    ADJTimestampMilli *_Nonnull currentLastActivityTimestamp =
        self.stateData.measurementSessionData.lastActivityTimestampMilli;

    ADJTimeLengthMilli *_Nonnull intervalSinceLastActivity =
        [currentLastActivityTimestamp
         timeLengthDifferenceWithNonMonotonicNowTimestamp:nonMonotonicNowTimestamp];

    // add time length instead of "= nowTimestampMilli"
    //  because of non monotonic clock
    [measurementSessionDataBuilder setLastActivityTimestampMilli:
     [currentLastActivityTimestamp generateTimestampWithAddedTimeLength:
      intervalSinceLastActivity]];

    [self increaseSessionLengthWithBuilder:measurementSessionDataBuilder
                 intervalSinceLastActivity:intervalSinceLastActivity];

    [self increaseTimeSpentWithBuilder:measurementSessionDataBuilder
             intervalSinceLastActivity:intervalSinceLastActivity];

    ADJResult<ADJMeasurementSessionData *> *_Nonnull newMeasurementSessionDataResult =
        [ADJMeasurementSessionData instanceFromBuilder:measurementSessionDataBuilder];

    if (newMeasurementSessionDataResult.fail != nil) {
        [self.logger debugDev:
        @"Cannot update intervals in active session with invalid sdk session"
                   resultFail:newMeasurementSessionDataResult.fail
                    issueType:ADJIssueLogicError];
        return nil;
    }

    self.stateData = [[ADJMeasurementSessionStateData alloc]
                      initWithMeasurementSessionData:newMeasurementSessionDataResult.value];

    return [[ADJMeasurementSessionStateOutputData alloc]
            initWithChangedStateData:self.stateData
            packageSessionData:nil];
}

- (void)
    increaseSessionLengthWithBuilder:(nonnull ADJMeasurementSessionDataBuilder *)builder
    intervalSinceLastActivity:(nonnull ADJTimeLengthMilli *)intervalSinceLastActivity
{
    ADJTimeLengthMilli *_Nullable currentSessionLength = builder.sessionLengthMilli;
    if (currentSessionLength == nil) {
        [self.logger debugDev:@"Cannot increase session length without any value"
                    issueType:ADJIssueLogicError];
        return;
    }

    ADJTimeLengthMilli *_Nonnull newSessionLength =
        [currentSessionLength generateTimeLengthWithAddedTimeLength: intervalSinceLastActivity];

    [builder setSessionLengthMilli:newSessionLength];

    [self.logger debugDev:@"Session length increased"
                     key1:@"interval"
                   value1:intervalSinceLastActivity.description
                     key2:@"session lenght"
                   value2:builder.sessionLengthMilli.description];
}

- (void)
    increaseTimeSpentWithBuilder:(nonnull ADJMeasurementSessionDataBuilder *)builder
    intervalSinceLastActivity:(nonnull ADJTimeLengthMilli *)intervalSinceLastActivity
{
    ADJTimeLengthMilli *_Nullable currentTimeSpent = builder.timeSpentMilli;
    if (currentTimeSpent == nil) {
        [self.logger debugDev:@"Cannot increase time spent without any value"
                    issueType:ADJIssueLogicError];
        return;
    }

    ADJTimeLengthMilli *_Nonnull newTimeSpent =
        [currentTimeSpent generateTimeLengthWithAddedTimeLength:intervalSinceLastActivity];

    [builder setTimeSpentMilli:newTimeSpent];

    [self.logger debugDev:@"Time Spent increased"
                     key1:@"interval"
                   value1:intervalSinceLastActivity.description
                     key2:@"time spent"
                   value2:builder.timeSpentMilli.description];
}

@end
