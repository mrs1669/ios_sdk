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

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSNumber *doubleNumberValue;
 */

@implementation ADJMoneyDoubleAmount
#pragma mark Instantiation
+ (nullable instancetype)instanceFromIoLlfValue:(nonnull NSString *)ioLlfValue
                                         logger:(nonnull ADJLogger *)logger {
    NSNumber *_Nullable doubleNumberValue =
    [self convertToDoubleNumberWithIoLlfValue:ioLlfValue];
    
    return [self instanceFromDoubleNumberValue:doubleNumberValue
                                        logger:logger];
}

+ (nullable instancetype)instanceFromDoubleNumberValue:(nullable NSNumber *)doubleNumberValue
                                                logger:(nonnull ADJLogger *)logger {
    return [self instanceFromDoubleNumberValue:doubleNumberValue
                                        logger:logger
                                    isOptional:NO];
}

+ (nullable instancetype)instanceFromOptionalDoubleNumberValue:(nullable NSNumber *)doubleNumberValue
                                                        logger:(nonnull ADJLogger *)logger {
    return [self instanceFromDoubleNumberValue:doubleNumberValue
                                        logger:logger
                                    isOptional:YES];
}

#pragma mark - Private constructors
+ (nullable instancetype)instanceFromDoubleNumberValue:(nullable NSNumber *)doubleNumberValue
                                                logger:(nonnull ADJLogger *)logger
                                            isOptional:(BOOL)isOptional {
    if (doubleNumberValue == nil) {
        if (! isOptional) {
            [logger debugDev:@"Cannot create money amount with nil double number value"
                   issueType:ADJIssueInvalidInput];
        }
        return nil;
    }
    
    if ([ADJUtilF isNotANumber:doubleNumberValue]) {
        [logger debugDev:@"Cannot create money amount with invalid double number"
                     key:@"doubleNumberValue"
                   value:doubleNumberValue.description
               issueType:ADJIssueInvalidInput];
        return nil;
    }
    
    if (doubleNumberValue.doubleValue != 0.0 && ! isnormal(doubleNumberValue.doubleValue)) {
        [logger debugDev:@"Cannot create money amount with invalid double number"
                     key:@"doubleNumberValue"
                   value:doubleNumberValue.description
               issueType:ADJIssueInvalidInput];
        return nil;
    }
    
    if (doubleNumberValue.doubleValue < 0.0) {
        [logger debugDev:@"Cannot create money amount with negative double number"
                     key:@"doubleNumberValue"
                   value:doubleNumberValue.description
               issueType:ADJIssueInvalidInput];
        return nil;
    }
    
    return [[self alloc] initWithDoubleNumberValue:doubleNumberValue];
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
            [self.doubleNumberValue descriptionWithLocale:[ADJUtilF usLocale]]];
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
+ (nullable NSNumber *)convertToDoubleNumberWithIoLlfValue:(nonnull NSString *)ioLlfValue {
    NSNumber *_Nullable llNumber = [ADJUtilConv convertToLLNumberWithStringValue:ioLlfValue];
    if (llNumber == nil) {
        return nil;
    }
    
    long long llValue = llNumber.longLongValue;
    
    double * doublePtr = (double *)&llValue;
    
    double doubleValue = *(doublePtr);
    
    return @(doubleValue);
}

+ (BOOL)isDoubleValidWithValue:(double)doubleValue {
    if (doubleValue == 0.0) {
        return YES;
    }
    
    return isnormal(doubleValue) ? YES : NO;
}

@end
