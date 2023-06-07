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
#import "ADJResultNN.h"

@interface ADJMoneyDecimalAmount : ADJMoneyAmountBase
// instantiation
+ (nonnull ADJResultNN<ADJMoneyDecimalAmount *> *)
    instanceFromIoDecValue:(nonnull NSString *)ioDecValue;

+ (nonnull ADJResultNN<ADJMoneyDecimalAmount *> *)instanceFromDecimalNumberValue:
    (nullable NSDecimalNumber *)decimalNumberValue;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSDecimalNumber *decimalNumberValue;

@end
