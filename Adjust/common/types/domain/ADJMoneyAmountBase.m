//
//  ADJMoneyAmountBase.m
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMoneyAmountBase.h"

#import "ADJUtilF.h"
#import "ADJConstants.h"
#import "ADJMoneyDoubleAmount.h"
#import "ADJMoneyDecimalAmount.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSNumber *numberValue;
 @property (readonly, assign, nonatomic) double doubleValue;
 */

@implementation ADJMoneyAmountBase
#pragma mark Instantiation
+ (nonnull ADJResultNN<ADJMoneyAmountBase *> *)
    instanceFromIoValue:(nullable ADJNonEmptyString *)ioValue
{
    if (ioValue == nil) {
        return [ADJResultNN failWithMessage:@"Cannot create money amount with nil string value"];
    }

    if ([ioValue.stringValue hasPrefix:@"llf"]) {
        return (ADJResultNN<ADJMoneyAmountBase *> *)
            [ADJMoneyDoubleAmount instanceFromIoLlfValue:
             [ioValue.stringValue substringFromIndex:3]];
    }

    if ([ioValue.stringValue hasPrefix:@"dec"]) {
        return (ADJResultNN<ADJMoneyAmountBase *> *)
            [ADJMoneyDecimalAmount instanceFromIoDecValue:
             [ioValue.stringValue substringFromIndex:3]];
    }

    return [ADJResultNN failWithMessage:
            [NSString stringWithFormat:
                 @"Cannot create money amount without a valid io data value prefix: %@",
            ioValue.stringValue]];
}

+ (nonnull ADJResultNL<ADJMoneyAmountBase *> *)instanceFromOptionalIoValue:
    (nullable ADJNonEmptyString *)ioValue
{
    return [ADJResultNL instanceFromNN:^ADJResultNN *_Nonnull(ADJNonEmptyString *_Nullable value) {
        return [ADJMoneyAmountBase instanceFromIoValue:value];
    } nlValue:ioValue];
}

- (nonnull instancetype)init {
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJMoneyAmountBase class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    
    self = [super init];
    
    return self;
}

#pragma mark Public API
#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

@end
