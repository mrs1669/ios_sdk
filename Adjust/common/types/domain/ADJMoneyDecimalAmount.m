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
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSDecimalNumber *decimalNumberValue;
 */

@implementation ADJMoneyDecimalAmount
#pragma mark Instantiation
+ (nonnull ADJResult<ADJMoneyDecimalAmount *> *)instanceFromIoDecValue:
    (nonnull NSString *)ioDecValue
{
    ADJResult<NSDecimalNumber *> *_Nonnull decimalNumberResult =
        [self convertToDecimalNumberWithIoDecValue:ioDecValue];

    if (decimalNumberResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot create money amount from ioDecValue to decimal number conversion"
                                      key:@"decimal number fail"
                                otherFail:decimalNumberResult.fail];
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

- (nonnull instancetype)initWithDecimalNumberValue:(nonnull NSDecimalNumber *)decimalNumberValue {
    self = [super init];
    _decimalNumberValue = decimalNumberValue;
    
    return self;
}

#pragma mark Public API
#pragma mark - ADJMoneyAmount
- (nonnull NSNumber *)numberValue {
    return self.decimalNumberValue;
}

- (double)doubleValue {
    // TODO: check if decimal -> string -> double would be better (more precise)
    return self.decimalNumberValue.doubleValue;
}

#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            [ADJUtilF usLocaleNumberFormat:self.decimalNumberValue]];
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    int exponent = self.decimalNumberValue.decimalValue._exponent;
    unsigned int length = self.decimalNumberValue.decimalValue._length;
    unsigned int isNegative = self.decimalNumberValue.decimalValue._isNegative;
    unsigned int isCompact = self.decimalNumberValue.decimalValue._isCompact;
    unsigned int reserved = self.decimalNumberValue.decimalValue._reserved;
    
    /* TODO: see if memcpy version should be used instead
     unsigned long long longBits;
     memcpy(&longBits,
     self.decimalNumberValue.decimalValue._mantissa,
     sizeof(unsigned long long));
     */
    unsigned short * mantissaPtr = self.decimalNumberValue.decimalValue._mantissa;
    unsigned long long * longBitsPtr = (unsigned long long *)mantissaPtr;
    unsigned long long longBits = *longBitsPtr;
    
    return [[ADJNonEmptyString alloc]
            initWithConstStringValue:
                [NSString stringWithFormat:@"dec%@ %@ %@ %@ %@ %@",
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
+ (nonnull ADJResult<NSDecimalNumber *> *)convertToDecimalNumberWithIoDecValue:
    (nonnull NSString *)ioDecValue
{
    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:ioDecValue];

    ADJResult<NSNumber *> *_Nonnull exponentResult = [self scanIntWithScanner:scanner];
    if (exponentResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot read 'exponent' for decimal number"
                              wasInputNil:NO
                             builderBlock:^(ADJResultFailBuilder *_Nonnull resultFailBuilder) {
            [resultFailBuilder withKey:@"scan int fail" otherFail:exponentResult.fail];
            [resultFailBuilder withKey:@"ioDecValue" stringValue:ioDecValue]; }];
    }

    ADJResult<NSNumber *> *_Nonnull lengthResult = [self scanIntWithScanner:scanner];
    if (lengthResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot read 'length' for decimal number"
                              wasInputNil:NO
                             builderBlock:^(ADJResultFailBuilder *_Nonnull resultFailBuilder) {
            [resultFailBuilder withKey:@"scan int fail" otherFail:lengthResult.fail];
            [resultFailBuilder withKey:@"ioDecValue" stringValue:ioDecValue]; }];
    }
    ADJResult<NSNumber *> *_Nonnull isNegativeResult = [self scanIntWithScanner:scanner];
    if (isNegativeResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot read 'isNegative' for decimal number"
                              wasInputNil:NO
                             builderBlock:^(ADJResultFailBuilder *_Nonnull resultFailBuilder) {
            [resultFailBuilder withKey:@"scan int fail" otherFail:isNegativeResult.fail];
            [resultFailBuilder withKey:@"ioDecValue" stringValue:ioDecValue]; }];
    }
    ADJResult<NSNumber *> *_Nonnull isCompactResult = [self scanIntWithScanner:scanner];
    if (isCompactResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot read 'isCompact' for decimal number"
                              wasInputNil:NO
                             builderBlock:^(ADJResultFailBuilder *_Nonnull resultFailBuilder) {
            [resultFailBuilder withKey:@"scan int fail" otherFail:isCompactResult.fail];
            [resultFailBuilder withKey:@"ioDecValue" stringValue:ioDecValue]; }];
    }
    ADJResult<NSNumber *> *_Nonnull reservedResult = [self scanIntWithScanner:scanner];
    if (reservedResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot read 'reserved' for decimal number"
                              wasInputNil:NO
                             builderBlock:^(ADJResultFailBuilder *_Nonnull resultFailBuilder) {
            [resultFailBuilder withKey:@"scan int fail" otherFail:reservedResult.fail];
            [resultFailBuilder withKey:@"ioDecValue" stringValue:ioDecValue]; }];
    }

    unsigned long long longBits;
    if (! [scanner scanUnsignedLongLong:&longBits]) {
        return [ADJResult failWithMessage:
                @"Cannot scan valid ull representation of 'longBits' for decimal number"
                                      key:@"ioDecValue"
                              stringValue:ioDecValue];
    }
    if (longBits == ULLONG_MAX){
        return [ADJResult failWithMessage:
                @"Found overflow when scanning ull value of 'longBits' for decimal number"
                                      key:@"ioDecValue"
                              stringValue:ioDecValue];
    }

    NSDecimal dec = {0};
    
    dec._exponent = exponentResult.value.intValue;
    dec._length = (unsigned int)lengthResult.value.intValue;
    dec._isNegative = (unsigned int)isNegativeResult.value.intValue;
    dec._isCompact = (unsigned int)isCompactResult.value.intValue;
    dec._reserved = (unsigned int)reservedResult.value.intValue;
    memcpy(&(dec._mantissa), &longBits, sizeof(unsigned long long));
    
    return [ADJResult okWithValue:[NSDecimalNumber decimalNumberWithDecimal:dec]];
}

+ (nonnull ADJResult<NSNumber *> *)scanIntWithScanner:(nonnull NSScanner *)scanner {
    int intValue;
    if (! [scanner scanInt:&intValue]) {
        return [ADJResult failWithMessage:@"Cannot scan valid int representation"];
    }
    // Contains INT_MAX or INT_MIN on overflow
    if (intValue == INT_MAX || intValue == INT_MIN) {
        return [ADJResult failWithMessage:@"Found overflow when scanning int value"];
    }

    return [ADJResult okWithValue:[NSNumber numberWithInt:intValue]];
}

@end
