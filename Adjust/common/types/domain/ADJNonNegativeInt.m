//
//  ADJNonNegativeInt.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJNonNegativeInt.h"

#import "ADJUtilF.h"
#import "ADJUtilConv.h"
#import "ADJConstants.h"

//#import "ADJResultFail.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (readonly, assign, nonatomic) NSUInteger nsuIntegerValue;
 */

@implementation ADJNonNegativeInt
#pragma mark Instantiation
+ (nonnull instancetype)instanceAtZero {
    static dispatch_once_t zeroInstanceToken;
    static id zeroInstance;
    dispatch_once(&zeroInstanceToken, ^{
        zeroInstance = [[self alloc] initWithUIntegerValue:0];
    });
    return zeroInstance;
}

+ (nonnull instancetype)instanceAtOne {
    static dispatch_once_t oneInstanceToken;
    static id oneInstance;
    dispatch_once(&oneInstanceToken, ^{
        oneInstance = [[self alloc] initWithUIntegerValue:1];
    });
    return oneInstance;
}

+ (nonnull ADJResultNN<ADJNonNegativeInt *> *)
    instanceFromIntegerNumber:(nullable NSNumber *)integerNumber
{
    if (integerNumber == nil) {
        return [ADJResultNN failWithMessage:
                @"Cannot create non negative int with nil integer number"];
    }

    if (integerNumber.integerValue < 0) {
        return [ADJResultNN failWithMessage:
                [self failMessageWithNegativeIntegerNumber:integerNumber]];
    }

    return [ADJResultNN okWithValue:
            [[ADJNonNegativeInt alloc] initWithUIntegerValue:integerNumber.unsignedIntegerValue]];
}

+ (nonnull ADJResultNL<ADJNonNegativeInt *> *)
    instanceFromOptionalIntegerNumber:(nullable NSNumber *)integerNumber
{
    if (integerNumber == nil) {
        return [ADJResultNL okWithoutValue];
    }

    if (integerNumber.integerValue < 0) {
        return [ADJResultNL failWithMessage:
                [self failMessageWithNegativeIntegerNumber:integerNumber]];
    }

    return [ADJResultNL okWithValue:
            [[ADJNonNegativeInt alloc] initWithUIntegerValue:integerNumber.unsignedIntegerValue]];

}
+ (nonnull NSString *)
    failMessageWithNegativeIntegerNumber:(nonnull NSNumber *)negativeIntegerNumber
{
    return [NSString stringWithFormat:
            @"Cannot create non negative int with negative value: %@",
            [ADJUtilF integerFormat:negativeIntegerNumber.integerValue]];
}

+ (nonnull ADJResultNN<ADJNonNegativeInt *> *)
    instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
{
    if (ioDataValue == nil) {
        return [ADJResultNN failWithMessage:
                @"Cannot create non negative int with nil io value"];
    }

    ADJResultNN<NSNumber *> *_Nonnull integerNumberResult =
        [ADJUtilConv convertToIntegerNumberWithStringValue:ioDataValue.stringValue];
    if (integerNumberResult.fail != nil) {
        return [ADJResultNN failWithMessage:
                    @"Cannot create non negative int from io data value"
                                        key:@"integer from io value fail"
                                      value:[integerNumberResult foundationDictionary]];
    }

    return [self instanceFromIntegerNumber:integerNumberResult.value];
}
+ (nonnull ADJResultNL<ADJNonNegativeInt *> *)
    instanceFromOptionalIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
{
    if (ioDataValue == nil) {
        return [ADJResultNL okWithoutValue];
    }

    ADJResultNN<NSNumber *> *_Nonnull integerNumberResult =
        [ADJUtilConv convertToIntegerNumberWithStringValue:ioDataValue.stringValue];
    if (integerNumberResult.fail != nil) {
        return [ADJResultNL failWithMessage:integerNumberResult.fail.message
                                 failParams:integerNumberResult.fail.params
                                  failError:integerNumberResult.fail.error
                              failException:integerNumberResult.fail.exception];
    }

    return [self instanceFromOptionalIntegerNumber:integerNumberResult.value];
}
+ (nonnull NSString *)
    failMessageFromConversionWithFailMessage:(nonnull NSString *)failMessage
{
    return [NSString stringWithFormat:@"Could not convert from string to integer: %@", failMessage];
}

- (nonnull instancetype)initWithUIntegerValue:(NSUInteger)uIntegerValue {
    self = [super init];

    _uIntegerValue = uIntegerValue;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull ADJNonEmptyString *)toNonEmptyString {
    return [[ADJNonEmptyString alloc] initWithConstStringValue:self.description];
}

- (NSComparisonResult)compare:(nonnull ADJNonNegativeInt *)nonNegativeInt {
    return [@(self.uIntegerValue) compare:@(nonNegativeInt.uIntegerValue)];
}

- (BOOL)isZero {
    return self.uIntegerValue == 0;
}

- (BOOL)isMaxValue {
    return self.uIntegerValue == NSUIntegerMax;
}

#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    if (self.uIntegerValue == 0) {
        return nil;
    }
    return [self toNonEmptyString];
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    return [self toNonEmptyString];
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilF uIntegerFormat:self.uIntegerValue];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    
    hashCode = ADJHashCodeMultiplier * hashCode + (NSUInteger)self.uIntegerValue;
    
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[ADJNonNegativeInt class]]) {
        return NO;
    }
    
    ADJNonNegativeInt *other = (ADJNonNegativeInt *)object;
    return self.uIntegerValue == other.uIntegerValue;
}

@end
