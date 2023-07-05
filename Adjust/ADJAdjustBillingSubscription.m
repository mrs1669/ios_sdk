//
//  ADJAdjustBillingSubscription.m
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustBillingSubscription.h"

#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSDecimalNumber *priceDecimalNumber;
 @property (nullable, readonly, strong, nonatomic) NSString *currency;
 @property (nullable, readonly, strong, nonatomic) NSString *transactionId;
 @property (nullable, readonly, strong, nonatomic) NSData *receiptData;
 @property (nullable, readonly, strong, nonatomic) NSDate *transactionDate;
 @property (nullable, readonly, strong, nonatomic) NSString *salesRegion;
 @property (nullable, readonly, strong, nonatomic)
 NSArray<NSString *> *callbackParameterKeyValueArray;
 @property (nullable, readonly, strong, nonatomic)
 NSArray<NSString *> *partnerParameterKeyValueArray;
 */

@interface ADJAdjustBillingSubscription ()
#pragma mark - Internal variables
@property (nonnull, readwrite, strong, nonatomic) NSMutableArray<NSString *> *callbackParametersMut;
@property (nonnull, readwrite, strong, nonatomic) NSMutableArray<NSString *> *partnerParametersMut;

@end

@implementation ADJAdjustBillingSubscription
#pragma mark Instantiation
- (nonnull instancetype)initWithPriceDecimalNumber:(nonnull NSDecimalNumber *)priceDecimalNumber
                                          currency:(nonnull NSString *)currency
                                     transactionId:(nonnull NSString *)transactionId
                                       receiptData:(nonnull NSData *)receiptData {
    self = [super init];

    _priceDecimalNumber = [ADJUtilObj copyObjectWithInput:priceDecimalNumber
                                              classObject:[NSDecimalNumber class]];
    _currency = [ADJUtilObj copyStringWithInput:currency];
    _transactionId = [ADJUtilObj copyStringWithInput:transactionId];
    _receiptData = [ADJUtilObj copyObjectWithInput:receiptData
                                       classObject:[NSData class]];
    _callbackParametersMut = [[NSMutableArray alloc] init];
    _partnerParametersMut = [[NSMutableArray alloc] init];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (void)setTransactionDate:(nonnull NSDate *)transactionDate {
    _transactionDate = [ADJUtilObj copyObjectWithInput:transactionDate
                                           classObject:[NSDate class]];
}

- (void)setSalesRegion:(nonnull NSString *)salesRegion {
    _salesRegion = [ADJUtilObj copyStringWithInput:salesRegion];
}

- (void)addCallbackParameterWithKey:(nonnull NSString *)key
                              value:(nonnull NSString *)value {
    @synchronized (self.callbackParametersMut) {
        [self.callbackParametersMut addObject:[ADJUtilObj copyStringOrNSNullWithInput:key]];
        [self.callbackParametersMut addObject:
         [ADJUtilObj copyStringOrNSNullWithInput:value]];
    }
}

- (void)addPartnerParameterWithKey:(nonnull NSString *)key
                             value:(nonnull NSString *)value {
    @synchronized (self.partnerParametersMut) {
        [self.partnerParametersMut addObject:[ADJUtilObj copyStringOrNSNullWithInput:key]];
        [self.partnerParametersMut addObject:
         [ADJUtilObj copyStringOrNSNullWithInput:value]];
    }
}

#pragma mark - Generated properties
- (nullable NSArray<NSString *> *)callbackParameterKeyValueArray {
    @synchronized (self.callbackParametersMut) {
        if (self.callbackParametersMut.count == 0) {
            return nil;
        }
        return [self.callbackParametersMut copy];
    }
}

- (nullable NSArray<NSString *> *)partnerParameterKeyValueArray {
    @synchronized (self.partnerParametersMut) {
        if (self.partnerParametersMut.count == 0) {
            return nil;
        }
        return [self.partnerParametersMut copy];
    }
}

@end

