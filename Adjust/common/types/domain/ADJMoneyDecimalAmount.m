//
//  ADJMoneyDecimalAmount.m
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMoneyDecimalAmount.h"

#import "ADJUtilF.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kDecimalIoValuePrefix = @"dec";
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSDecimalNumber *decimalNumberValue;
 */

@implementation ADJMoneyDecimalAmount
#pragma mark Instantiation
+ (nonnull ADJResult<ADJMoneyDecimalAmount *> *)
    instanceFromIoMoneyDecimalAmountSubValue:(nonnull NSString *)ioMoneyDecimalAmountSubValue
{
    ADJResult<NSDecimalNumber *> *_Nonnull decimalNumberResult =
        [self convertToDecimalNumberWithIoMoneyDecimalAmountSubValue:ioMoneyDecimalAmountSubValue];

    if (decimalNumberResult.fail != nil) {
        return [ADJResult failWithMessage:@"Could not create money decimal amount instance"
                " with invalid conversion from io sub value"
                              wasInputNil:NO
                               builderBlock:^(ADJResultFailBuilder *_Nonnull resultFailBuilder) {
            [resultFailBuilder withKey:@"ioMoneyDecimalAmountSubValue"
                           stringValue:ioMoneyDecimalAmountSubValue];
            [resultFailBuilder withKey:@"decimal number io sub value fail"
                             otherFail:decimalNumberResult.fail];
        }];
    }

    return [ADJMoneyDecimalAmount instanceFromDecimalNumberValue:decimalNumberResult.value];
}

+ (nonnull ADJResult<ADJMoneyDecimalAmount *> *)instanceFromDecimalNumberValue:
    (nullable NSDecimalNumber *)decimalNumberValue
{
    if (decimalNumberValue == nil) {
        return [ADJResult nilInputWithMessage:
                @"Cannot create money amount with nil decimal number value"];
    }
    
    if ([ADJUtilF isNotANumber:decimalNumberValue]) {
        return [ADJResult failWithMessage:
                [NSString stringWithFormat:
                 @"Cannot create money amount with NaN decimal number: %@",
                 decimalNumberValue.description]];
    }
    
    BOOL isDecimalNegative =
        [decimalNumberValue compare:[NSDecimalNumber zero]] == NSOrderedAscending;
    if (isDecimalNegative) {
        return [ADJResult failWithMessage:
                [NSString stringWithFormat:
                 @"Cannot create money amount with negative decimal number: %@",
                 decimalNumberValue.description]];
    }
    
    return [ADJResult okWithValue:
            [[ADJMoneyDecimalAmount alloc] initWithDecimalNumberValue:decimalNumberValue]];
}

+ (nullable NSString *)ioMoneyDecimalAmountSubValueWithIoValue:
    (nonnull ADJNonEmptyString *)ioValue
{
    return [ioValue.stringValue hasPrefix:kDecimalIoValuePrefix] ?
        [ioValue.stringValue substringFromIndex:3] : nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithDecimalNumberValue:(nonnull NSDecimalNumber *)decimalNumberValue {
    self = [super init];
    _decimalNumberValue = decimalNumberValue;
    
    return self;
}

#pragma mark Public API
#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            [ADJUtilF usLocaleNumberFormat:self.decimalNumberValue]];
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    NSDecimal decimalValue = self.decimalNumberValue.decimalValue;
    int exponent = decimalValue._exponent;
    unsigned int length = decimalValue._length;
    unsigned int isNegative = decimalValue._isNegative;
    unsigned int isCompact = decimalValue._isCompact;
    unsigned int reserved = decimalValue._reserved;
    
    /* TODO: see if memcpy version should be used instead
     unsigned long long longBits;
     memcpy(&longBits,
     self.decimalNumberValue.decimalValue._mantissa,
     sizeof(unsigned long long));
     */
    unsigned short * mantissaPtr = decimalValue._mantissa;
    unsigned long long * longBitsPtr = (unsigned long long *)mantissaPtr;
    unsigned long long longBits = *longBitsPtr;
    
    return [[ADJNonEmptyString alloc]
            initWithConstStringValue:
                [NSString stringWithFormat:@"%@%@ %@ %@ %@ %@ %@",
                 kDecimalIoValuePrefix,
                 [ADJUtilF intFormat:exponent],
                 [ADJUtilF intFormat:(int)length],
                 [ADJUtilF intFormat:(int)isNegative],
                 [ADJUtilF intFormat:(int)isCompact],
                 [ADJUtilF intFormat:(int)reserved],
                 [ADJUtilF uLongLongFormat:longBits]]];
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [self.decimalNumberValue stringValue];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    
    hashCode = ADJHashCodeMultiplier * hashCode + self.decimalNumberValue.hash;
    
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[ADJMoneyDecimalAmount class]]) {
        return NO;
    }
    
    ADJMoneyDecimalAmount *other = (ADJMoneyDecimalAmount *)object;
    return [ADJUtilObj objectEquals:self.decimalNumberValue other:other.decimalNumberValue];
}

#pragma mark Internal Methods
+ (nonnull ADJResult<NSNumber *> *)nextIntWithScanner:(nonnull NSScanner *)scanner {
    int intValue;
    if (! [scanner scanInt:&intValue]) {
        return [ADJResult failWithMessage:
                @"Invalid decimal integer representation of sub part of io decimal value"];
    }
    if (intValue == INT_MAX || intValue == INT_MAX) {
        return [ADJResult failWithMessage:@"Overflow of sub part of io decimal value"];
    }

    return [ADJResult okWithValue:[NSNumber numberWithInt:intValue]];
}
+ (nonnull ADJResult<NSDecimalNumber *> *)
    convertToDecimalNumberWithIoMoneyDecimalAmountSubValue:(nonnull NSString *)ioDecValue
{
    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:ioDecValue];

    ADJResult<NSNumber *> *_Nonnull exponentResult = [self nextIntWithScanner:scanner];
    if (exponentResult.fail != nil) {
        return [ADJResult failWithMessage:@"Could not scan exponent of io decimal value"
                                      key:@"scan fail"
                                otherFail:exponentResult.fail];
    }
    ADJResult<NSNumber *> *_Nonnull lengthResult = [self nextIntWithScanner:scanner];
    if (lengthResult.fail != nil) {
        return [ADJResult failWithMessage:@"Could not scan length of io decimal value"
                                      key:@"scan fail"
                                otherFail:exponentResult.fail];
    }
    ADJResult<NSNumber *> *_Nonnull isNegativeResult = [self nextIntWithScanner:scanner];
    if (isNegativeResult.fail != nil) {
        return [ADJResult failWithMessage:@"Could not scan isNegative of io decimal value"
                                      key:@"scan fail"
                                otherFail:isNegativeResult.fail];
    }
    ADJResult<NSNumber *> *_Nonnull isCompactResult = [self nextIntWithScanner:scanner];
    if (isCompactResult.fail != nil) {
        return [ADJResult failWithMessage:@"Could not scan isCompact of io decimal value"
                                      key:@"scan fail"
                                otherFail:isCompactResult.fail];
    }
    ADJResult<NSNumber *> *_Nonnull reservedResult = [self nextIntWithScanner:scanner];
    if (reservedResult.fail != nil) {
        return [ADJResult failWithMessage:@"Could not scan reserved of io decimal value"
                                      key:@"scan fail"
                                otherFail:reservedResult.fail];
    }
    
    unsigned long long longBits;
    if (! [scanner scanUnsignedLongLong:&longBits]) {
        return [ADJResult failWithMessage:
                @"Invalid decimal integer representation of long bitts of io decimal value"];
    }

    if (longBits == ULLONG_MAX) {
        return [ADJResult failWithMessage:@"Overflow of long bits of io decimal value"];
    }

    NSDecimal dec = {0};
    
    dec._exponent = exponentResult.value.intValue;
    dec._length = lengthResult.value.unsignedIntValue;
    dec._isNegative = isNegativeResult.value.unsignedIntValue;
    dec._isCompact = isCompactResult.value.unsignedIntValue;
    dec._reserved = reservedResult.value.unsignedIntValue;
    memcpy(&(dec._mantissa), &longBits, sizeof(unsigned long long));
    
    return [ADJResult okWithValue:[NSDecimalNumber decimalNumberWithDecimal:dec]];
}

@end
