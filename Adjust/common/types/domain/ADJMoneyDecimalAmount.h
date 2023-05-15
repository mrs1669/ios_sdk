//
//  ADJMoneyDecimalAmount.h
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJMoneyAmountBase.h"
#import "ADJPackageParamValueSerializable.h"
#import "ADJIoValueSerializable.h"
#import "ADJResult.h"

@interface ADJMoneyDecimalAmount : ADJMoneyAmountBase
// instantiation
+ (nonnull ADJResult<ADJMoneyDecimalAmount *> *)
    instanceFromIoMoneyDecimalAmountSubValue:(nonnull NSString *)ioMoneyDecimalAmountSubValue;

+ (nonnull ADJResult<ADJMoneyDecimalAmount *> *)instanceFromDecimalNumberValue:
    (nullable NSDecimalNumber *)decimalNumberValue;

+ (nullable NSString *)ioMoneyDecimalAmountSubValueWithIoValue:
    (nonnull ADJNonEmptyString *)ioValue;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSDecimalNumber *decimalNumberValue;

@end
