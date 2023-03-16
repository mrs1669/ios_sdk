//
//  ADJV4UserDefaultsData.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJV4UserDefaultsData.h"

#import "ADJUtilUserDefaults.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSData *pushTokenData;
 @property (nullable, readonly, strong, nonatomic) NSString *pushTokenString;
 @property (nullable, readonly, strong, nonatomic) NSNumber *installTrackedNumberBool;
 @property (nullable, readonly, strong, nonatomic) NSNumber *gdprForgetMeNumberBool;
 @property (nullable, readonly, strong, nonatomic) NSURL *deeplinkUrl;
 @property (nullable, readonly, strong, nonatomic) NSDate *deeplinkClickTime;
 @property (nullable, readonly, strong, nonatomic) NSNumber *disableThirdPartySharingNumberBool;
 @property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, NSNumber *> *iAdErrors;
 @property (nullable, readonly, strong, nonatomic) NSNumber *adServicesTrackedNumberBool;
 @property (nullable, readonly, strong, nonatomic) NSDate * skadRegisterCallTimestamp;
 */

NSString *const ADJUserDefaultsV4PushToken = @"adj_push_token";
NSString *const ADJUserDefaultsV4PushTokenString = @"adj_push_token_string";
NSString *const ADJUserDefaultsV4InstallTracked = @"adj_install_tracked";
NSString *const ADJUserDefaultsV4GdprForgetMe = @"adj_gdpr_forget_me";
NSString *const ADJUserDefaultsV4DeeplinkUrk = @"adj_deeplink_url";
NSString *const ADJUserDefaultsV4DeeplinkClickTime = @"adj_deeplink_click_time";
NSString *const ADJUserDefaultsV4DisableThirdPartySharing = @"adj_disable_third_party_sharing";
NSString *const ADJUserDefaultsV4IadErrors = @"adj_iad_errors";
NSString *const ADJUserDefaultsV4AdServicesTracked = @"adj_adservices_tracked";
NSString *const ADJUserDefaultsV4SkadRegisterCallTime = @"adj_skad_register_call_time";

@implementation ADJV4UserDefaultsData
- (nonnull instancetype)initByReadingAll {
    self = [super init];
    
    _pushTokenData = [ADJUtilUserDefaults dataWithKey:ADJUserDefaultsV4PushToken];
    _pushTokenString = [ADJUtilUserDefaults stringWithKey:ADJUserDefaultsV4PushTokenString];
    _installTrackedNumberBool =
        [ADJUtilUserDefaults numberBoolWithKey:ADJUserDefaultsV4InstallTracked];
    _gdprForgetMeNumberBool = [ADJUtilUserDefaults numberBoolWithKey:ADJUserDefaultsV4GdprForgetMe];
    _deeplinkUrl = [ADJUtilUserDefaults urlWithKey:ADJUserDefaultsV4DeeplinkUrk];
    _deeplinkClickTime = [ADJUtilUserDefaults dateWithKey:ADJUserDefaultsV4DeeplinkClickTime];
    _disableThirdPartySharingNumberBool =
        [ADJUtilUserDefaults numberBoolWithKey:ADJUserDefaultsV4DisableThirdPartySharing];
    _iAdErrors = [ADJUtilUserDefaults dictionaryWithKey:ADJUserDefaultsV4IadErrors];
    _adServicesTrackedNumberBool =
        [ADJUtilUserDefaults numberBoolWithKey:ADJUserDefaultsV4AdServicesTracked];
    _skadRegisterCallTimestamp =
        [ADJUtilUserDefaults dateWithKey:ADJUserDefaultsV4SkadRegisterCallTime];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
