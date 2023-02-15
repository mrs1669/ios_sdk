//
//  ADJMoney.h
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJMoneyAmountBase.h"
#import "ADJNonEmptyString.h"
#import "ADJLogger.h"

@interface ADJMoney : NSObject
// instantiation
+ (nullable instancetype)instanceFromAmountDoubleNumber:(nullable NSNumber *)amountDoubleNumber
                                               currency:(nullable NSString *)currency
                                                 source:(nonnull NSString *)source
                                                 logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromAmountDecimalNumber:(nullable NSDecimalNumber *)amountDecimalNumber
                                                currency:(nullable NSString *)currency
                                                  source:(nonnull NSString *)source
                                                  logger:(nonnull ADJLogger *)logger;

- (nonnull instancetype)initWithAmount:(nonnull ADJMoneyAmountBase *)amount
                              currency:(nonnull ADJNonEmptyString *)currency
NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJMoneyAmountBase *amount;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *currency;

@end
