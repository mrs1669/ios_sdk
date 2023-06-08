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

//#import "ADJResultFail.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJMoneyAmountBase *amount;
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *currency;
 */

@implementation ADJMoney
#pragma mark Instantiation
+ (nonnull ADJResult<ADJMoney *> *)
    instanceFromAmountDoubleNumber:(nullable NSNumber *)amountDoubleNumber
    currency:(nullable NSString *)currency
{
    ADJResult<ADJMoneyDoubleAmount *> *_Nonnull moneyDoubleAmountResult =
        [ADJMoneyDoubleAmount instanceFromDoubleNumberValue:amountDoubleNumber];

    if (moneyDoubleAmountResult.failNonNilInput != nil) {
        return [ADJResult failWithMessage:
                @"Cannot create money instance without valid double amount"
                                      key:@"double amount fail"
                                otherFail:moneyDoubleAmountResult.fail];
    }

    return [ADJMoney instanceFromMoneyAmount:moneyDoubleAmountResult.value
                                    currency:currency];
}

+ (nonnull ADJResult<ADJMoney *> *)
    instanceFromAmountDecimalNumber:(nullable NSDecimalNumber *)amountDecimalNumber
    currency:(nullable NSString *)currency
{
    ADJResult<ADJMoneyDecimalAmount *> *_Nonnull moneyDecimalAmountResult =
        [ADJMoneyDecimalAmount instanceFromDecimalNumberValue:amountDecimalNumber];

    if (moneyDecimalAmountResult.failNonNilInput != nil) {
        return [ADJResult failWithMessage:
                @"Cannot create money instance without valid decimal amount"
                                      key:@"decimal amount fail"
                                otherFail:moneyDecimalAmountResult.fail];
    }

    return [ADJMoney instanceFromMoneyAmount:moneyDecimalAmountResult.value
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
+ (nonnull ADJResult<ADJMoney *> *)
    instanceFromMoneyAmount:(nullable ADJMoneyAmountBase *)moneyAmount
    currency:(nullable NSString *)currency
{
    ADJResult<ADJNonEmptyString *> *_Nonnull currencyResult =
        [ADJNonEmptyString instanceFromString:currency];

    if (currencyResult.failNonNilInput != nil) {
        return [ADJResult failWithMessage:@"Cannot create money instance with invalid currency"
                                      key:@"currency fail"
                                otherFail:currencyResult.fail];
    }

    if (currencyResult.wasInputNil && moneyAmount == nil) {
        return [ADJResult nilInputWithMessage:
                @"Cannot create money instance without currency and amount"];
    }
    if (currencyResult.wasInputNil) {
        return [ADJResult failWithMessage:@"Cannot create money instance without currency"];
    }
    if (moneyAmount == nil) {
        return [ADJResult failWithMessage:@"Cannot create money instance without amount"];
    }

    return [ADJResult okWithValue:
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
