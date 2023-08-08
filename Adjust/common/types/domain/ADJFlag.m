//
//  ADJFlag.m
//  Adjust
//
//  Created by Pedro Silva on 10.07.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJFlag.h"

#import "ADJConstants.h"
#import "ADJUtilF.h"

@implementation ADJFlag
+ (nullable ADJFlag *)instanceFromBool:(BOOL)boolValue {
    if (! boolValue) {
        return nil;
    }

    return [ADJFlag singleInstance];
}
/*
+ (nonnull ADJResult<ADJFlag *> *)instanceFromBoolWrapper:
    (nullable ADJBooleanWrapper *)boolWrapperValue
{
    if (boolWrapperValue == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot create flag from nil boolean wrapper"];
    }

    if (! boolWrapperValue.boolValue) {
        return [ADJResult failWithMessage:@"Cannot create flag from false boolean wrapper"];
    }

    return [ADJFlag okResultSingleInstance];
}

+ (nonnull ADJResult<ADJFlag *> *)instanceFromNumberBoolean:
    (nullable NSNumber *)numberBooleanValue
{
    ADJResult<ADJBooleanWrapper *> *_Nonnull boolWrapperResult =
        [ADJBooleanWrapper instanceFromNumberBoolean:numberBooleanValue];

    if (boolWrapperResult.wasInputNil) {
        return [ADJResult nilInputWithMessage:@"Cannot create flag from nil number"];
    }

    if (boolWrapperResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot create flag from invalid number bool"
                                      key:@"boolean conversion fail"
                                otherFail:boolWrapperResult.fail];
    }

    if (! boolWrapperResult.value.boolValue) {
        return [ADJResult failWithMessage:@"Cannot create flag from false number bool"];
    }

    return [self okResultSingleInstance];
}

+ (nonnull ADJResult<ADJFlag *> *)instanceFromIoValue:
    (nullable ADJNonEmptyString *)ioValue
{
    if (ioValue == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot create flag with nil io value"];
    }

    if ([ioValue.stringValue isEqualToString:ADJBooleanTrueJsonString]) {
        return [self okResultSingleInstance];
    }

    return [ADJResult failWithMessage:@"Could not match io value to valid flag value"
                                  key:@"io value"
                          stringValue:ioValue.stringValue];
}

+ (nonnull ADJResult<ADJFlag *> *)instanceFromString:(nullable NSString *)stringValue {
    ADJResult<ADJNonEmptyString *> *_Nonnull flagStringResult =
        [ADJNonEmptyString instanceFromString:stringValue];

    if (flagStringResult.wasInputNil) {
        return [ADJResult nilInputWithMessage:@"Cannot create flag with nil string"];
    }
    if (flagStringResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot create flag with invalid string"
                                      key:@"string fail"
                                otherFail:flagStringResult.fail];
    }

    return [ADJFlag instanceFromIoValue:flagStringResult.value];
}

+ (nonnull ADJResult<ADJFlag *> *)instanceFromObject:(nullable id)objectValue {
    if (objectValue == nil) {
        return [ADJResult nilInputWithMessage:
                @"Cannot create flag wrapper with nil object value"];
    }

    if (! [objectValue isKindOfClass:[NSNumber class]]) {
        return [ADJResult failWithMessage:@"Cannot create string from non-NSNumber object for flag"
                                      key:ADJLogActualKey
                              stringValue:NSStringFromClass([objectValue class])];
    }

    return [ADJResult okWithValue:
            [ADJFlag instanceFromNumberBoolean:(NSNumber *)objectValue]];
}
*/

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithSingleInstance {
    self = [super init];

    return self;
}

+ (nonnull ADJFlag *)singleInstance {
    static dispatch_once_t onceSingleInstanceToken;
    static ADJFlag * singleInstance;
    dispatch_once(&onceSingleInstanceToken, ^{
        singleInstance = [[ADJFlag alloc] initWithSingleInstance];
    });
    return singleInstance;
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

/*
+ (nonnull ADJResult<ADJFlag *> *)okResultSingleInstance {
    static dispatch_once_t onceOkResultSingleInstanceToken;
    static ADJResult<ADJFlag *> * okResultSingleInstance;
    dispatch_once(&onceOkResultSingleInstanceToken, ^{
        okResultSingleInstance = [ADJResult okWithValue:[ADJFlag singleInstance]];
    });
    return okResultSingleInstance;
}


#pragma mark Public API
- (nonnull NSString *)jsonString {
    return ADJBooleanTrueJsonString;
}
 */

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    return [ADJFlag trueString];
}

#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    // TODO: change all boolean values to be "true"/"false" instead of "0"/"1" in the backend
    return [ADJFlag trueString];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilF boolFormat:YES];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + [@(YES) hash];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJFlag class]]) {
        return NO;
    }

    return YES;
}

@end
