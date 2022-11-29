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
@property (nonnull, readwrite, strong, nonatomic)NSMutableDictionary *granularOptionsByNameDictMut;
@property (nonnull, readwrite, strong, nonatomic)NSMutableDictionary *partnerSharingSettingsByNameDictMut;

@end

@implementation ADJAdjustThirdPartySharing
#pragma mark Instantiation
- (nonnull instancetype)init {
    self = [super init];

    _enabledOrElseDisabledSharingNumberBool = nil;

    _granularOptionsByNameDictMut = [[NSMutableDictionary alloc] init];
    _partnerSharingSettingsByNameDictMut = [[NSMutableDictionary alloc] init];

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
    NSMutableDictionary *granularOptions = [self.granularOptionsByNameDictMut objectForKey:partnerName];
    if (granularOptions == nil) {
        granularOptions = [[NSMutableDictionary alloc] init];
        [self.granularOptionsByNameDictMut setObject:granularOptions forKey:partnerName];
    }

    [granularOptions setObject:value forKey:key];
}

- (void)addPartnerSharingSettingWithPartnerName:(nonnull NSString *)partnerName
                                     key:(nonnull NSString *)key
                                   value:(BOOL)value {
    NSMutableDictionary *partnerSharingSetting = [self.partnerSharingSettingsByNameDictMut objectForKey:partnerName];
    if (partnerSharingSetting == nil) {
        partnerSharingSetting = [[NSMutableDictionary alloc] init];
        [self.partnerSharingSettingsByNameDictMut setObject:partnerSharingSetting forKey:partnerName];
    }

    [partnerSharingSetting setObject:[NSNumber numberWithBool:value] forKey:key];
}


#pragma mark - Generated properties
- (nullable NSDictionary *)granularOptionsByNameDictionary {
    @synchronized (self.granularOptionsByNameDictMut) {
        if (self.granularOptionsByNameDictMut.count == 0) {
            return nil;
        }
        return [self.granularOptionsByNameDictMut copy];
    }
}

- (nullable NSDictionary *)partnerSharingSettingsByNameDictionary {
    @synchronized (self.partnerSharingSettingsByNameDictMut) {
        if (self.partnerSharingSettingsByNameDictMut.count == 0) {
            return nil;
        }
        return  [self.partnerSharingSettingsByNameDictMut copy];
    }
}

@end

