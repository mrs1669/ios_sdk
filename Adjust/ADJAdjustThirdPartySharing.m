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

    NSMutableDictionary *granularOptions = [self.granularOptionsByNameDictMut
                                            objectForKey:[ADJUtilObj copyStringForCollectionWithInput:partnerName]];
    if (granularOptions == nil) {
        granularOptions = [[NSMutableDictionary alloc] init];
        [self.granularOptionsByNameDictMut setObject:granularOptions
                                              forKey:[ADJUtilObj copyStringForCollectionWithInput:partnerName]];
    }

    [granularOptions setObject:[ADJUtilObj copyStringForCollectionWithInput:value] forKey:[ADJUtilObj copyStringForCollectionWithInput:key]];
}

- (void)addPartnerSharingSettingWithPartnerName:(nonnull NSString *)partnerName
                                            key:(nonnull NSString *)key
                                          value:(BOOL)value {

    NSMutableDictionary *partnerSharingSettings = [self.partnerSharingSettingsByNameDictMut
                                                  objectForKey:[ADJUtilObj copyStringForCollectionWithInput:partnerName]];
    if (partnerSharingSettings == nil) {
        partnerSharingSettings = [[NSMutableDictionary alloc] init];
        [self.partnerSharingSettingsByNameDictMut setObject:partnerSharingSettings
                                                     forKey:[ADJUtilObj copyStringForCollectionWithInput:partnerName]];
    }

    [partnerSharingSettings setObject:[NSNumber numberWithBool:value] forKey:[ADJUtilObj copyStringForCollectionWithInput:key]];
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

