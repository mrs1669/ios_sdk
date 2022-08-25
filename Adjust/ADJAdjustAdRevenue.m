//
//  ADJAdjustAdRevenue.m
//  Adjust
//
//  Created by Aditi Agrawal on 23/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustAdRevenue.h"

#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSString *source;
 @property (nullable, readonly, strong, nonatomic) NSNumber *revenueAmountDoubleNumber;
 @property (nullable, readonly, strong, nonatomic) NSString *revenueCurrency;
 @property (nullable, readonly, strong, nonatomic) NSNumber *adImpressionsCountIntegerNumber;
 @property (nullable, readonly, strong, nonatomic) NSString *adRevenueNetwork;
 @property (nullable, readonly, strong, nonatomic) NSString *adRevenueUnit;
 @property (nullable, readonly, strong, nonatomic) NSString *adRevenuePlacement;
 @property (nullable, readonly, strong, nonatomic) NSArray<NSString *> *callbackParameterKeyValueArray;
 @property (nullable, readonly, strong, nonatomic) NSArray<NSString *> *partnerParameterKeyValueArray;
 */

@interface ADJAdjustAdRevenue ()
#pragma mark - Internal variables
@property (nonnull, readwrite, strong, nonatomic) NSMutableArray *callbackParametersMut;
@property (nonnull, readwrite, strong, nonatomic) NSMutableArray *partnerParametersMut;

@end

@implementation ADJAdjustAdRevenue
#pragma mark Instantiation
- (nonnull instancetype)initWithSource:(nonnull NSString *)source {
    self = [super init];

    _source = [ADJUtilObj copyStringWithInput:source];

    _callbackParametersMut = [[NSMutableArray alloc] init];
    _partnerParametersMut = [[NSMutableArray alloc] init];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (void)setRevenueWithDouble:(double)revenueAmountDouble
                    currency:(nonnull NSString *)currency {
    _revenueAmountDoubleNumber = @(revenueAmountDouble);
    _revenueCurrency = [ADJUtilObj copyStringWithInput:currency];
}

- (void)setAdImpressionsCountWithInteger:(NSInteger)adImpressionsCount {
    _adImpressionsCountIntegerNumber = @(adImpressionsCount);
}

- (void)setAdRevenueNetwork:(nonnull NSString *)adRevenueNetwork {
    _adRevenueNetwork = [ADJUtilObj copyStringWithInput:adRevenueNetwork];
}

- (void)setAdRevenueUnit:(nonnull NSString *)adRevenueUnit {
    _adRevenueUnit = [ADJUtilObj copyStringWithInput:adRevenueUnit];
}

- (void)setAdRevenuePlacement:(nonnull NSString *)adRevenuePlacement {
    _adRevenuePlacement = [ADJUtilObj copyStringWithInput:adRevenuePlacement];
}

- (void)addCallbackParameterWithKey:(nonnull NSString *)key
                              value:(nonnull NSString *)value {
    @synchronized (self.callbackParametersMut) {
        [self.callbackParametersMut addObject:[ADJUtilObj copyStringForCollectionWithInput:key]];
        [self.callbackParametersMut addObject:[ADJUtilObj copyStringForCollectionWithInput:value]];
    }
}

- (void)addPartnerParameterWithKey:(nonnull NSString *)key
                             value:(nonnull NSString *)value {
    @synchronized (self.partnerParametersMut) {
        [self.partnerParametersMut addObject:[ADJUtilObj copyStringForCollectionWithInput:key]];
        [self.partnerParametersMut addObject:[ADJUtilObj copyStringForCollectionWithInput:value]];
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
