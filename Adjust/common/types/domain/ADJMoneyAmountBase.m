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
+ (nonnull ADJResult<ADJMoneyAmountBase *> *)
    instanceFromIoValue:(nullable ADJNonEmptyString *)ioValue
{
    if (ioValue == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot create money amount with nil string value"];
    }

    if ([ioValue.stringValue hasPrefix:@"llf"]) {
        ADJResult<ADJMoneyDoubleAmount *> *_Nonnull llfDoubleResult =
            [ADJMoneyDoubleAmount instanceFromIoLlfValue:
             [ioValue.stringValue substringFromIndex:3]];
        // cast to result of parent class, should be safe, just not supported directly in obj-c
        return (ADJResult<ADJMoneyAmountBase *> *)llfDoubleResult;
    }

    if ([ioValue.stringValue hasPrefix:@"dec"]) {
        ADJResult<ADJMoneyDecimalAmount *> *_Nonnull decDecimalResult =
            [ADJMoneyDecimalAmount instanceFromIoDecValue:
             [ioValue.stringValue substringFromIndex:3]];
        // cast to result of parent class, should be safe, just not supported directly in obj-c
        return (ADJResult<ADJMoneyAmountBase *> *)decDecimalResult;
    }

    return [ADJResult failWithMessage:
            [NSString stringWithFormat:
                 @"Cannot create money amount without a valid io data value prefix: %@",
            ioValue.stringValue]];
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
