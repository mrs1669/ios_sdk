//
//  ADJMoneyDoubleAmount.m
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMoneyDoubleAmount.h"

#import "ADJUtilF.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJUtilConv.h"

//#import "ADJResultFail.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSNumber *doubleNumberValue;
 */

@implementation ADJMoneyDoubleAmount
#pragma mark Instantiation
+ (nonnull ADJResult<ADJMoneyDoubleAmount *> *)
    instanceFromIoLlfValue:(nonnull NSString *)ioLlfValue
{
    ADJResult<NSNumber *> *_Nonnull doubleNumberValueResult =
        [self convertToDoubleNumberWithIoLlfValue:ioLlfValue];

    if (doubleNumberValueResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Could not obtain double number from llf string value"
                                      key:@"convert to double from llf string value fail"
                                otherFail:doubleNumberValueResult.fail];
    }
    return [self instanceFromDoubleNumberValue:doubleNumberValueResult.value];
}

+ (nonnull ADJResult<ADJMoneyDoubleAmount *> *)
    instanceFromDoubleNumberValue:(nullable NSNumber *)doubleNumberValue
{
    if (doubleNumberValue == nil) {
        return [ADJResult nilInputWithMessage:
                @"Cannot create money amount with nil double number value"];
    }

    if ([ADJUtilF isNotANumber:doubleNumberValue]) {
        return [ADJResult failWithMessage:
                [NSString stringWithFormat:@"Cannot create money amount with NaN double number: %@",
                 doubleNumberValue.description]];
    }

    if (doubleNumberValue.doubleValue != 0.0 && ! isnormal(doubleNumberValue.doubleValue)) {
        return [ADJResult failWithMessage:
                [NSString stringWithFormat:@"Cannot create money amount with"
                 " double number that is not normal, while not being 0.0: %@",
                 doubleNumberValue.description]];
    }

    if (doubleNumberValue.doubleValue < 0.0) {
        return [ADJResult failWithMessage:
                [NSString stringWithFormat:
                 @"Cannot create money amount with negative double number: %@",
                 doubleNumberValue.description]];
    }

    return [ADJResult okWithValue:
            [[ADJMoneyDoubleAmount alloc] initWithDoubleNumberValue:doubleNumberValue]];
}

- (nonnull instancetype)initWithDoubleNumberValue:(nonnull NSNumber *)doubleNumberValue {
    self = [super init];
    
    _doubleNumberValue = doubleNumberValue;
    
    return self;
}

#pragma mark Public API
#pragma mark - ADJMoneyAmount
- (nonnull NSNumber *)numberValue {
    return self.doubleNumberValue;
}

- (double)doubleValue {
    return self.doubleNumberValue.doubleValue;
}

#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            [ADJUtilF usLocaleNumberFormat:self.doubleNumberValue]];
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    double doubleValue = self.doubleNumberValue.doubleValue;
    long long * longBitsPtr = (long long *)&doubleValue;
    long long longBits = *longBitsPtr;
    
    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            [NSString stringWithFormat:@"llf%@",
             [ADJUtilF longLongFormat:longBits]]];
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [self.doubleNumberValue stringValue];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    
    hashCode = ADJHashCodeMultiplier * hashCode + self.doubleNumberValue.hash;
    
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (! [object isKindOfClass:[ADJMoneyDoubleAmount class]]) {
        return NO;
    }
    
    ADJMoneyDoubleAmount *other = (ADJMoneyDoubleAmount *)object;
    return [ADJUtilObj objectEquals:self.doubleNumberValue other:other.doubleNumberValue];
}

#pragma mark Internal Methods
+ (nonnull ADJResult<NSNumber *> *)convertToDoubleNumberWithIoLlfValue:
    (nonnull NSString *)ioLlfValue
{
    ADJResult<NSNumber *> *_Nonnull llNumberResult =
        [ADJUtilConv convertToLLNumberWithStringValue:ioLlfValue];
    if (llNumberResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Could not convert first to ll number, before converting to double"
                                      key:@"string to ll number fail"
                                otherFail:llNumberResult.fail];
    }
    
    long long llValue = llNumberResult.value.longLongValue;
    
    double * doublePtr = (double *)&llValue;
    
    double doubleValue = *(doublePtr);
    
    return [ADJResult okWithValue:@(doubleValue)];
}

+ (BOOL)isDoubleValidWithValue:(double)doubleValue {
    if (doubleValue == 0.0) {
        return YES;
    }
    
    return isnormal(doubleValue) ? YES : NO;
}

@end
