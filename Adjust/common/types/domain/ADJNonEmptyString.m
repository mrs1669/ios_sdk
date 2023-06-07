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
+ (nonnull ADJResultNN<ADJNonEmptyString *> *)
    instanceFromString:(nullable NSString *)stringValue
{
    if (stringValue == nil) {
        return [ADJResultNN failWithMessage:@"Cannot create string with null"];
    }

    if ([stringValue length] == 0) {
        return [ADJResultNN failWithMessage:@"Cannot create empty string"];
    }

    return [ADJResultNN okWithValue:
            [[ADJNonEmptyString alloc] initWithConstStringValue:stringValue]];
}
+ (nonnull ADJResultNN<ADJNonEmptyString *> *)
    instanceFromObject:(nullable id)objectValue
{
    if (objectValue == nil) {
        return [ADJNonEmptyString instanceFromString:(NSString *)objectValue];
    }

    if (! [objectValue isKindOfClass:[NSString class]]) {
        return [ADJResultNN failWithMessage:@"Cannot create string from non-string object"];
    }

    return [ADJNonEmptyString instanceFromString:(NSString *)objectValue];
}

+ (nonnull ADJResultNL<ADJNonEmptyString *> *)
    instanceFromOptionalString:(nullable NSString *)stringValue
{
    if (stringValue == nil) {
        return [ADJResultNL okWithoutValue];
    }

    if ([stringValue length] == 0) {
        return [ADJResultNL failWithMessage:@"Cannot create empty string"];
    }

    return [ADJResultNL okWithValue:
            [[ADJNonEmptyString alloc] initWithConstStringValue:stringValue]];
}
+ (nonnull ADJResultNL<ADJNonEmptyString *> *)
    instanceFromOptionalObject:(nullable id)objectValue
{
    if (objectValue == nil) {
        return [ADJNonEmptyString instanceFromOptionalString:nil];
    }

    if (! [objectValue isKindOfClass:[NSString class]]) {
        return [ADJResultNL failWithMessage:@"Cannot create string from non-string object"];
    }

    return [ADJNonEmptyString instanceFromOptionalString:(NSString *)objectValue];
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
