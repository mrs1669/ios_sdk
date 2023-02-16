//
//  ADJMoneyDoubleAmount.h
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
#import "ADJResultNL.h"

@interface ADJMoneyDoubleAmount : ADJMoneyAmountBase
// instantiation
+ (nonnull ADJResultNN<ADJMoneyDoubleAmount *> *)
    instanceFromIoLlfValue:(nonnull NSString *)ioLlfValue;

+ (nonnull ADJResultNN<ADJMoneyDoubleAmount *> *)
    instanceFromDoubleNumberValue:(nullable NSNumber *)doubleNumberValue;

+ (nonnull ADJResultNL<ADJMoneyDoubleAmount *> *)
    instanceFromOptionalDoubleNumberValue:(nullable NSNumber *)doubleNumberValue;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSNumber *doubleNumberValue;

@end
