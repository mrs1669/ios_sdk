//
//  ADJAdjustBillingSubscription.h
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJAdjustBillingSubscription : NSObject
// instantiation
- (nonnull instancetype)initWithPriceDecimalNumber:(nonnull NSDecimalNumber *)priceDecimalNumber
                                          currency:(nonnull NSString *)currency
                                     transactionId:(nonnull NSString *)transactionId
                                       receiptData:(nonnull NSData *)receiptData
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)setTransactionDate:(nonnull NSDate *)transactionDate;

- (void)setSalesRegion:(nonnull NSString *)salesRegion;

- (void)addCallbackParameterWithKey:(nonnull NSString *)key
                              value:(nonnull NSString *)value;
- (void)addPartnerParameterWithKey:(nonnull NSString *)key
                             value:(nonnull NSString *)value;

// public properties
@property (nullable, readonly, strong, nonatomic) NSDecimalNumber *priceDecimalNumber;
@property (nullable, readonly, strong, nonatomic) NSString *currency;
@property (nullable, readonly, strong, nonatomic) NSString *transactionId;
@property (nullable, readonly, strong, nonatomic) NSData *receiptData;
@property (nullable, readonly, strong, nonatomic) NSDate *transactionDate;
@property (nullable, readonly, strong, nonatomic) NSString *salesRegion;
@property (nullable, readonly, strong, nonatomic) NSArray<NSString *> *callbackParameterKeyValueArray;
@property (nullable, readonly, strong, nonatomic) NSArray<NSString *> *partnerParameterKeyValueArray;

@end

