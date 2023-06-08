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
#import "ADJResult.h"

@interface ADJMoneyDoubleAmount : ADJMoneyAmountBase
// instantiation
+ (nonnull ADJResult<ADJMoneyDoubleAmount *> *)
    instanceFromIoLlfValue:(nonnull NSString *)ioLlfValue;

+ (nonnull ADJResult<ADJMoneyDoubleAmount *> *)
    instanceFromDoubleNumberValue:(nullable NSNumber *)doubleNumberValue;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSNumber *doubleNumberValue;

@end
