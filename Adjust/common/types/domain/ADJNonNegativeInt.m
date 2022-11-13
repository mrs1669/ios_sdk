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

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (readonly, assign, nonatomic) NSUInteger nsuIntegerValue;
 */

@implementation ADJNonNegativeInt
#pragma mark Instantiation
+ (nonnull instancetype)instanceAtZero {
    return [self zeroInstance];
}

+ (nonnull instancetype)instanceAtOne {
    return [self oneInstance];
}

+ (nullable instancetype)instanceFromIntegerNumber:(nullable NSNumber *)integerNumber
                                            logger:(nonnull ADJLogger *)logger {
    return [self instanceFromIntegerNumber:integerNumber
                                    logger:logger
                                isOptional:NO];
}

+ (nullable instancetype)instanceFromOptionalIntegerNumber:(nullable NSNumber *)integerNumber
                                                    logger:(nonnull ADJLogger *)logger {
    return [self instanceFromIntegerNumber:integerNumber
                                    logger:logger
                                isOptional:YES];
    
}

+ (nullable instancetype)instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
                                          logger:(nonnull ADJLogger *)logger {
    return [self instanceFromIoDataValue:ioDataValue
                                  logger:logger
                              isOptional:NO];
}

+ (nullable instancetype)instanceFromOptionalIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
                                                  logger:(nonnull ADJLogger *)logger {
    return [self instanceFromIoDataValue:ioDataValue
                                  logger:logger
                              isOptional:YES];
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

#pragma mark - Private constructors
+ (nonnull instancetype)zeroInstance {
    static dispatch_once_t zeroInstanceToken;
    static id zeroInstance;
    dispatch_once(&zeroInstanceToken, ^{
        zeroInstance = [[self alloc] initWithUIntegerValue:0];
    });
    return zeroInstance;
}

+ (nonnull instancetype)oneInstance {
    static dispatch_once_t oneInstanceToken;
    static id oneInstance;
    dispatch_once(&oneInstanceToken, ^{
        oneInstance = [[self alloc] initWithUIntegerValue:1];
    });
    return oneInstance;
}

+ (nullable instancetype)instanceFromIntegerNumber:(nullable NSNumber *)integerNumber
                                            logger:(nonnull ADJLogger *)logger
                                        isOptional:(BOOL)isOptional
{
    if (integerNumber == nil) {
        if (! isOptional) {
            [logger debugDev:@"Cannot create non negative int with nil integer number value"
                   issueType:ADJIssueInvalidInput];
        }
        return nil;
    }
    
    if (integerNumber.integerValue < 0) {
        [logger debugDev:@"Cannot create non negative int with negative value"
                     key:@"number"
                   value:[ADJUtilF integerFormat:integerNumber.integerValue].description
               issueType:ADJIssueInvalidInput];
        return nil;
    }
    
    return [[self alloc] initWithUIntegerValue:integerNumber.unsignedIntegerValue];
}

+ (nullable instancetype)instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
                                          logger:(nonnull ADJLogger *)logger
                                      isOptional:(BOOL)isOptional
{
    if (ioDataValue == nil) {
        if (! isOptional) {
            [logger debugDev:@"Cannot create non negative int with IoData value"
                   issueType:ADJIssueStorageIo];
        }
        return nil;
    }
    
    return [self instanceFromIntegerNumber:
            [ADJUtilConv convertToIntegerNumberWithStringValue:ioDataValue.stringValue]
                                    logger:logger
                                isOptional:isOptional];
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

