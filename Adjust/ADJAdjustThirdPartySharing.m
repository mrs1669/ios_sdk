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
 @property (nullable, readonly, strong, nonatomic) NSArray<NSString *> *granularOptionsByNameArray;
 */

@interface ADJAdjustThirdPartySharing ()
#pragma mark - Internal variables
@property (nonnull, readwrite, strong, nonatomic)NSMutableArray<NSString *> *granularOptionsByNameArrayMut;

@end

@implementation ADJAdjustThirdPartySharing
#pragma mark Instantiation
- (nonnull instancetype)init {
    self = [super init];

    _enabledOrElseDisabledSharingNumberBool = nil;

    _granularOptionsByNameArrayMut = [[NSMutableArray alloc] init];

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
         [ADJUtilObj copyStringForCollectionWithInput:partnerName]];
        [self.granularOptionsByNameArrayMut addObject:
         [ADJUtilObj copyStringForCollectionWithInput:key]];
        [self.granularOptionsByNameArrayMut addObject:
         [ADJUtilObj copyStringForCollectionWithInput:value]];
    }
}

#pragma mark - Generated properties
- (nullable NSArray<NSString *> *)granularOptionMapByName {
    @synchronized (self.granularOptionsByNameArrayMut) {
        if (self.granularOptionsByNameArrayMut.count == 0) {
            return nil;
        }
        return [self.granularOptionsByNameArrayMut copy];
    }
}

@end
