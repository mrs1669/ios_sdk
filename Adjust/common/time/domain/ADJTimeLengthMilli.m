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

//#import "ADJResultFail.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonNegativeInt *millisecondsSpan;
 */

@implementation ADJTimeLengthMilli
#pragma mark Instantiation
+ (nonnull instancetype)instanceWithoutTimeSpan {
    static dispatch_once_t zeroInstanceToken;
    static id zeroInstance;
    dispatch_once(&zeroInstanceToken, ^{
        zeroInstance = [[self alloc] initWithMillisecondsSpan:[ADJNonNegativeInt instanceAtZero]];
    });
    return zeroInstance;
}

+ (nonnull instancetype)instanceWithOneMilliSpan {
    static dispatch_once_t oneInstanceToken;
    static id oneInstance;
    dispatch_once(&oneInstanceToken, ^{
        oneInstance = [[self alloc] initWithMillisecondsSpan:[ADJNonNegativeInt instanceAtOne]];
    });
    return oneInstance;
}

+ (nonnull ADJResult<ADJTimeLengthMilli *> *)
    instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
{
    ADJResult<ADJNonNegativeInt *> *_Nonnull nnIntResult =
        [ADJNonNegativeInt instanceFromIoDataValue:ioDataValue];

    if (nnIntResult.wasInputNil) {
        return [ADJResult nilInputWithMessage:
                @"Cannot create time length with nil io value"];
    }

    if (nnIntResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot create time length instance"
                                      key:@"nnInt io value fail"
                                otherFail:nnIntResult.fail];
    }

    return [ADJResult okWithValue:
            [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:nnIntResult.value]];
}

+ (nonnull ADJResult<ADJTimeLengthMilli *> *)
    instanceWithNumberDoubleSeconds:(nullable NSNumber *)numberDoubleSeconds
{
    if (numberDoubleSeconds == nil) {
        return [ADJResult nilInputWithMessage:
                @"Cannot create time length with nil number double seconds"];
    }

    ADJResult<ADJNonNegativeInt *> *_Nonnull millisecondsSpanResult =
        [ADJNonNegativeInt
         instanceFromIntegerNumber:
             [NSNumber numberWithDouble:numberDoubleSeconds.doubleValue * ADJSecondToMilliDouble]];
    if (millisecondsSpanResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot create time length instance"
                              wasInputNil:NO
                             builderBlock:^(ADJResultFailBuilder * _Nonnull resultFailBuilder) {
            [resultFailBuilder withKey:@"key convertion fail"
                             otherFail:millisecondsSpanResult.fail];
            [resultFailBuilder withKey:@"number double seconds"
                           stringValue:[ADJUtilF usLocaleNumberFormat:numberDoubleSeconds]];
        }];
    }
    
    return [ADJResult okWithValue:
            [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:millisecondsSpanResult.value]];
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

#pragma mark Public API
- (nonnull ADJTimeLengthMilli *)generateTimeLengthWithAddedTimeLength:(nonnull ADJTimeLengthMilli *)timeLengthToAdd {
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
    return self.millisecondsSpan.uIntegerValue == 1 ? @"1 millisecond"
        : [NSString stringWithFormat:@"%@ milliseconds", self.millisecondsSpan];
}

- (nonnull NSString *)secondsDescription {
    return [NSString stringWithFormat:@"%@ seconds",
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
