//
//  ADJAdjustThirdPartySharing.h
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJAdjustThirdPartySharing : NSObject
// instantiation
- (nonnull instancetype)init;

// public api
- (void)enableThirdPartySharing;
- (void)disableThirdPartySharing;

- (void)addGranularOptionWithPartnerName:(nonnull NSString *)partnerName
                                     key:(nonnull NSString *)key
                                   value:(nonnull NSString *)value;

- (void)addPartnerSharingSettingWithPartnerName:(nonnull NSString *)partnerName
                                     key:(nonnull NSString *)key
                                   value:(BOOL)value;

// public properties
@property (nullable, readonly, strong, nonatomic) NSNumber *enabledOrElseDisabledSharingNumberBool;
@property (nullable, readonly, strong, nonatomic) NSDictionary *granularOptionsByNameDictionary;
@property (nullable, readonly, strong, nonatomic) NSDictionary *partnerSharingSettingsByNameDictionary;

@end


//private @NonNull final Map<String, Map<String, Boolean>> partnerSharingSettingsMap;
