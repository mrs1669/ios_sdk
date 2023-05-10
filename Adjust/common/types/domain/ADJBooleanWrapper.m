//
//  ADJBooleanWrapper.m
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJBooleanWrapper.h"

#import "ADJConstants.h"
#import "ADJUtilF.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (readonly, assign, nonatomic) BOOL boolValue;
 @property (nonnull, readonly, strong, nonatomic) NSNumber *numberBoolValue;
 @property (nonnull, readonly, strong, nonatomic) NSString *jsonString;
 */

#pragma mark - Public constants
NSString *const ADJBooleanTrueJsonString = @"true";
NSString *const ADJBooleanFalseJsonString = @"false";

@implementation ADJBooleanWrapper
#pragma mark Instantiation
+ (nonnull instancetype)instanceFromBool:(BOOL)boolValue {
    return boolValue ? [self trueInstance] : [self falseInstance];
}

+ (nonnull ADJResult<ADJBooleanWrapper *> *)instanceFromNumberBoolean:
    (nullable NSNumber *)numberBooleanValue
{
    if (numberBooleanValue == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot create boolean with nil number boolean"];
    }

    /** TODO: test if it works for:
     - @(YES)/@(NO)
     - [NSNumber numberWithBool:]
     - (json string -> json dictionary with json boolean value)
        - from IoData serialization/desiralization
        - backend/fakend json parsing
        - webview json
     */

    if ((__bridge CFBooleanRef)numberBooleanValue == kCFBooleanTrue) {
        return [ADJResult okWithValue:[self trueInstance]];
    }
    if ((__bridge CFBooleanRef)numberBooleanValue == kCFBooleanFalse) {
        return [ADJResult okWithValue:[self falseInstance]];
    }

    return [ADJResult failWithMessage:
            @"Number value does not seem to have been created from boolean"
                                  key:@"CFNumberType value"
                          stringValue:[ADJUtilF longFormat:
                                       CFNumberGetType((CFNumberRef)numberBooleanValue)]];
}

+ (nonnull ADJResult<ADJBooleanWrapper *> *)instanceFromIoValue:
    (nullable ADJNonEmptyString *)ioValue
{
    if (ioValue == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot create boolean wrapper with nil io value"];
    }

    if ([ioValue.stringValue isEqualToString:ADJBooleanTrueJsonString]) {
        return [ADJResult okWithValue:[self trueInstance]];
    }

    if ([ioValue.stringValue isEqualToString:ADJBooleanFalseJsonString]) {
        return [ADJResult okWithValue:[self falseInstance]];
    }

    return [ADJResult failWithMessage:@"Could not match io value to valid boolean value"
                                  key:@"io value"
                          stringValue:ioValue.stringValue];
}

+ (nonnull ADJResult<ADJBooleanWrapper *> *)instanceFromString:(nullable NSString *)stringValue {
    ADJResult<ADJNonEmptyString *> *_Nonnull booleanStringResult =
        [ADJNonEmptyString instanceFromString:stringValue];

    if (booleanStringResult.wasInputNil) {
        return [ADJResult nilInputWithMessage:@"Cannot create boolean with nil string"];
    }
    if (booleanStringResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot create boolean with invalid string"
                                      key:@"string fail"
                                otherFail:booleanStringResult.fail];
    }

    return [ADJBooleanWrapper instanceFromIoValue:booleanStringResult.value];
}

+ (nonnull ADJResult<ADJBooleanWrapper *> *)instanceFromObject:(nullable id)objectValue {
    if (objectValue == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot create boolean wrapper with nil object value"];
    }

    if (! [objectValue isKindOfClass:[NSNumber class]]) {
        return [ADJResult failWithMessage:@"Cannot create string from non-NSNumber object"
                                      key:ADJLogActualKey
                              stringValue:NSStringFromClass([objectValue class])];
    }

    NSNumber *_Nonnull booleanNumber = (NSNumber *)objectValue;

    return [ADJResult okWithValue:[ADJBooleanWrapper instanceFromBool:booleanNumber.boolValue]];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
+ (nonnull ADJBooleanWrapper *)trueInstance {
    static dispatch_once_t onceTrueInstanceToken;
    static ADJBooleanWrapper * trueInstance;
    dispatch_once(&onceTrueInstanceToken, ^{
        trueInstance = [[ADJBooleanWrapper alloc] initWithBoolValue:YES];
    });
    return trueInstance;
}

+ (nonnull ADJBooleanWrapper *)falseInstance {
    static dispatch_once_t onceFalseInstanceToken;
    static ADJBooleanWrapper * falseInstance;
    dispatch_once(&onceFalseInstanceToken, ^{
        falseInstance = [[ADJBooleanWrapper alloc] initWithBoolValue:NO];
    });
    return falseInstance;
}

+ (nonnull ADJNonEmptyString *)trueString {
    static dispatch_once_t onceTrueStringToken;
    static ADJNonEmptyString * trueString;
    dispatch_once(&onceTrueStringToken, ^{
        trueString = [[ADJNonEmptyString alloc]
                      initWithConstStringValue:ADJBooleanTrueJsonString];
    });
    return trueString;
}

+ (nonnull ADJNonEmptyString *)falseString {
    static dispatch_once_t onceFalseStringToken;
    static ADJNonEmptyString * falseString;
    dispatch_once(&onceFalseStringToken, ^{
        falseString = [[ADJNonEmptyString alloc]
                       initWithConstStringValue:ADJBooleanFalseJsonString];
    });
    return falseString;
}

- (nonnull instancetype)initWithBoolValue:(BOOL)boolValue {
    self = [super init];

    _boolValue = boolValue;
    _numberBoolValue = [NSNumber numberWithBool:boolValue];

    return self;
}

#pragma mark Public API
- (nonnull NSString *)jsonString {
    return self.boolValue ? ADJBooleanTrueJsonString : ADJBooleanFalseJsonString;
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    return self.boolValue ? [ADJBooleanWrapper trueString] : [ADJBooleanWrapper falseString];
}

#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    // TODO: change all boolean values to be "true"/"false" instead of "0"/"1" in the backend
    return self.boolValue ? [ADJBooleanWrapper trueString] : [ADJBooleanWrapper falseString];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilF boolFormat:self.boolValue];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + [@(self.boolValue) hash];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJBooleanWrapper class]]) {
        return NO;
    }

    ADJBooleanWrapper *other = (ADJBooleanWrapper *)object;
    return self.boolValue == other.boolValue;
}

@end
