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
#pragma mark - Public constants
NSString *const ADJMeasurementSessionStartStatusFirstSession = @"FirstSession";
NSString *const ADJMeasurementSessionStartStatusFollowingSession = @"FollowingSession";
NSString *const ADJMeasurementSessionStartStatusNotNewSession = @"NotNewSession";

#pragma mark - Private constants
static NSString *const kPreSdkInitStatus = @"PreSdkInit";
static NSString *const kPreMeasurementSessionStartStatus = @"PreMeasurementSessionStart";
static NSString *const kActiveSessionStatus = @"ActiveSession";
static NSString *const kPausedSessionStatus = @"PausedSession";

@interface ADJMeasurementSessionState ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *minMeasurementSessionIntervalMilli;

#pragma mark - Internal variables
@property (nonnull, readwrite, strong, nonatomic) NSString *measurementSessionStatus;
@property (readwrite, assign, nonatomic) BOOL isOnForeground;
@property (readwrite, assign, nonatomic) BOOL isSdkActive;
@property (readwrite, assign, nonatomic) BOOL hasFirstMeasurementSessionStartHappened;

@end

@implementation ADJMeasurementSessionState
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
           minMeasurementSessionIntervalMilli:(nonnull ADJTimeLengthMilli *)minMeasurementSessionIntervalMilli {
    self = [super initWithLoggerFactory:loggerFactory source:@"MeasurementSessionState"];
    _minMeasurementSessionIntervalMilli = minMeasurementSessionIntervalMilli;

    _measurementSessionStatus = kPreSdkInitStatus;

    _isOnForeground = ADJIsSdkInForegroundWhenStarting;

    _isSdkActive = ADJIsSdkActiveWhenStarting;

    _hasFirstMeasurementSessionStartHappened = NO;

    return self;
}

#pragma mark Public API
- (BOOL)canMeasurementSessionBecomeActiveWhenSdkInit {
    if (kPreSdkInitStatus != self.measurementSessionStatus) {
        [self.logger debugDev:
         @"Cannot change to PreSdkStart from SdkInit, was meant to be in PreSdkInit"
                          key:@"measurementSessionStatus"
                        value:self.measurementSessionStatus
                    issueType:ADJIssueLogicError];
        return NO;
    }
    self.measurementSessionStatus = kPreMeasurementSessionStartStatus;

    return [self canChangeToActiveSessionWithSource:@"SdkInit"];
}

- (BOOL)canMeasurementSessionBecomeActiveWhenAppWentToTheForeground {
    if (self.isOnForeground) {
        [self.logger debugDev:
         @"Cannot change from AppWentToTheForeground while already being in the foreground"
                    issueType:ADJIssueUnexpectedInput];
        return NO;
    }
    self.isOnForeground = YES;

    return [self canChangeToActiveSessionWithSource:@"AppWentToTheForeground"];
}

- (BOOL)canMeasurementSessionBecomeActiveWhenSdkBecameActive {
    if (self.isSdkActive) {
        [self.logger debugDev:@"Cannot change from SdkBecameActive while already being active"
                    issueType:ADJIssueUnexpectedInput];
        return NO;
    }
    self.isSdkActive = YES;

    return [self canChangeToActiveSessionWithSource:@"SdkBecameActive"];
}

- (BOOL)changeToActiveSessionWithCurrentMeasurementSessionData:(nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
                                          sdkStartStateEventWO:(nonnull ADJValueWO<NSString *> *)sdkStartStateEventWO
                               changedMeasurementSessionDataWO:(nonnull ADJValueWO<ADJMeasurementSessionData *> *)changedMeasurementSessionDataWO
                                          packageSessionDataWO:(nonnull ADJValueWO<ADJPackageSessionData *> *)packageSessionDataWO
                                 nonMonotonicNowTimestampMilli:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestampMilli
                                                        source:(nonnull NSString *)source {
    [self.logger debugDev:@"Changing to ActiveState from %@ in %@"
                     from:source
                      key:@"measurementSessionStatus"
                    value:self.measurementSessionStatus];

    ADJMeasurementSessionData *_Nonnull updatedMeasurementSessionData =
    [self
     sessionDataToUpdateWhenChangingToActiveSessionWithCurrentMeasurementSessionData:
         currentMeasurementSessionStateData
     sdkStartStateEventWO:sdkStartStateEventWO
     packageSessionDataWO:packageSessionDataWO
     nonMonotonicNowTimestampMilli:nonMonotonicNowTimestampMilli
     source:source];

    if (updatedMeasurementSessionData == nil) {
        [self.logger debugDev:@"Cannot change to Active Session with invalid sdk session"
                    issueType:ADJIssueInvalidInput];
        return NO;
    }

    [changedMeasurementSessionDataWO setNewValue:updatedMeasurementSessionData];

    self.measurementSessionStatus = kActiveSessionStatus;

    self.hasFirstMeasurementSessionStartHappened = YES;

    return YES;
}

- (void)appWentToTheBackgroundWithCurrentMeasurementSessionData:(nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
                                changedMeasurementSessionDataWO:(nonnull ADJValueWO<ADJMeasurementSessionData *> *)changedMeasurementSessionDataWO
                                  nonMonotonicNowTimestampMilli:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestampMilli {
    if (! self.isOnForeground) {
        [self.logger debugDev:
         @"Cannot change from AppWentToTheBackground while already being in the background"];
        return;
    }
    self.isOnForeground = NO;

    if (currentMeasurementSessionStateData.measurementSessionData == nil) {
        [self.logger debugDev:
         @"Cannot change from AppWentToTheBackground without a valid current session data"];
        return;
    }

    [self
     changeToPauseSessionWithCurrentMeasurementSessionData:
         currentMeasurementSessionStateData.measurementSessionData
     changedMeasurementSessionDataWO:changedMeasurementSessionDataWO
     nonMonotonicNowTimestampMilli:nonMonotonicNowTimestampMilli
     source:@"AppWentToTheBackground"];
}

- (void)sdkBecameNotActiveWithCurrentMeasurementSessionData:(nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
changedMeasurementSessionDataWO:(nonnull ADJValueWO<ADJMeasurementSessionData *> *)changedMeasurementSessionDataWO
nonMonotonicNowTimestampMilli:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestampMilli {
    if (! self.isSdkActive) {
        [self.logger debugDev:
         @"Cannot change from SdkBecameNotActive while already being in not active"];
        return;
    }
    self.isSdkActive = NO;

    if (currentMeasurementSessionStateData.measurementSessionData == nil) {
        [self.logger debugDev:
         @"Cannot change from SdkBecameNotActive without a valid current session data"];
        return;
    }

    [self
     changeToPauseSessionWithCurrentMeasurementSessionData:
         currentMeasurementSessionStateData.measurementSessionData
     changedMeasurementSessionDataWO:changedMeasurementSessionDataWO
     nonMonotonicNowTimestampMilli:nonMonotonicNowTimestampMilli
     source:@"SdkBecameNotActive"];
}

- (void)keepAlivePingedWithCurrentMeasurementSessionData:(nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
                         changedMeasurementSessionDataWO:(nonnull ADJValueWO<ADJMeasurementSessionData *> *)changedMeasurementSessionDataWO
                           nonMonotonicNowTimestampMilli:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestampMilli {
    BOOL notActiveSession = kActiveSessionStatus != self.measurementSessionStatus;

    if (notActiveSession) {
        [self.logger debugDev:@"Cannot update from KeepAlivePinged"
                          key:@"measurementSessionStatus"
                        value:self.measurementSessionStatus];
        return;
    }

    if (currentMeasurementSessionStateData.measurementSessionData == nil) {
        [self.logger debugDev:
         @"Cannot update from KeepAlivePinged without a valid current session data"];
        return;
    }

    [self
     updateIntervalsInActiveSessionWithCurrentMeasurementSessionData:
         currentMeasurementSessionStateData.measurementSessionData
     changedMeasurementSessionDataWO:changedMeasurementSessionDataWO
     nonMonotonicNowTimestampMilli:nonMonotonicNowTimestampMilli];
}

#pragma mark Internal Methods
- (BOOL)canChangeToActiveSessionWithSource:(nonnull NSString *)source {
    BOOL notPreSdkStart = kPreMeasurementSessionStartStatus != self.measurementSessionStatus;
    BOOL notPausedSession = kPausedSessionStatus != self.measurementSessionStatus;

    // can only transition to ActiveSession from PreSdkStart or PausedSession
    if (notPreSdkStart && notPausedSession) {
        [self.logger debugDev:
         @"Cannot change to ActiveSession, would be an invalid transition"
                         from:source
                          key:@"measurementSessionStatus"
                        value:self.measurementSessionStatus];

        return NO;
    }

    if (! self.isSdkActive) {
        [self.logger debugDev:
         @"Cannot change to ActiveSession while it is not active"
                         from:source
                          key:@"measurementSessionStatus"
                        value:self.measurementSessionStatus];

        return NO;
    }

    if (! self.isOnForeground) {
        [self.logger debugDev:
         @"Cannot change to ActiveSession while it is on the background"
                         from:source
                          key:@"measurementSessionStatus"
                        value:self.measurementSessionStatus];

        return NO;
    }

    return YES;
}

- (nullable ADJMeasurementSessionData *)sessionDataToUpdateWhenChangingToActiveSessionWithCurrentMeasurementSessionData:
(nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
                                                                                                   sdkStartStateEventWO:(nonnull ADJValueWO<NSString *> *)sdkStartStateEventWO
                                                                                                   packageSessionDataWO:(nonnull ADJValueWO<ADJPackageSessionData *> *)packageSessionDataWO
                                                                                          nonMonotonicNowTimestampMilli:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestampMilli
                                                                                                                 source:(nonnull NSString *)source {
    if (currentMeasurementSessionStateData.measurementSessionData == nil) {
        [self.logger debugDev:
         @"Creating first session, since there is no current session data"];

        ADJMeasurementSessionDataBuilder *_Nonnull firstSessionBuilder =
        [[ADJMeasurementSessionDataBuilder alloc] initWithPreFirstSessionData];

        [self processNewSessionWithMeasurementSessionDataBuilder:firstSessionBuilder
                                            packageSessionDataWO:packageSessionDataWO];

        [firstSessionBuilder setLastActivityTimestampMilli:nonMonotonicNowTimestampMilli];

        [sdkStartStateEventWO setNewValue:ADJMeasurementSessionStartStatusFirstSession];

        return [ADJMeasurementSessionData instanceFromBuilder:firstSessionBuilder
                                                       logger:self.logger];
    }

    ADJMeasurementSessionDataBuilder *_Nonnull updatedMeasurementSessionDataBuilder =
    [currentMeasurementSessionStateData.measurementSessionData toMeasurementSessionDataBuilder];

    ADJTimestampMilli *_Nonnull currentLastActivityTimestampMilli =
    currentMeasurementSessionStateData.measurementSessionData.lastActivityTimestampMilli;

    ADJTimeLengthMilli *_Nonnull intervalSinceLastActivityMilli =
    [self
     calculateIntervalSinceLastActivityMilliWithLastActivityTimestampMilli:
         currentLastActivityTimestampMilli
     nonMonotonicNowTimestampMilli:nonMonotonicNowTimestampMilli];

    if (intervalSinceLastActivityMilli.millisecondsSpan.uIntegerValue
        > self.minMeasurementSessionIntervalMilli.millisecondsSpan.uIntegerValue)
    {
        [self.logger debugDev:
         @"Create a new session, because there was enough of interval since last activity"
                messageParams:
         [NSDictionary dictionaryWithObjectsAndKeys:
          source, @"from",
          intervalSinceLastActivityMilli.description, @"interval milli",
          self.minMeasurementSessionIntervalMilli.description,
          @"min interval for new session milli", nil]];

        [self processNewSessionWithMeasurementSessionDataBuilder:updatedMeasurementSessionDataBuilder
                                            packageSessionDataWO:packageSessionDataWO];

        [sdkStartStateEventWO setNewValue:ADJMeasurementSessionStartStatusFollowingSession];
    } else {
        [self increaseSessionLengthWithMeasurementSessionDataBuilder:updatedMeasurementSessionDataBuilder
                                      intervalSinceLastActivityMilli:intervalSinceLastActivityMilli];

        // if it is transitioning to ActiveState from PreSdkStart
        //  it must publish an SdkStartEvent, even if there is no new session
        if (self.measurementSessionStatus == kPreMeasurementSessionStartStatus) {
            [sdkStartStateEventWO setNewValue:ADJMeasurementSessionStartStatusNotNewSession];
        }
    }

    // add time length instead of "= nowTimestampMilli"
    //  because of non monotonic clock
    [updatedMeasurementSessionDataBuilder setLastActivityTimestampMilli:
     [currentLastActivityTimestampMilli generateTimestampWithAddedTimeLength:
      intervalSinceLastActivityMilli]];

    return [ADJMeasurementSessionData instanceFromBuilder:updatedMeasurementSessionDataBuilder
                                                   logger:self.logger];
}

- (void)processNewSessionWithMeasurementSessionDataBuilder:(nonnull ADJMeasurementSessionDataBuilder *)newMeasurementSessionDataBuilder
                                      packageSessionDataWO:(nonnull ADJValueWO<ADJPackageSessionData *> *)packageSessionDataWO {

    [newMeasurementSessionDataBuilder incrementSessionCountWithLogger:self.logger];

    // build session package with the incremented session count,
    //  but before resetting the intervals from the previous sessions
    //  which are read for the new session package
    ADJPackageSessionData *_Nonnull packageSessionData =
    [[ADJPackageSessionData alloc] initWithBuilder:newMeasurementSessionDataBuilder];

    [packageSessionDataWO setNewValue:packageSessionData];

    // reset session intervals after session package has been created
    [newMeasurementSessionDataBuilder resetSessionIntervals];
}

- (nonnull ADJTimeLengthMilli *)calculateIntervalSinceLastActivityMilliWithLastActivityTimestampMilli:(nonnull ADJTimestampMilli *)lastActivityTimestampMilli
                                                                        nonMonotonicNowTimestampMilli:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestampMilli {
    ADJTimeLengthMilli *_Nullable intervalSinceLastActivityMilli =
    [lastActivityTimestampMilli timeLengthDifferenceWithLaterTimestamp:
     nonMonotonicNowTimestampMilli];

    // avoid non-reliability of non monotonic current time
    if (intervalSinceLastActivityMilli == nil
        || [intervalSinceLastActivityMilli isEqual:[ADJTimeLengthMilli instanceWithoutTimeSpan]])
    {
        return [ADJTimeLengthMilli instanceWithOneMilliSpan];
    }

    return intervalSinceLastActivityMilli;
}

- (void)increaseSessionLengthWithMeasurementSessionDataBuilder:(nonnull ADJMeasurementSessionDataBuilder *)newMeasurementSessionDataBuilder
                                intervalSinceLastActivityMilli:(nullable ADJTimeLengthMilli *)intervalSinceLastActivityMilli {
    if (intervalSinceLastActivityMilli == nil) {
        [self.logger debugDev:@"Cannot increase session length without any value"];
        return;
    }

    ADJTimeLengthMilli *_Nullable currentSessionLengthMilli =
    newMeasurementSessionDataBuilder.sessionLengthMilli;

    if (currentSessionLengthMilli == nil) {
        [self.logger debugDev:
         @"Cannot increase session length without interval since last activity"];
        return;
    }

    ADJTimeLengthMilli *_Nonnull newSessionLengthMilli =
    [currentSessionLengthMilli generateTimeLengthWithAddedTimeLength:
     intervalSinceLastActivityMilli];

    [newMeasurementSessionDataBuilder setSessionLengthMilli:newSessionLengthMilli];

    [self.logger debugDev:@"Session length increased"
                     key1:@"interval"
                   value1:intervalSinceLastActivityMilli.description
                     key2:@"session lenght"
                   value2:newMeasurementSessionDataBuilder.sessionLengthMilli.description];
}

- (void)changeToPauseSessionWithCurrentMeasurementSessionData:(nonnull ADJMeasurementSessionData *)currentMeasurementSessionData
                              changedMeasurementSessionDataWO:(nonnull ADJValueWO<ADJMeasurementSessionData *> *)changedMeasurementSessionDataWO
                                nonMonotonicNowTimestampMilli:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestampMilli
                                                       source:(nonnull NSString *)source {
    BOOL notActiveSession = kActiveSessionStatus != self.measurementSessionStatus;
    if (notActiveSession) {
        [self.logger debugDev:@"Cannot change status"
                         from:source
                          key:@"measurementSessionStatus"
                        value:self.measurementSessionStatus];
        return;
    }

    [self.logger debugDev:@"Changing to PausedSession in ActiveSession"
                     from: source];

    [self
     updateIntervalsInActiveSessionWithCurrentMeasurementSessionData:currentMeasurementSessionData
     changedMeasurementSessionDataWO:changedMeasurementSessionDataWO
     nonMonotonicNowTimestampMilli:nonMonotonicNowTimestampMilli];

    self.measurementSessionStatus = kPausedSessionStatus;
}

- (void)updateIntervalsInActiveSessionWithCurrentMeasurementSessionData:(nonnull ADJMeasurementSessionData *)currentMeasurementSessionData
                                        changedMeasurementSessionDataWO:(nonnull ADJValueWO<ADJMeasurementSessionData *> *)changedMeasurementSessionDataWO
                                          nonMonotonicNowTimestampMilli:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestampMilli {
    ADJMeasurementSessionDataBuilder *_Nonnull measurementSessionDataBuilder =
    [currentMeasurementSessionData toMeasurementSessionDataBuilder];

    ADJTimestampMilli *_Nonnull currentLastActivityTimestampMilli =
    currentMeasurementSessionData.lastActivityTimestampMilli;

    ADJTimeLengthMilli *_Nullable intervalSinceLastActivityMilli =
    [self
     calculateIntervalSinceLastActivityMilliWithLastActivityTimestampMilli:
         currentLastActivityTimestampMilli
     nonMonotonicNowTimestampMilli:nonMonotonicNowTimestampMilli];

    // add time length instead of "= nowTimestampMilli"
    //  because of non monotonic clock
    [measurementSessionDataBuilder setLastActivityTimestampMilli:
     [currentLastActivityTimestampMilli generateTimestampWithAddedTimeLength:
      intervalSinceLastActivityMilli]];

    [self increaseSessionLengthWithMeasurementSessionDataBuilder:measurementSessionDataBuilder
                                  intervalSinceLastActivityMilli:intervalSinceLastActivityMilli];

    [self increaseTimeSpentWithMeasurementSessionDataBuilder:measurementSessionDataBuilder
                              intervalSinceLastActivityMilli:intervalSinceLastActivityMilli];

    ADJMeasurementSessionData *_Nullable newMeasurementSessionData =
    [ADJMeasurementSessionData instanceFromBuilder:measurementSessionDataBuilder
                                            logger:self.logger];

    if (newMeasurementSessionData == nil) {
        [self.logger debugDev:
         @"Cannot update intervals in active session with invalid sdk session"
                    issueType:ADJIssueInvalidInput];
        return;
    }

    [changedMeasurementSessionDataWO setNewValue:newMeasurementSessionData];
}

- (void)increaseTimeSpentWithMeasurementSessionDataBuilder:(nonnull ADJMeasurementSessionDataBuilder *)newMeasurementSessionDataBuilder
                            intervalSinceLastActivityMilli:(nullable ADJTimeLengthMilli *)intervalSinceLastActivityMilli {
    if (intervalSinceLastActivityMilli == nil) {
        [self.logger debugDev:
         @"Cannot increase time spent without interval since last activity"
                    issueType:ADJIssueInvalidInput];
        return;
    }

    ADJTimeLengthMilli *_Nullable currentTimeSpentMilli =
    newMeasurementSessionDataBuilder.timeSpentMilli;

    if (currentTimeSpentMilli == nil) {
        [self.logger debugDev:@"Cannot increase time spent without any value"
                    issueType:ADJIssueInvalidInput];
        return;
    }

    ADJTimeLengthMilli *_Nonnull newTimeSpentMilli =
    [currentTimeSpentMilli
     generateTimeLengthWithAddedTimeLength:intervalSinceLastActivityMilli];

    [newMeasurementSessionDataBuilder setTimeSpentMilli:newTimeSpentMilli];

    [self.logger debugDev:@"Time Spent increased"
                     key1:@"interval"
                   value1:intervalSinceLastActivityMilli.description
                     key2:@"time spent"
                   value2:newMeasurementSessionDataBuilder.timeSpentMilli.description];
}

@end

