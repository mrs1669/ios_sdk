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
#import "ADJLogger.h"
#import "ADJNonEmptyString.h"

@interface ADJMoneyDecimalAmount : ADJMoneyAmountBase
// instantiation
+ (nullable instancetype)instanceFromIoDecValue:(nonnull NSString *)ioDecValue
                                         logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromDecimalNumberValue:(nullable NSDecimalNumber *)decimalNumberValue
                                                 logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromOptionalDecimalNumberValue:(nullable NSDecimalNumber *)decimalNumberValue logger:(nonnull ADJLogger *)logger;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSDecimalNumber *decimalNumberValue;

@end
