//
//  ADJTimeLengthMilli.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJTimeLengthMilli.h"

#import "ADJUtilF.h"
#import "ADJUtilConv.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonNegativeInt *millisecondsSpan;
 */

@implementation ADJTimeLengthMilli
#pragma mark Instantiation
+ (nonnull instancetype)instanceWithoutTimeSpan {
    return [self zeroMilliInstance];
}

+ (nonnull instancetype)instanceWithOneMilliSpan {
    return [self oneMilliInstance];
}

+ (nullable instancetype)
    instanceFromOptionalIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
    logger:(nonnull ADJLogger *)logger
{
    return [self instanceFromOptionalNonNegativeInt:
            [ADJNonNegativeInt instanceFromOptionalIoDataValue:ioDataValue
                                                         logger:logger]];
}

+ (nullable instancetype)instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
                                          logger:(nonnull ADJLogger *)logger
{
    return [self instanceFromOptionalNonNegativeInt:
            [ADJNonNegativeInt instanceFromIoDataValue:ioDataValue
                                                 logger:logger]];
}

+ (nullable instancetype)
    instanceWithOptionalNumberDoubleSeconds:(nullable NSNumber *)numberDoubleSeconds
    logger:(nonnull ADJLogger *)logger
{
    if (numberDoubleSeconds == nil) {
        return nil;
    }

    ADJNonNegativeInt *_Nullable millisecondsSpan =
        [ADJNonNegativeInt
            instanceFromIntegerNumber:@(numberDoubleSeconds.doubleValue * ADJSecondToMilliDouble)
            logger:logger];

    if (millisecondsSpan == nil) {
        return nil;
    }

    return [[self alloc] initWithMillisecondsSpan:millisecondsSpan];
}

- (nonnull instancetype)initWithMillisecondsSpan:(nonnull ADJNonNegativeInt *)millisecondsSpan {
    self = [super init];

    _millisecondsSpan = millisecondsSpan;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
+ (nullable instancetype)
    instanceFromOptionalNonNegativeInt:(nullable ADJNonNegativeInt *)nonNegativeInt
{
    if (nonNegativeInt == nil) {
        return nil;
    }

    return [[self alloc] initWithMillisecondsSpan:nonNegativeInt];
}

+ (nonnull instancetype)zeroMilliInstance {
    static dispatch_once_t zeroInstanceToken;
    static id zeroInstance;
    dispatch_once(&zeroInstanceToken, ^{
        zeroInstance = [[self alloc] initWithMillisecondsSpan:[ADJNonNegativeInt instanceAtZero]];
    });
    return zeroInstance;
}

+ (nonnull instancetype)oneMilliInstance {
    static dispatch_once_t oneInstanceToken;
    static id oneInstance;
    dispatch_once(&oneInstanceToken, ^{
        oneInstance = [[self alloc] initWithMillisecondsSpan:[ADJNonNegativeInt instanceAtOne]];
    });
    return oneInstance;
}

#pragma mark Public API
- (nonnull ADJTimeLengthMilli *)
    generateTimeLengthWithAddedTimeLength:
        (nonnull ADJTimeLengthMilli *)timeLengthToAdd
{
    ADJNonNegativeInt *_Nonnull addedLengthMilli =
        [[ADJNonNegativeInt alloc] initWithUIntegerValue:
            self.millisecondsSpan.uIntegerValue
            + timeLengthToAdd.millisecondsSpan.uIntegerValue];

    return [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:addedLengthMilli];
}

- (NSTimeInterval)secondsInterval {
    return [ADJUtilConv convertToSecondsWithMilliseconds:self.millisecondsSpan.uIntegerValue];
}

- (nonnull NSString *)millisecondsDescription {
    return [NSString stringWithFormat:@"%@ millisecond(s)", self.millisecondsSpan];
}

- (nonnull NSString *)secondsDescription {
    return [NSString stringWithFormat:@"%@ second(s)",
                [ADJUtilF secondsFormat:
                    [NSNumber numberWithDouble:[self secondsInterval]]]];
}

- (BOOL)isZero {
    return [self.millisecondsSpan isZero];
}

- (BOOL)isMaxValue {
    return [self.millisecondsSpan isMaxValue];
}

#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    return [self.millisecondsSpan toNonEmptyString];
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    return [self.millisecondsSpan toIoValue];
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [self millisecondsDescription];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + [self.millisecondsSpan hash];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJTimeLengthMilli class]]) {
        return NO;
    }

    ADJTimeLengthMilli *other = (ADJTimeLengthMilli *)object;
    return [ADJUtilObj objectEquals:self.millisecondsSpan other:other.millisecondsSpan];
}

@end
