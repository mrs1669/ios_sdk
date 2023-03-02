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
+ (nonnull ADJResultNN<ADJMoneyDoubleAmount *> *)
    instanceFromIoLlfValue:(nonnull NSString *)ioLlfValue
{
    ADJResultNN<NSNumber *> *_Nonnull doubleNumberValueResult =
        [self convertToDoubleNumberWithIoLlfValue:ioLlfValue];

    if (doubleNumberValueResult.fail != nil) {
        return [ADJResultNN failWithMessage:
                @"Could not obtain double number from llf string value"
                                        key:@"convert to double from llf string value fail"
                                      value:[doubleNumberValueResult.fail foundationDictionary]];
    }
    return [self instanceFromDoubleNumberValue:doubleNumberValueResult.value];
}

+ (nonnull ADJResultNN<ADJMoneyDoubleAmount *> *)
    instanceFromDoubleNumberValue:(nullable NSNumber *)doubleNumberValue
{
    if (doubleNumberValue == nil) {
        return [ADJResultNN failWithMessage:
                @"Cannot create money amount with nil double number value"];
    }

    if ([ADJUtilF isNotANumber:doubleNumberValue]) {
        return [ADJResultNN failWithMessage:
                [NSString stringWithFormat:@"Cannot create money amount with NaN double number: %@",
                 doubleNumberValue.description]];
    }

    if (doubleNumberValue.doubleValue != 0.0 && ! isnormal(doubleNumberValue.doubleValue)) {
        return [ADJResultNN failWithMessage:
                [NSString stringWithFormat:@"Cannot create money amount with"
                 " double number that is not normal, while not being 0.0: %@",
                 doubleNumberValue.description]];
    }

    if (doubleNumberValue.doubleValue < 0.0) {
        return [ADJResultNN failWithMessage:
                [NSString stringWithFormat:
                 @"Cannot create money amount with negative double number: %@",
                 doubleNumberValue.description]];
    }

    return [ADJResultNN okWithValue:
            [[ADJMoneyDoubleAmount alloc] initWithDoubleNumberValue:doubleNumberValue]];
}

+ (nonnull ADJResultNL<ADJMoneyDoubleAmount *> *)
    instanceFromOptionalDoubleNumberValue:(nullable NSNumber *)doubleNumberValue
{
    return [ADJResultNL instanceFromNN:^ADJResultNN * _Nonnull(NSNumber *_Nullable value) {
        return [ADJMoneyDoubleAmount instanceFromDoubleNumberValue:value];
    } nlValue:doubleNumberValue];
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
+ (nonnull ADJResultNN<NSNumber *> *)convertToDoubleNumberWithIoLlfValue:
    (nonnull NSString *)ioLlfValue
{
    ADJResultNN<NSNumber *> *_Nonnull llNumberResult =
        [ADJUtilConv convertToLLNumberWithStringValue:ioLlfValue];
    if (llNumberResult.fail != nil) {
        return [ADJResultNN failWithMessage:
                    @"Could not convert first to ll number, before converting to double"
                                        key:@"string to ll number fail"
                                      value:[llNumberResult.fail foundationDictionary]];
    }
    
    long long llValue = llNumberResult.value.longLongValue;
    
    double * doublePtr = (double *)&llValue;
    
    double doubleValue = *(doublePtr);
    
    return [ADJResultNN okWithValue:@(doubleValue)];
}

+ (BOOL)isDoubleValidWithValue:(double)doubleValue {
    if (doubleValue == 0.0) {
        return YES;
    }
    
    return isnormal(doubleValue) ? YES : NO;
}

@end
