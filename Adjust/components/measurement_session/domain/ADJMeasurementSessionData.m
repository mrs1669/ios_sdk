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
+ (nonnull ADJResult<ADJMeasurementSessionData *> *)
    instanceFromIoDataMap:(nonnull ADJStringMap *)ioDataMap
{
    ADJResult<ADJTallyCounter *> *_Nonnull sessionCountResult =
        [ADJTallyCounter
         instanceFromIoDataValue:[ioDataMap pairValueWithKey:kSessionCountKey]];
    if (sessionCountResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot create instance from io data map with invalid session count"
                                      key:@"session count fail"
                                otherFail:sessionCountResult.fail];
    }

    ADJResult<ADJTimestampMilli *> *_Nonnull lastActivityTimestampResult =
        [ADJTimestampMilli instanceFromIoDataValue:
             [ioDataMap pairValueWithKey:kLastActivityTimestampMilliKey]];
    if (lastActivityTimestampResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot create instance from io data map with invalid last activity timestamp"
                                      key:@"last activity timestamp fail"
                                otherFail:lastActivityTimestampResult.fail];
    }

    ADJResult<ADJTimeLengthMilli *> *_Nonnull sessionLengthResult =
        [ADJTimeLengthMilli instanceFromIoDataValue:
         [ioDataMap pairValueWithKey:kSessionLengthMilliKey]];
    if (sessionLengthResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot create instance from io data map with invalid session length"
                                      key:@"session length fail"
                                otherFail:sessionLengthResult.fail];
    }

    ADJResult<ADJTimeLengthMilli *> *_Nonnull timeSpentResult =
        [ADJTimeLengthMilli instanceFromIoDataValue:
         [ioDataMap pairValueWithKey:kTimeSpentMilliKey]];
    if (timeSpentResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot create instance from io data map with invalid time spent"
                                      key:@"time spent fail"
                                otherFail:timeSpentResult.fail];
    }

    return [ADJResult okWithValue:[[ADJMeasurementSessionData alloc]
                                   initWithSessionCount:sessionCountResult.value
                                   lastActivityTimestampMilli:lastActivityTimestampResult.value
                                   sessionLengthMilli:sessionLengthResult.value
                                   timeSpentMilli:timeSpentResult.value]];
}

+ (nonnull ADJResult<ADJMeasurementSessionData *> *)
    instanceFromBuilder:(nonnull ADJMeasurementSessionDataBuilder *)measurementSessionDataBuilder
{
    ADJTallyCounter *_Nullable sessionCount = measurementSessionDataBuilder.sessionCount;
    if (sessionCount == nil) {
        return [ADJResult failWithMessage:
                @"Cannot create instance from builder without session count"];
    }

    ADJTimestampMilli *_Nullable lastActivityTimestampMilli =
        measurementSessionDataBuilder.lastActivityTimestampMilli;
    if (lastActivityTimestampMilli == nil) {
        return [ADJResult failWithMessage:
                @"Cannot create instance from builder without last activity timestamp"];
    }

    ADJTimeLengthMilli *_Nullable sessionLengthMilli =
        measurementSessionDataBuilder.sessionLengthMilli;
    if (sessionLengthMilli == nil) {
        return [ADJResult failWithMessage:
                @"Cannot create instance from builder without session length"];
    }

    ADJTimeLengthMilli *_Nullable timeSpentMilli = measurementSessionDataBuilder.timeSpentMilli;
    if (timeSpentMilli == nil) {
        return [ADJResult failWithMessage:
                @"Cannot create instance from builder without time spent"];
    }

    return [ADJResult okWithValue:[[ADJMeasurementSessionData alloc]
                                   initWithSessionCount:sessionCount
                                   lastActivityTimestampMilli:lastActivityTimestampMilli
                                   sessionLengthMilli:sessionLengthMilli
                                   timeSpentMilli:timeSpentMilli]];
}

+ (nonnull ADJResult<ADJMeasurementSessionData *> *)
    instanceFromV4WithActivityState:(nonnull ADJV4ActivityState *)v4ActivityState
{
    ADJResult<ADJNonNegativeInt *> *_Nonnull sessionCountIntResult =
        [ADJNonNegativeInt instanceFromIntegerNumber:v4ActivityState.sessionCountNumberInt];
    if (sessionCountIntResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot create session data instance with invalid session count"
                                      key:@"session count fail"
                                otherFail:sessionCountIntResult.fail];
    }
    ADJTallyCounter *_Nonnull sessionCount =
        [[ADJTallyCounter alloc] initWithCountValue:sessionCountIntResult.value];

    ADJResult<ADJTimestampMilli *> *_Nonnull lastActivityTimestampResult =
        [ADJTimestampMilli instanceWithNumberDoubleSecondsSince1970:
         v4ActivityState.lastActivityNumberDouble];
    if (lastActivityTimestampResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot create session data instance with invalid last activity timestamp"
                                      key:@"last activity timestamp fail"
                                otherFail:lastActivityTimestampResult.fail];
    }

    ADJResult<ADJTimeLengthMilli *> *_Nonnull sessionLengthResult =
        [ADJTimeLengthMilli instanceWithNumberDoubleSeconds:
         v4ActivityState.sessionLengthNumberDouble];
    if (sessionLengthResult.fail != nil) {
        return [ADJResult
                failWithMessage:@"Cannot create session data instance with invalid session length"
                key:@"session length fail"
                otherFail:sessionLengthResult.fail];
    }

    ADJResult<ADJTimeLengthMilli *> *_Nonnull timeSpentResult =
        [ADJTimeLengthMilli instanceWithNumberDoubleSeconds:v4ActivityState.timeSpentNumberDouble];
    if (timeSpentResult.fail != nil) {
        return [ADJResult
                failWithMessage:@"Cannot create session data instance with invalid time spent"
                key:@"time spent fail"
                otherFail:timeSpentResult.fail];
    }

    return [ADJResult okWithValue:
            [[ADJMeasurementSessionData alloc]
             initWithSessionCount:sessionCount
             lastActivityTimestampMilli:lastActivityTimestampResult.value
             sessionLengthMilli:sessionLengthResult.value
             timeSpentMilli:timeSpentResult.value]];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
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
