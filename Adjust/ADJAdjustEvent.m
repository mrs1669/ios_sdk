//
//  ADJAdjustEvent.m
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustEvent.h"

#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSString *eventId;
 @property (nullable, readonly, strong, nonatomic) NSDecimalNumber *revenueAmountDecimalNumber;
 @property (nullable, readonly, strong, nonatomic) NSString *revenueCurrency;
 @property (nullable, readonly, strong, nonatomic)
 NSArray<NSString *> *callbackParameterKeyValueArray;
 @property (nullable, readonly, strong, nonatomic)
 NSArray<NSString *> *partnerParameterKeyValueArray;
 @property (nullable, readonly, strong, nonatomic) NSString *deduplicationId;
 */

@interface ADJAdjustEvent ()
#pragma mark - Internal variables
@property (nonnull, readwrite, strong, nonatomic)
NSMutableArray *callbackParametersMut;
@property (nonnull, readwrite, strong, nonatomic)
NSMutableArray *partnerParametersMut;

@end

@implementation ADJAdjustEvent

#pragma mark - Instantiation
- (nonnull instancetype)initWithEventId:(nonnull NSString *)eventId {
    self = [super init];
    
    _eventId = [ADJUtilObj copyStringWithInput:eventId];
    _callbackParametersMut = [[NSMutableArray alloc] init];
    _partnerParametersMut = [[NSMutableArray alloc] init];
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Public API
- (void)setRevenueWithDouble:(double)revenueAmountDouble
                    currency:(nonnull NSString *)currency {
    _revenueAmountDoubleNumber = @(revenueAmountDouble);
    _revenueCurrency = [ADJUtilObj copyStringWithInput:currency];
}

- (void)setRevenueWithDoubleNumber:(nonnull NSNumber *)revenueAmountDoubleNumber
                          currency:(nonnull NSString *)currency {
    _revenueAmountDoubleNumber = [ADJUtilObj copyObjectWithInput:revenueAmountDoubleNumber
                                                     classObject:[NSNumber class]];
    
    _revenueCurrency = [ADJUtilObj copyStringWithInput:currency];
}

- (void)setRevenueWithNSDecimalNumber:(nonnull NSDecimalNumber *)revenueAmountDecimalNumber
                             currency:(nonnull NSString *)currency {
    _revenueAmountDecimalNumber = [ADJUtilObj copyObjectWithInput:revenueAmountDecimalNumber
                                                      classObject:[NSDecimalNumber class]];
    _revenueCurrency = [ADJUtilObj copyStringWithInput:currency];
}

- (void)addCallbackParameterWithKey:(nonnull NSString *)key
                              value:(nonnull NSString *)value {
    @synchronized (self.callbackParametersMut) {
        [self.callbackParametersMut addObject:[ADJUtilObj copyStringForCollectionWithInput:key]];
        [self.callbackParametersMut addObject:
         [ADJUtilObj copyStringForCollectionWithInput:value]];
    }
}

- (void)addPartnerParameterWithKey:(nonnull NSString *)key
                             value:(nonnull NSString *)value {
    @synchronized (self.partnerParametersMut) {
        [self.partnerParametersMut addObject:[ADJUtilObj copyStringForCollectionWithInput:key]];
        [self.partnerParametersMut addObject:
         [ADJUtilObj copyStringForCollectionWithInput:value]];
    }
}

- (void)setDeduplicationId:(nonnull NSString *)deduplicationId {
    _deduplicationId = [ADJUtilObj copyStringWithInput:deduplicationId];
}

#pragma mark - Generated properties
- (nullable NSArray *)callbackParameterKeyValueArray {
    @synchronized (self.callbackParametersMut) {
        if (self.callbackParametersMut.count == 0) {
            return nil;
        }
        return [self.callbackParametersMut copy];
    }
}

- (nullable NSArray *)partnerParameterKeyValueArray {
    @synchronized (self.partnerParametersMut) {
        if (self.partnerParametersMut.count == 0) {
            return nil;
        }
        return [self.partnerParametersMut copy];
    }
}

@end
