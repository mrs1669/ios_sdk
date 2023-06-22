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
+ (nonnull ADJResult<ADJMoney *> *)
    instanceFromAmountDoubleNumber:(nullable NSNumber *)amountDoubleNumber
    currency:(nullable NSString *)currency;

+ (nonnull ADJResult<ADJMoney *> *)
    instanceFromAmountDecimalNumber:(nullable NSDecimalNumber *)amountDecimalNumber
    currency:(nullable NSString *)currency;

+ (nonnull ADJResult<ADJMoney *> *)
    instanceFromAmount:(nullable ADJMoneyAmountBase *)amount
    currency:(nullable NSString *)currency;

+ (nonnull ADJResult<ADJMoney *> *)
    instanceFromAmountIoValue:(nullable ADJNonEmptyString *)amountIoValue
    currencyIoValue:(nullable ADJNonEmptyString *)currencyIoValue;

- (nonnull instancetype)initWithAmount:(nonnull ADJMoneyAmountBase *)amount
                              currency:(nonnull ADJNonEmptyString *)currency
NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJMoneyAmountBase *amount;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *currency;

@end
