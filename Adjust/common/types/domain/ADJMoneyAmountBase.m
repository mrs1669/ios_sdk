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
@implementation ADJMoneyAmountBase
#pragma mark Instantiation
+ (nonnull ADJResult<ADJMoneyAmountBase *> *)
    instanceFromIoValue:(nullable ADJNonEmptyString *)ioValue
{
    if (ioValue == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot create money amount with nil string value"];
    }
    {
        NSString *_Nullable ioMoneyDoubleAmountSubValue =
            [ADJMoneyDoubleAmount ioMoneyDoubleAmountSubValueWithIoValue:ioValue];
        if (ioMoneyDoubleAmountSubValue != nil) {
            return (ADJResult<ADJMoneyAmountBase *> *)
            [ADJMoneyDoubleAmount
             instanceFromIoMoneyDoubleAmountSubValue:ioMoneyDoubleAmountSubValue];
        }
    }
    {
        NSString *_Nullable ioMoneyDecimalAmountSubValue =
            [ADJMoneyDecimalAmount ioMoneyDecimalAmountSubValueWithIoValue:ioValue];
        if (ioMoneyDecimalAmountSubValue != nil) {
            return (ADJResult<ADJMoneyAmountBase *> *)
            [ADJMoneyDecimalAmount
             instanceFromIoMoneyDecimalAmountSubValue:ioMoneyDecimalAmountSubValue];
        }
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
