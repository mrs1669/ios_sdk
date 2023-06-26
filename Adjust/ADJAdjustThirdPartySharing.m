//
//  ADJAdjustThirdPartySharing.m
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustThirdPartySharing.h"

#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSNumber *enabledOrElseDisabledSharingNumberBool;
 @property (nullable, readonly, strong, nonatomic) NSArray *granularOptionsByNameArray;
 @property (nullable, readonly, strong, nonatomic) NSArray *partnerSharingSettingsByNameArray;
 */

@interface ADJAdjustThirdPartySharing ()
#pragma mark - Internal variables
@property (nullable, readonly, strong, nonatomic) NSMutableArray *granularOptionsByNameArrayMut;
@property (nullable, readonly, strong, nonatomic) NSMutableArray *partnerSharingSettingsByNameArrayMut;

@end

@implementation ADJAdjustThirdPartySharing
#pragma mark Instantiation
- (nonnull instancetype)init {
    self = [super init];

    _enabledOrElseDisabledSharingNumberBool = nil;
    _granularOptionsByNameArrayMut = [[NSMutableArray alloc] init];
    _partnerSharingSettingsByNameArrayMut = [[NSMutableArray alloc] init];

    return self;
}

#pragma mark Public API
- (void)enableThirdPartySharing {
    _enabledOrElseDisabledSharingNumberBool = @(YES);
}

- (void)disableThirdPartySharing {
    _enabledOrElseDisabledSharingNumberBool = @(NO);
}

- (void)addGranularOptionWithPartnerName:(nonnull NSString *)partnerName
                                     key:(nonnull NSString *)key
                                   value:(nonnull NSString *)value {
    @synchronized (self.granularOptionsByNameArrayMut) {
        [self.granularOptionsByNameArrayMut addObject:
         [ADJUtilObj copyStringOrNSNullWithInput:partnerName]];
        [self.granularOptionsByNameArrayMut addObject:
         [ADJUtilObj copyStringOrNSNullWithInput:key]];
        [self.granularOptionsByNameArrayMut addObject:
         [ADJUtilObj copyStringOrNSNullWithInput:value]];
    }
}

- (void)addPartnerSharingSettingWithPartnerName:(nonnull NSString *)partnerName
                                            key:(nonnull NSString *)key
                                          value:(BOOL)value {
    @synchronized (self.partnerSharingSettingsByNameArrayMut) {
        [self.partnerSharingSettingsByNameArrayMut addObject:
         [ADJUtilObj copyStringOrNSNullWithInput:partnerName]];
        [self.partnerSharingSettingsByNameArrayMut addObject:
         [ADJUtilObj copyStringOrNSNullWithInput:key]];
        [self.partnerSharingSettingsByNameArrayMut addObject:
         [NSNumber numberWithBool:value]];
    }
}

#pragma mark - Generated properties
- (nullable NSArray *)granularOptionsByNameArray {
    @synchronized (self.granularOptionsByNameArrayMut) {
        if (self.granularOptionsByNameArrayMut.count == 0) {
            return nil;
        }
        return [self.granularOptionsByNameArrayMut copy];
    }
}

- (nullable NSArray *)partnerSharingSettingsByNameArray {
    @synchronized (self.partnerSharingSettingsByNameArrayMut) {
        if (self.partnerSharingSettingsByNameArrayMut.count == 0) {
            return nil;
        }
        return [self.partnerSharingSettingsByNameArrayMut copy];
    }
}

@end

