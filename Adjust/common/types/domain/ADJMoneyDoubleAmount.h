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
#import "ADJLogger.h"
#import "ADJNonEmptyString.h"

@interface ADJMoneyDoubleAmount : ADJMoneyAmountBase
// instantiation
+ (nullable instancetype)instanceFromIoLlfValue:(nonnull NSString *)ioLlfValue
                                         logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromDoubleNumberValue:(nullable NSNumber *)doubleNumberValue
                                                logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromOptionalDoubleNumberValue:(nullable NSNumber *)doubleNumberValue
                                                        logger:(nonnull ADJLogger *)logger;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSNumber *doubleNumberValue;

@end
