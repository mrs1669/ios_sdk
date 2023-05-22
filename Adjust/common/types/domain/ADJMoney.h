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

/*
 attribution
    double number
 event
    double number
    decimal number
    string
 ad revenue
    double
    decimal number
 billing subscription
    decimal number
    string


 ADJMoneyAmountBase
    number value
    - client ad revenue
        from io value to adjustAdRevenue
    - attribution data
        to adjust attribution

    double value
    - client event
        from io value to adjust revenue
        (also reads decimal number when casted)

Money.amount
    [x description]
    inject io value serializable
    inject param value serializable


Change:
    Replace Money Amount Base with Money Amount protocol
        still implement ADJPackageParamValueSerializable and ADJIoValueSerializable
    Use and inject id<MoneyAmount> when reading from io data/value
    Use double amount directly in Attribution
    Add string money amount
 */
