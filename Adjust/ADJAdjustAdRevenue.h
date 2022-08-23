//
//  ADJAdjustAdRevenue.h
//  Adjust
//
//  Created by Aditi Agrawal on 23/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJAdRevenueSourceAppLovinMax;
FOUNDATION_EXPORT NSString *const ADJAdRevenueSourceMopub;
FOUNDATION_EXPORT NSString *const ADJAdRevenueSourceAdmob;
FOUNDATION_EXPORT NSString *const ADJAdRevenueSourceIronsource;

NS_ASSUME_NONNULL_END

@interface ADJAdjustAdRevenue : NSObject
// instantiation
- (nonnull instancetype)initWithSource:(nonnull NSString *)source;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)setRevenueWithDouble:(double)revenueAmountDouble
                    currency:(nonnull NSString *)currency;
- (void)setRevenueWithDoubleNumber:(nonnull NSNumber *)revenueAmountDoubleNumber
                          currency:(nonnull NSString *)currency;

- (void)setAdImpressionsCountWithInteger:(NSInteger)adImpressionsCount;
- (void)setAdImpressionsCountWithIntegerNumber:(nonnull NSNumber *)adImpressionsCountIntegerNumber;

- (void)setAdRevenueNetwork:(nonnull NSString *)adRevenueNetwork;

- (void)setAdRevenueUnit:(nonnull NSString *)adRevenueUnit;

- (void)setAdRevenuePlacement:(nonnull NSString *)adRevenuePlacement;

- (void)addCallbackParameterWithKey:(nonnull NSString *)key
                              value:(nonnull NSString *)value;
- (void)addPartnerParameterWithKey:(nonnull NSString *)key
                             value:(nonnull NSString *)value;

// public properties
@property (nullable, readonly, strong, nonatomic) NSString *source;
@property (nullable, readonly, strong, nonatomic) NSNumber *revenueAmountDoubleNumber;
@property (nullable, readonly, strong, nonatomic) NSString *revenueCurrency;
@property (nullable, readonly, strong, nonatomic) NSNumber *adImpressionsCountIntegerNumber;
@property (nullable, readonly, strong, nonatomic) NSString *adRevenueNetwork;
@property (nullable, readonly, strong, nonatomic) NSString *adRevenueUnit;
@property (nullable, readonly, strong, nonatomic) NSString *adRevenuePlacement;
@property (nullable, readonly, strong, nonatomic) NSArray<NSString *> *callbackParameterKeyValueArray;
@property (nullable, readonly, strong, nonatomic) NSArray<NSString *> *partnerParameterKeyValueArray;

@end


