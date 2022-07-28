//
//  ADJAdjustEvent.h
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJAdjustEvent : NSObject
// instantiation
- (nonnull instancetype)initWithEventId:(nonnull NSString *)eventId
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)setRevenueWithDouble:(double)revenueAmountDouble
                    currency:(nonnull NSString *)currency;
- (void)setRevenueWithDoubleNumber:(nonnull NSNumber *)revenueAmountDoubleNumber
                          currency:(nonnull NSString *)currency;
- (void)setRevenueWithNSDecimalNumber:(nonnull NSDecimalNumber *)revenueAmountDecimalNumber
                             currency:(nonnull NSString *)currency;

- (void)addCallbackParameterWithKey:(nonnull NSString *)key
                              value:(nonnull NSString *)value;
- (void)addPartnerParameterWithKey:(nonnull NSString *)key
                             value:(nonnull NSString *)value;

- (void)setDeduplicationId:(nonnull NSString *)deduplicationId;

// public properties
@property (nullable, readonly, strong, nonatomic) NSString *eventId;
@property (nullable, readonly, strong, nonatomic) NSNumber *revenueAmountDoubleNumber;
@property (nullable, readonly, strong, nonatomic) NSDecimalNumber *revenueAmountDecimalNumber;
@property (nullable, readonly, strong, nonatomic) NSString *revenueCurrency;
@property (nullable, readonly, strong, nonatomic) NSArray<NSString *> *callbackParameterKeyValueArray;
@property (nullable, readonly, strong, nonatomic) NSArray<NSString *> *partnerParameterKeyValueArray;
@property (nullable, readonly, strong, nonatomic) NSString *deduplicationId;

@end
