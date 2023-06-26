//
//  ADJTimestampMilli.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJTimestampMilli.h"

#import "ADJNonNegativeInt.h"
#import "ADJUtilF.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import <math.h>

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonNegativeInt *millisecondsSince1970Int;
 */

@implementation ADJTimestampMilli
#pragma mark Instantiation
+ (nonnull ADJResult<ADJTimestampMilli *> *)
    instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
{
    ADJResult<ADJNonNegativeInt *> *_Nonnull nnIntResult =
        [ADJNonNegativeInt instanceFromIoDataValue:ioDataValue];

    if (nnIntResult.wasInputNil) {
        return [ADJResult nilInputWithMessage:@"Cannot create timestamp with nil io value"];
    }

    if (nnIntResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot create timestamp instance from io value"
                                      key:@"nnInt from io value fail"
                                otherFail:nnIntResult.fail];
    }

    return [ADJResult okWithValue:
            [[ADJTimestampMilli alloc] initWithMillisecondsSince1970Int:nnIntResult.value]];
}

+ (nonnull ADJResult<ADJTimestampMilli *> *)
    instanceWithNumberDoubleSecondsSince1970:(nullable NSNumber *)numberDoubleSecondsSince1970
{
    if (numberDoubleSecondsSince1970 == nil) {
        return [ADJResult nilInputWithMessage:
                @"Cannot create timestamp with nil number double seconds since 1970"];
    }

    return [ADJTimestampMilli instanceWithTimeIntervalSecondsSince1970:
            numberDoubleSecondsSince1970.doubleValue];
}

+ (nonnull ADJResult<ADJTimestampMilli *> *)
    instanceWithTimeIntervalSecondsSince1970:(NSTimeInterval)timeIntervalSecondsSince1970
{
    NSNumber *_Nonnull milliSince1970Number =
        [NSNumber numberWithDouble:timeIntervalSecondsSince1970 * ADJSecondToMilliDouble];
    
    ADJResult<ADJNonNegativeInt *> *_Nonnull milliSince1970IntResult =
        [ADJNonNegativeInt instanceFromIntegerNumber:milliSince1970Number];

    if (milliSince1970IntResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot create timestamp from timeIntervalSecondsSince1970"
                                      key:@"nnInt from integer number fail"
                                otherFail:milliSince1970IntResult.fail];
    }

    return [ADJResult okWithValue:
            [[ADJTimestampMilli alloc] initWithMillisecondsSince1970Int:
             milliSince1970IntResult.value]];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithMillisecondsSince1970Int:
    (nonnull ADJNonNegativeInt *)millisecondsSince1970Int
{
    self = [super init];
    
    _millisecondsSince1970Int = millisecondsSince1970Int;
    
    return self;
}

#pragma mark Public API
- (nullable ADJTimeLengthMilli *)timeLengthDifferenceWithLaterTimestamp:
    (nonnull ADJTimestampMilli *)laterTimestamp
{
    if (self.millisecondsSince1970Int.uIntegerValue >
        laterTimestamp.millisecondsSince1970Int.uIntegerValue)
    {
        return nil;
    }
    
    NSUInteger millisecondsDifference =
        laterTimestamp.millisecondsSince1970Int.uIntegerValue
        - self.millisecondsSince1970Int.uIntegerValue;
    
    return [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
            [[ADJNonNegativeInt alloc] initWithUIntegerValue:millisecondsDifference]];
}

- (nonnull ADJTimeLengthMilli *)timeLengthDifferenceWithNonMonotonicNowTimestamp:
    (nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp
{
    ADJTimeLengthMilli *_Nullable originalDifference =
        [self timeLengthDifferenceWithLaterTimestamp:nonMonotonicNowTimestamp];

    if (originalDifference == nil) {
        return [ADJTimeLengthMilli instanceWithOneMilliSpan];
    }

    if ([originalDifference isEqual:[ADJTimeLengthMilli instanceWithoutTimeSpan]]) {
        return [ADJTimeLengthMilli instanceWithOneMilliSpan];
    }

    return originalDifference;
}

- (nonnull ADJTimestampMilli *)generateTimestampWithAddedTimeLength:
    (nonnull ADJTimeLengthMilli *)timeLengthToAdd
{
    NSUInteger addedMillisecondsSince1970 =
        self.millisecondsSince1970Int.uIntegerValue
        + timeLengthToAdd.millisecondsSpan.uIntegerValue;
    
    return [[ADJTimestampMilli alloc] initWithMillisecondsSince1970Int:
            [[ADJNonNegativeInt alloc] initWithUIntegerValue:addedMillisecondsSince1970]];
}

- (nonnull NSString *)dateFormattedDescription {
    return [ADJUtilF dateTimestampFormat:self];
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    return [self.millisecondsSince1970Int toIoValue];
}

#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    return [[ADJNonEmptyString alloc] initWithConstStringValue:[self dateFormattedDescription]];
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [self dateFormattedDescription];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    
    hashCode = ADJHashCodeMultiplier * hashCode + [self.millisecondsSince1970Int hash];
    
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[ADJTimestampMilli class]]) {
        return NO;
    }
    
    ADJTimestampMilli *other = (ADJTimestampMilli *)object;
    return [ADJUtilObj objectEquals:self.millisecondsSince1970Int
                              other:other.millisecondsSince1970Int];
}

@end
