//
//  ADJNonEmptyString.m
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJNonEmptyString.h"

#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSString *stringValue;
 */

@implementation ADJNonEmptyString
#pragma mark Instantiation
+ (nonnull ADJResult<ADJNonEmptyString *> *)
    instanceFromString:(nullable NSString *)stringValue
{
    if (stringValue == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot create string with null"];
    }

    if ([stringValue length] == 0) {
        return [ADJResult failWithMessage:@"Cannot create empty string"];
    }

    return [ADJResult okWithValue:
            [[ADJNonEmptyString alloc] initWithConstStringValue:stringValue]];
}
+ (nonnull ADJResult<ADJNonEmptyString *> *)
    instanceFromObject:(nullable id)objectValue
{
    if (objectValue == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot create string with null object"];
    }

    if (! [objectValue isKindOfClass:[NSString class]]) {
        return [ADJResult failWithMessage:@"Cannot create string from non-string object"
                                      key:ADJLogActualKey
                              stringValue:NSStringFromClass([objectValue class])];
    }

    return [ADJNonEmptyString instanceFromString:(NSString *)objectValue];
}

- (nonnull instancetype)initWithConstStringValue:(nonnull NSString *)constStringValue {
    self = [super init];
    
    _stringValue = constStringValue;
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    return self;
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    return self;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return self.stringValue;
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    
    hashCode = ADJHashCodeMultiplier * hashCode + [self.stringValue hash];
    
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[ADJNonEmptyString class]]) {
        return NO;
    }
    
    ADJNonEmptyString *other = (ADJNonEmptyString *)object;
    return [ADJUtilObj objectEquals:self.stringValue other:other.stringValue];
}

@end
