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
+ (nullable instancetype)instanceFromAmountDoubleNumber:(nullable NSNumber *)amountDoubleNumber
                                               currency:(nullable NSString *)currency
                                                 source:(nonnull NSString *)source
                                                 logger:(nonnull ADJLogger *)logger
{
    ADJMoneyDoubleAmount *_Nullable moneyDoubleAmount =
        [ADJMoneyDoubleAmount instanceFromDoubleNumberValue:amountDoubleNumber
                                                 logger:logger];
    
    if (moneyDoubleAmount == nil) {
        [logger debugDev:@"Cannot create money instance without valid double amount"
                    from:source
               issueType:ADJIssueInvalidInput];
        return nil;
    }
    
    return [self instanceFromMoneyAmount:moneyDoubleAmount
                                currency:currency
                                  source:source
                                  logger:logger];
}

+ (nullable instancetype)
    instanceFromAmountDecimalNumber:(nullable NSDecimalNumber *)amountDecimalNumber
    currency:(nullable NSString *)currency
    source:(nonnull NSString *)source
    logger:(nonnull ADJLogger *)logger
{
    ADJMoneyDecimalAmount *_Nullable moneyDecimalAmount =
        [ADJMoneyDecimalAmount instanceFromDecimalNumberValue:amountDecimalNumber
                                                       logger:logger];
    
    if (moneyDecimalAmount == nil) {
        [logger debugDev:@"Cannot create money instance without valid decimal amount"
                    from:source
               issueType:ADJIssueInvalidInput];
        return nil;
    }
    
    return [self instanceFromMoneyAmount:moneyDecimalAmount
                                currency:currency
                                  source:source
                                  logger:logger];
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
+ (nullable instancetype)instanceFromMoneyAmount:(nonnull ADJMoneyAmountBase *)moneyAmount
                                        currency:(nullable NSString *)currency
                                          source:(nonnull NSString *)source
                                          logger:(nonnull ADJLogger *)logger {
    ADJNonEmptyString *_Nullable currencyNonEmptyString =
    [ADJNonEmptyString instanceFromString:currency
                        sourceDescription:source
                                   logger:logger];
    
    if (currencyNonEmptyString == nil) {
        [logger debugDev:@"Cannot create money instance without valid decimal currency"
                    from:source
               issueType:ADJIssueInvalidInput];
        return nil;
    }
    
    return [[self alloc] initWithAmount:moneyAmount currency:currencyNonEmptyString];
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
