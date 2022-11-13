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
+ (nullable instancetype)instanceFromString:(nullable NSString *)stringValue
                          sourceDescription:(nonnull NSString *)sourceDescription
                                     logger:(nonnull ADJLogger *)logger
{
    return [ADJNonEmptyString instanceWithStringValue:stringValue
                                    sourceDescription:sourceDescription
                                               logger:logger
                                           isOptional:NO];
}

+ (nullable instancetype)instanceFromOptionalString:(nullable NSString *)stringValue
                                  sourceDescription:(nonnull NSString *)sourceDescription
                                             logger:(nonnull ADJLogger *)logger {
    return [ADJNonEmptyString instanceWithStringValue:stringValue
                                    sourceDescription:sourceDescription
                                               logger:logger
                                           isOptional:YES];
}

+ (nullable instancetype)instanceWithStringValue:(nullable NSString *)stringValue
                               sourceDescription:(nonnull NSString *)sourceDescription
                                          logger:(nonnull ADJLogger *)logger
                                      isOptional:(BOOL)isOptional
{
    if (stringValue == nil) {
        if (! isOptional) {
            [logger debugDev:@"Cannot create NonEmptyString with nil value"
                        from:sourceDescription
                   issueType:ADJIssueUnexpectedInput];
        }
        
        return nil;
    }
    
    if ([stringValue length] == 0) {
        [logger debugDev:@"Cannot create NonEmptyString with empty value"
                    from:sourceDescription
               issueType:ADJIssueUnexpectedInput];
        return nil;
    }
    
    return [[ADJNonEmptyString alloc] initWithConstStringValue:stringValue];
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
