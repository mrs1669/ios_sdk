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
        [self logInvalidExternalValue:@"session count"
                          failMessage:sessionCountResult.failMessage
                               logger:logger];
        return nil;
    }

    ADJResultNN<ADJTimestampMilli *> *_Nonnull lastActivityTimestampResult =
        [ADJTimestampMilli instanceFromIoDataValue:
             [ioDataMap pairValueWithKey:kLastActivityTimestampMilliKey]];
    if (lastActivityTimestampResult.failMessage != nil) {
        [self logInvalidExternalValue:@"last activity timestamp"
                          failMessage:lastActivityTimestampResult.failMessage
                               logger:logger];
        return nil;
    }

    ADJResultNN<ADJTimeLengthMilli *> *_Nonnull sessionLengthResult =
        [ADJTimeLengthMilli instanceFromIoDataValue:
         [ioDataMap pairValueWithKey:kSessionLengthMilliKey]];
    if (sessionLengthResult.failMessage != nil) {
        [self logInvalidExternalValue:@"session length"
                          failMessage:sessionLengthResult.failMessage
                               logger:logger];
        return nil;
    }

    ADJResultNN<ADJTimeLengthMilli *> *_Nonnull timeSpentResult =
        [ADJTimeLengthMilli instanceFromIoDataValue:
         [ioDataMap pairValueWithKey:kTimeSpentMilliKey]];
    if (timeSpentResult.failMessage != nil) {
        [self logInvalidExternalValue:@"time spent"
                          failMessage:timeSpentResult.failMessage
                               logger:logger];
        return nil;
    }

    return [[self alloc] initWithSessionCount:sessionCountResult.value
                   lastActivityTimestampMilli:lastActivityTimestampResult.value
                           sessionLengthMilli:sessionLengthResult.value
                               timeSpentMilli:timeSpentResult.value];
}
+ (void)logInvalidIoDataMapValue:(nonnull NSString *)invalidValue
                     failMessage:(nonnull NSString *)failMessage
                          logger:(nonnull ADJLogger *)logger
 {
     [logger debugWithMessage:@"Cannot create instance"
                 builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
      {
         [logBuilder where:@"from io data map"];
         [logBuilder withSubject:invalidValue
                             why:@"not present in io data map or failed to parse"];
         [logBuilder withFailMessage:failMessage
                               issue:ADJIssueInvalidInput];
     }];
 }

+ (nullable instancetype)
    instanceFromBuilder:(nonnull ADJMeasurementSessionDataBuilder *)measurementSessionDataBuilder
    logger:(nonnull ADJLogger *)logger
{
    ADJTallyCounter *_Nullable sessionCount = measurementSessionDataBuilder.sessionCount;
    if (sessionCount != nil) {
        [self logNullBuilderValue:@"session count" logger:logger];
        return nil;
    }

    ADJTimestampMilli *_Nullable lastActivityTimestampMilli =
        measurementSessionDataBuilder.lastActivityTimestampMilli;
    if (lastActivityTimestampMilli != nil) {
        [self logNullBuilderValue:@"last activity timestamp" logger:logger];
        return nil;
    }

    ADJTimeLengthMilli *_Nullable sessionLengthMilli =
        measurementSessionDataBuilder.sessionLengthMilli;
    if (sessionLengthMilli != nil) {
        [self logNullBuilderValue:@"session length" logger:logger];
        return nil;
    }

    ADJTimeLengthMilli *_Nullable timeSpentMilli = measurementSessionDataBuilder.timeSpentMilli;
    if (timeSpentMilli != nil) {
        [self logNullBuilderValue:@"time spent" logger:logger];
        return nil;
    }

    return [[self alloc] initWithSessionCount:sessionCount
                   lastActivityTimestampMilli:lastActivityTimestampMilli
                           sessionLengthMilli:sessionLengthMilli
                               timeSpentMilli:timeSpentMilli];
}
+ (void)logNullBuilderValue:(nonnull NSString *)nullValue
                     logger:(nonnull ADJLogger *)logger
{
    [logger debugWithMessage:@"Cannot create instance"
                builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
     {
        [logBuilder where:@"from builder"];
        [logBuilder withSubject:nullValue
                            why:@"null value"];
    }];
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
        [self logInvalidExternalValue:@"session count"
                          failMessage:sessionCountIntResult.failMessage
                               logger:logger];
        return nil;
    }
    ADJTallyCounter *_Nonnull sessionCount =
        [[ADJTallyCounter alloc] initWithCountValue:sessionCountIntResult.value];

    ADJResultNN<ADJTimestampMilli *> *_Nonnull lastActivityTimestampResult =
        [ADJTimestampMilli instanceWithNumberDoubleSecondsSince1970:
         lastActivityTimestampNumberDoubleSeconds];
    if (lastActivityTimestampResult.failMessage != nil) {
        [self logInvalidExternalValue:@"last activity timestamp"
                          failMessage:sessionCountIntResult.failMessage
                               logger:logger];
        return nil;
    }

    ADJResultNN<ADJTimeLengthMilli *> *_Nonnull sessionLengthResult =
        [ADJTimeLengthMilli instanceWithNumberDoubleSeconds:sessionLengthNumberDoubleSeconds];
    if (sessionLengthResult.failMessage != nil) {
        [self logInvalidExternalValue:@"session length"
                          failMessage:sessionCountIntResult.failMessage
                               logger:logger];
        return nil;
    }

    ADJResultNN<ADJTimeLengthMilli *> *_Nonnull timeSpentResult =
        [ADJTimeLengthMilli instanceWithNumberDoubleSeconds:timeSpentNumberDoubleSeconds];
    if (timeSpentResult.failMessage != nil) {
        [self logInvalidExternalValue:@"time spent"
                          failMessage:sessionCountIntResult.failMessage
                               logger:logger];
        return nil;
    }

    return [[self alloc] initWithSessionCount:sessionCount
                   lastActivityTimestampMilli:lastActivityTimestampResult.value
                           sessionLengthMilli:sessionLengthResult.value
                               timeSpentMilli:timeSpentResult.value];
}
+ (void)logInvalidExternalValue:(nonnull NSString *)invalidValue
                    failMessage:(nonnull NSString *)failMessage
                         logger:(nonnull ADJLogger *)logger
{
    [logger debugWithMessage:@"Cannot create instance"
                builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
     {
        [logBuilder where:@"from external"];
        [logBuilder withSubject:invalidValue
                            why:@"failed to parse"];
        [logBuilder withFailMessage:failMessage
                              issue:ADJIssueInvalidInput];
    }];
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
