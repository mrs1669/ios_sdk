//
//  ADJMeasurementSessionData.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMeasurementSessionData.h"

#import "ADJUtilObj.h"
#import "ADJUtilMap.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJTallyCounter *sessionCount;
 @property (nonnull, readonly, strong, nonatomic) ADJTimestampMilli *lastActivityTimestampMilli;
 @property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *sessionLengthMilli;
 @property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *timeSpentMilli;
 */

#pragma mark - Public constants
NSString *const ADJMeasurementSessionDataMetadataTypeValue = @"MeasurementSessionData";

#pragma mark - Private constants
static NSString *const kSessionCountKey = @"sessionCount";
static NSString *const kLastActivityTimestampMilliKey = @"lastActivityTimestampMilli";
static NSString *const kSessionLengthMilliKey = @"sessionLengthMilli";
static NSString *const kTimeSpentMilliKey = @"timeSpentMilli";

@implementation ADJMeasurementSessionData
#pragma mark Instantiation
+ (nullable instancetype)instanceFromIoDataMap:(nonnull ADJStringMap *)ioDataMap
                                        logger:(nonnull ADJLogger *)logger
{
    ADJResultNN<ADJTallyCounter *> *_Nonnull sessionCountResult =
        [ADJTallyCounter
         instanceFromIoDataValue:[ioDataMap pairValueWithKey:kSessionCountKey]];
    if (sessionCountResult.failMessage != nil) {
        [logger debugDev:@"Cannot create instance with invalid session count"
                    from:@"io data map"
             failMessage:sessionCountResult.failMessage
               issueType:ADJIssueStorageIo];
        return nil;
    }

    ADJResultNN<ADJTimestampMilli *> *_Nonnull lastActivityTimestampResult =
        [ADJTimestampMilli instanceFromIoDataValue:
             [ioDataMap pairValueWithKey:kLastActivityTimestampMilliKey]];
    if (lastActivityTimestampResult.failMessage != nil) {
        [logger debugDev:@"Cannot create instance with invalid last activity timestamp"
                    from:@"io data map"
             failMessage:lastActivityTimestampResult.failMessage
               issueType:ADJIssueStorageIo];
        return nil;
    }

    ADJResultNN<ADJTimeLengthMilli *> *_Nonnull sessionLengthResult =
        [ADJTimeLengthMilli instanceFromIoDataValue:
         [ioDataMap pairValueWithKey:kSessionLengthMilliKey]];
    if (sessionLengthResult.failMessage != nil) {
        [logger debugDev:@"Cannot create instance with invalid session length"
                    from:@"io data map"
             failMessage:sessionLengthResult.failMessage
               issueType:ADJIssueStorageIo];
        return nil;
    }

    ADJResultNN<ADJTimeLengthMilli *> *_Nonnull timeSpentResult =
        [ADJTimeLengthMilli instanceFromIoDataValue:
         [ioDataMap pairValueWithKey:kTimeSpentMilliKey]];
    if (timeSpentResult.failMessage != nil) {
        [logger debugDev:@"Cannot create instance with invalid time spent"
                    from:@"io data map"
             failMessage:timeSpentResult.failMessage
               issueType:ADJIssueStorageIo];
        return nil;
    }

    return [[self alloc] initWithSessionCount:sessionCountResult.value
                   lastActivityTimestampMilli:lastActivityTimestampResult.value
                           sessionLengthMilli:sessionLengthResult.value
                               timeSpentMilli:timeSpentResult.value];
}

+ (nullable instancetype)
    instanceFromBuilder:(nonnull ADJMeasurementSessionDataBuilder *)measurementSessionDataBuilder
    logger:(nonnull ADJLogger *)logger
{
    ADJTallyCounter *_Nullable sessionCount = measurementSessionDataBuilder.sessionCount;
    if (sessionCount != nil) {
        [logger debugDev:@"Cannot create instance with nil session count"
                    from:@"builder"
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    ADJTimestampMilli *_Nullable lastActivityTimestampMilli =
        measurementSessionDataBuilder.lastActivityTimestampMilli;
    if (lastActivityTimestampMilli != nil) {
        [logger debugDev:@"Cannot create instance with nil last activity timestamp"
                    from:@"builder"
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    ADJTimeLengthMilli *_Nullable sessionLengthMilli =
        measurementSessionDataBuilder.sessionLengthMilli;
    if (sessionLengthMilli != nil) {
        [logger debugDev:@"Cannot create instance with nil session length"
                    from:@"builder"
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    ADJTimeLengthMilli *_Nullable timeSpentMilli = measurementSessionDataBuilder.timeSpentMilli;
    if (timeSpentMilli != nil) {
        [logger debugDev:@"Cannot create instance with nil time spent"
                    from:@"builder"
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    return [[self alloc] initWithSessionCount:sessionCount
                   lastActivityTimestampMilli:lastActivityTimestampMilli
                           sessionLengthMilli:sessionLengthMilli
                               timeSpentMilli:timeSpentMilli];
}

+ (nullable instancetype)
    instanceFromExternalWithSessionCountNumberInt:(nullable NSNumber *)sessionCountNumberInt
    lastActivityTimestampNumberDoubleSeconds:
        (nullable NSNumber *)lastActivityTimestampNumberDoubleSeconds
    sessionLengthNumberDoubleSeconds:(nullable NSNumber *)sessionLengthNumberDoubleSeconds
    timeSpentNumberDoubleSeconds:(nullable NSNumber *)timeSpentNumberDoubleSeconds
    logger:(nonnull ADJLogger *)logger
{
    ADJResultNN<ADJNonNegativeInt *> *_Nonnull sessionCountIntResult =
        [ADJNonNegativeInt instanceFromIntegerNumber:sessionCountNumberInt];
    if (sessionCountIntResult.failMessage != nil) {
        [logger debugDev:@"Cannot create instance with invalid session count"
                    from:@"external data"
             failMessage:sessionCountIntResult.failMessage
               issueType:ADJIssueInvalidInput];
        return nil;
    }
    ADJTallyCounter *_Nonnull sessionCount =
        [[ADJTallyCounter alloc] initWithCountValue:sessionCountIntResult.value];

    ADJResultNN<ADJTimestampMilli *> *_Nonnull lastActivityTimestampResult =
        [ADJTimestampMilli instanceWithNumberDoubleSecondsSince1970:
         lastActivityTimestampNumberDoubleSeconds];
    if (lastActivityTimestampResult.failMessage != nil) {
        [logger debugDev:@"Cannot create instance with invalid last activity timestamp"
                    from:@"external data"
             failMessage:lastActivityTimestampResult.failMessage
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    ADJResultNN<ADJTimeLengthMilli *> *_Nonnull sessionLengthResult =
        [ADJTimeLengthMilli instanceWithNumberDoubleSeconds:sessionLengthNumberDoubleSeconds];
    if (sessionLengthResult.failMessage != nil) {
        [logger debugDev:@"Cannot create instance with invalid session length"
                    from:@"external data"
             failMessage:sessionLengthResult.failMessage
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    ADJResultNN<ADJTimeLengthMilli *> *_Nonnull timeSpentResult =
        [ADJTimeLengthMilli instanceWithNumberDoubleSeconds:timeSpentNumberDoubleSeconds];
    if (timeSpentResult.failMessage != nil) {
        [logger debugDev:@"Cannot create instance with invalid time spent"
                    from:@"external data"
             failMessage:timeSpentResult.failMessage
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    return [[self alloc] initWithSessionCount:sessionCount
                   lastActivityTimestampMilli:lastActivityTimestampResult.value
                           sessionLengthMilli:sessionLengthResult.value
                               timeSpentMilli:timeSpentResult.value];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
/*
+ (nullable instancetype)
    instanceFromNullableWithSessionCount:(nullable ADJTallyCounter *)sessionCount
    lastActivityTimestampMilli:(nullable ADJTimestampMilli *)lastActivityTimestampMilli
    sessionLengthMilli:(nullable ADJTimeLengthMilli *)sessionLengthMilli
    timeSpentMilli:(nullable ADJTimeLengthMilli *)timeSpentMilli
    logger:(nonnull ADJLogger *)logger
{
    if (sessionCount == nil) {
        [self errorLogAtCreateWithLogger:logger key:kSessionCountKey];
        return nil;
    }

    if (lastActivityTimestampMilli == nil) {
        [self errorLogAtCreateWithLogger:logger key:kLastActivityTimestampMilliKey];
        return nil;
    }

    if (sessionLengthMilli == nil) {
        [self errorLogAtCreateWithLogger:logger key:kSessionLengthMilliKey];
        return nil;
    }

    if (timeSpentMilli == nil) {
        [self errorLogAtCreateWithLogger:logger key:kTimeSpentMilliKey];
        return nil;
    }

    return [[self alloc] initWithSessionCount:sessionCount
                   lastActivityTimestampMilli:lastActivityTimestampMilli
                           sessionLengthMilli:sessionLengthMilli
                               timeSpentMilli:timeSpentMilli];
}
*/
- (nonnull instancetype)
    initWithSessionCount:(nonnull ADJTallyCounter *)sessionCount
    lastActivityTimestampMilli:(nonnull ADJTimestampMilli *)lastActivityTimestampMilli
    sessionLengthMilli:(nonnull ADJTimeLengthMilli *)sessionLengthMilli
    timeSpentMilli:(nonnull ADJTimeLengthMilli *)timeSpentMilli
{
    self = [super init];

    _sessionCount = sessionCount;
    _lastActivityTimestampMilli = lastActivityTimestampMilli;
    _sessionLengthMilli = sessionLengthMilli;
    _timeSpentMilli = timeSpentMilli;

    return self;
}

#pragma mark Public API
- (nonnull ADJMeasurementSessionDataBuilder *)toMeasurementSessionDataBuilder {
    return [[ADJMeasurementSessionDataBuilder alloc]
            initWithSessionCount:self.sessionCount
            lastActivityTimestampMilli:self.lastActivityTimestampMilli
            sessionLengthMilli:self.sessionLengthMilli
            timeSpentMilli:self.timeSpentMilli];
}

#pragma mark - ADJIoDataMapBuilderInjectable
- (void)injectIntoIoDataMapBuilder:(nonnull ADJStringMapBuilder *)ioDataMapBuilder {
    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataMapBuilder
                                       key:kSessionCountKey
                       ioValueSerializable:self.sessionCount];

    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataMapBuilder
                                       key:kLastActivityTimestampMilliKey
                       ioValueSerializable:self.lastActivityTimestampMilli];

    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataMapBuilder
                                       key:kSessionLengthMilliKey
                       ioValueSerializable:self.sessionLengthMilli];

    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataMapBuilder
                                       key:kTimeSpentMilliKey
                       ioValueSerializable:self.timeSpentMilli];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJMeasurementSessionDataMetadataTypeValue,
            kSessionCountKey, self.sessionCount,
            kLastActivityTimestampMilliKey, self.lastActivityTimestampMilli,
            kSessionLengthMilliKey, self.sessionLengthMilli,
            kTimeSpentMilliKey, self.timeSpentMilli,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + self.sessionCount.hash;
    hashCode = ADJHashCodeMultiplier * hashCode + self.lastActivityTimestampMilli.hash;
    hashCode = ADJHashCodeMultiplier * hashCode + self.sessionLengthMilli.hash;
    hashCode = ADJHashCodeMultiplier * hashCode + self.timeSpentMilli.hash;

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJMeasurementSessionData class]]) {
        return NO;
    }

    ADJMeasurementSessionData *other = (ADJMeasurementSessionData *)object;
    return [ADJUtilObj objectEquals:self.sessionCount other:other.sessionCount]
    && [ADJUtilObj objectEquals:self.lastActivityTimestampMilli
                          other:other.lastActivityTimestampMilli]
    && [ADJUtilObj objectEquals:self.sessionLengthMilli other:other.sessionLengthMilli]
    && [ADJUtilObj objectEquals:self.timeSpentMilli other:other.timeSpentMilli];
}
@end
