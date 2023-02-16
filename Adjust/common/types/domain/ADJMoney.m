//
//  ADJMoney.m
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMoney.h"

#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJMoneyDoubleAmount.h"
#import "ADJMoneyDecimalAmount.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJMoneyAmountBase *amount;
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *currency;
 */

@implementation ADJMoney
#pragma mark Instantiation
+ (nonnull ADJResultNN<ADJMoney *> *)
    instanceFromAmountDoubleNumber:(nullable NSNumber *)amountDoubleNumber
    currency:(nullable NSString *)currency
{
    ADJResultNN<ADJMoneyDoubleAmount *> *_Nonnull moneyDoubleAmountResult =
        [ADJMoneyDoubleAmount instanceFromDoubleNumberValue:amountDoubleNumber];

    if (moneyDoubleAmountResult.failMessage != nil) {
        return [ADJResultNN failWithMessage:
                [NSString stringWithFormat:
                 @"Cannot create money instance without valid double amount: %@",
                 moneyDoubleAmountResult.failMessage]];
    }

    return [ADJMoney instanceFromMoneyAmount:moneyDoubleAmountResult.value
                                    currency:currency];
}

+ (nonnull ADJResultNN<ADJMoney *> *)
    instanceFromAmountDecimalNumber:(nullable NSDecimalNumber *)amountDecimalNumber
    currency:(nullable NSString *)currency
{
    ADJResultNN<ADJMoneyDecimalAmount *> *_Nonnull moneyDecimalAmountResult =
        [ADJMoneyDecimalAmount instanceFromDecimalNumberValue:amountDecimalNumber];

    if (moneyDecimalAmountResult.failMessage != nil) {
        return [ADJResultNN failWithMessage:
                [NSString stringWithFormat:
                 @"Cannot create money instance without valid decimal amount: %@",
                 moneyDecimalAmountResult.failMessage]];
    }

    return [self instanceFromMoneyAmount:moneyDecimalAmountResult.value
                                currency:currency];
}

- (nonnull instancetype)initWithAmount:(nonnull ADJMoneyAmountBase *)amount
                              currency:(nonnull ADJNonEmptyString *)currency {
    self = [super init];

    _amount = amount;
    _currency = currency;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
+ (nonnull ADJResultNN<ADJMoney *> *)
    instanceFromMoneyAmount:(nonnull ADJMoneyAmountBase *)moneyAmount
    currency:(nullable NSString *)currency
{
    ADJResultNN<ADJNonEmptyString *> *_Nonnull currencyResult =
        [ADJNonEmptyString instanceFromString:currency];

    if (currencyResult.failMessage != nil) {
        return [ADJResultNN failWithMessage:
                [NSString stringWithFormat:
                 @"Cannot create money instance without valid currency: %@",
                 currencyResult.failMessage]];
    }

    return [ADJResultNN okWithValue:
            [[ADJMoney alloc] initWithAmount:moneyAmount currency:currencyResult.value]];
}

#pragma mark Public API
#pragma mark - NSObject
- (nonnull NSString *)description {
    return [NSString stringWithFormat:@"{amount = %@, currency = %@}",
            self.amount, self.currency];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + self.amount.hash;
    hashCode = ADJHashCodeMultiplier * hashCode + self.currency.hash;

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJMoney class]]) {
        return NO;
    }

    ADJMoney *other = (ADJMoney *)object;
    return [ADJUtilObj objectEquals:self.amount other:other.amount]
    && [ADJUtilObj objectEquals:self.currency other:other.currency];
}

@end
