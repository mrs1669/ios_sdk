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
+ (nullable instancetype)instanceFromOptionalIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
                                                  logger:(nonnull ADJLogger *)logger {
    return [self instanceWithOptionalMillisecondsSince1970NonNegativeInt:
            [ADJNonNegativeInt instanceFromOptionalIoDataValue:ioDataValue
                                                        logger:logger]];
}

+ (nullable instancetype)instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
                                          logger:(nonnull ADJLogger *)logger {
    return [self instanceWithOptionalMillisecondsSince1970NonNegativeInt:
            [ADJNonNegativeInt instanceFromIoDataValue:ioDataValue
                                                logger:logger]];
}

+ (nullable instancetype)instanceWithTimeIntervalSecondsSince1970:(NSTimeInterval)timeIntervalSecondsSince1970
                                                           logger:(nonnull ADJLogger *)logger {
    NSNumber *_Nonnull milliSince1970Number =
    [NSNumber numberWithDouble:timeIntervalSecondsSince1970 * ADJSecondToMilliDouble];
    
    ADJNonNegativeInt *_Nullable milliSince1970Int =
    [ADJNonNegativeInt instanceFromIntegerNumber:milliSince1970Number
                                          logger:logger];
    
    if (milliSince1970Int == nil) {
        return nil;
    }
    
    return [[self alloc] initWithMillisecondsSince1970Int:milliSince1970Int];
}

+ (nullable instancetype)instanceWithOptionalNumberDoubleSecondsSince1970:(nullable NSNumber *)numberDoubleSecondsSince1970
                                                                   logger:(nonnull ADJLogger *)logger {
    if (numberDoubleSecondsSince1970 == nil) {
        return nil;
    }
    
    return [self instanceWithTimeIntervalSecondsSince1970:numberDoubleSecondsSince1970.doubleValue
                                                   logger:logger];
}

+ (nullable instancetype)instanceWithNSDateValue:(nullable NSDate *)nsDateValue
                                          logger:(nonnull ADJLogger *)logger {
    if (nsDateValue == nil) {
        return nil;
    }
    
    return [self instanceWithTimeIntervalSecondsSince1970:nsDateValue.timeIntervalSince1970
                                                   logger:logger];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
+ (nullable instancetype)instanceWithOptionalMillisecondsSince1970NonNegativeInt:(nullable ADJNonNegativeInt *)millisecondsSince1970NonNegativeInt {
    if (millisecondsSince1970NonNegativeInt == nil) {
        return nil;
    }
    
    return [[self alloc] initWithMillisecondsSince1970Int:millisecondsSince1970NonNegativeInt];
}

- (nonnull instancetype)initWithMillisecondsSince1970Int:(nonnull ADJNonNegativeInt *)millisecondsSince1970Int {
    self = [super init];
    
    _millisecondsSince1970Int = millisecondsSince1970Int;
    
    return self;
}

#pragma mark Public API
- (nullable ADJTimeLengthMilli *)timeLengthDifferenceWithLaterTimestamp:(nonnull ADJTimestampMilli *)laterTimestamp {
    if (self.millisecondsSince1970Int.uIntegerValue >
        laterTimestamp.millisecondsSince1970Int.uIntegerValue)
    {
        return nil;
    }
    
    NSUInteger millisecondsDifference =
    laterTimestamp.millisecondsSince1970Int.uIntegerValue -
    self.millisecondsSince1970Int.uIntegerValue;
    
    return [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
            [[ADJNonNegativeInt alloc] initWithUIntegerValue:
             millisecondsDifference]];
}

- (nonnull ADJTimestampMilli *)generateTimestampWithAddedTimeLength:(nonnull ADJTimeLengthMilli *)timeLengthToAdd {
    NSUInteger addedMillisecondsSince1970 =
    self.millisecondsSince1970Int.uIntegerValue +
    timeLengthToAdd.millisecondsSpan.uIntegerValue;
    
    return [[ADJTimestampMilli alloc] initWithMillisecondsSince1970Int:
            [[ADJNonNegativeInt alloc] initWithUIntegerValue:
             addedMillisecondsSince1970]];
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
    return [[ADJNonEmptyString alloc]
            initWithConstStringValue:[self dateFormattedDescription]];
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
