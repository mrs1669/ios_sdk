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
+ (nullable instancetype)instanceFromIoDecValue:(nonnull NSString *)ioDecValue
                                         logger:(nonnull ADJLogger *)logger {
    NSDecimalNumber *_Nullable decimalNumberValue =
    [self convertToDecimalNumberWithIoDecValue:ioDecValue];
    
    return [self instanceFromDecimalNumberValue:decimalNumberValue
                                         logger:logger];
}

+ (nullable instancetype)instanceFromDecimalNumberValue:(nullable NSDecimalNumber *)decimalNumberValue
                                                 logger:(nonnull ADJLogger *)logger {
    return [self instanceFromDecimalNumberValue:decimalNumberValue
                                         logger:logger
                                     isOptional:NO];
}

+ (nullable instancetype)instanceFromOptionalDecimalNumberValue:(nullable NSDecimalNumber *)decimalNumberValue
                                                         logger:(nonnull ADJLogger *)logger {
    return [self instanceFromDecimalNumberValue:decimalNumberValue
                                         logger:logger
                                     isOptional:YES];
}

#pragma mark - Private constructors
+ (nullable instancetype)instanceFromDecimalNumberValue:(nullable NSDecimalNumber *)decimalNumberValue
                                                 logger:(nonnull ADJLogger *)logger
                                             isOptional:(BOOL)isOptional {
    if (decimalNumberValue == nil) {
        if (! isOptional) {
            [logger debugDev:@"Cannot create money amount with nil decimal number value"
                   issueType:ADJIssueInvalidInput];
        }
        return nil;
    }
    
    if ([ADJUtilF isNotANumber:decimalNumberValue]) {
        [logger debugDev:@"Cannot create money amount with invalid decimal number"
                     key:@"decimalNumberValue"
                   value:decimalNumberValue.description
               issueType:ADJIssueInvalidInput];
        return nil;
    }
    
    BOOL isDecimalNegative =
        [decimalNumberValue compare:[NSDecimalNumber zero]] == NSOrderedAscending;
    if (isDecimalNegative) {
        [logger debugDev:@"Cannot create money amount with negative"
                     key:@"decimalNumberValue"
                   value:decimalNumberValue.description
               issueType:ADJIssueInvalidInput];
        return nil;
    }
    
    return [[self alloc] initWithDecimalNumberValue:decimalNumberValue];
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
    // TODO check if decimal -> string -> double would be better (more precise)
    return self.decimalNumberValue.doubleValue;
}

#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            [self.decimalNumberValue descriptionWithLocale:[ADJUtilF usLocale]]];
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    int exponent = self.decimalNumberValue.decimalValue._exponent;
    unsigned int length = self.decimalNumberValue.decimalValue._length;
    unsigned int isNegative = self.decimalNumberValue.decimalValue._isNegative;
    unsigned int isCompact = self.decimalNumberValue.decimalValue._isCompact;
    unsigned int reserved = self.decimalNumberValue.decimalValue._reserved;
    
    /* TODO see if memcpy version should be used instead
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

#define scanIntWithName(name)                                               \
int name;                                                               \
if (! [scanner scanInt:&name] || name == INT_MAX || name == INT_MIN) {  \
return nil;                                                         \
}                                                                       \

+ (nullable NSDecimalNumber *)convertToDecimalNumberWithIoDecValue:(nonnull NSString *)ioDecValue {
    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:ioDecValue];
    
    scanIntWithName(exponent)
    scanIntWithName(length)
    scanIntWithName(isNegative)
    scanIntWithName(isCompact)
    scanIntWithName(reserved)
    
    unsigned long long longBits;
    if (! [scanner scanUnsignedLongLong:&longBits] || longBits == ULLONG_MAX)
    {
        return nil;
    }
    
    NSDecimal dec = {0};
    
    dec._exponent = exponent;
    dec._length = (unsigned int)length;
    dec._isNegative = (unsigned int)isNegative;
    dec._isCompact = (unsigned int)isCompact;
    dec._reserved = (unsigned int)reserved;
    memcpy(&(dec._mantissa), &longBits, sizeof(unsigned long long));
    
    return [NSDecimalNumber decimalNumberWithDecimal:dec];
}

@end
