//
//  ADJV4UserDefaultsData.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJV4UserDefaultsData.h"

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
 @property (nullable, readonly, strong, nonatomic) NSNumber *migrationCompletedNumberBool;
 */

NSString *const ADJUserDefaultsPushToken = @"adj_push_token";
NSString *const ADJUserDefaultsPushTokenString = @"adj_push_token_string";
NSString *const ADJUserDefaultsInstallTracked = @"adj_install_tracked";
NSString *const ADJUserDefaultsGdprForgetMe = @"adj_gdpr_forget_me";
NSString *const ADJUserDefaultsDepplinkUrk = @"adj_deeplink_url";
NSString *const ADJUserDefaultsDepplinkClickTime = @"adj_deeplink_click_time";
NSString *const ADJUserDefaultsDisableThirdPartySharing = @"adj_disable_third_party_sharing";
NSString *const ADJUserDefaultsIadErrors = @"adj_iad_errors";
NSString *const ADJUserDefaultsAdServicesTracked = @"adj_adservices_tracked";
NSString *const ADJUserDefaultsSkadRegisterCallTime = @"adj_skad_register_call_time";
NSString *const ADJUserDefaultsMigrationCompleted = @"adj_migration_completed";

@implementation ADJV4UserDefaultsData
- (nonnull instancetype)initWithLogger:(nonnull ADJLogger *)logger {
    self = [super init];
    
    _pushTokenData = [ADJV4UserDefaultsData dataWithKey:ADJUserDefaultsPushToken];
    _pushTokenString = [ADJV4UserDefaultsData stringWithKey:ADJUserDefaultsPushTokenString];
    _installTrackedNumberBool = [ADJV4UserDefaultsData numberBoolWithKey:ADJUserDefaultsInstallTracked];
    _gdprForgetMeNumberBool = [ADJV4UserDefaultsData numberBoolWithKey:ADJUserDefaultsGdprForgetMe];
    _deeplinkUrl = [ADJV4UserDefaultsData urlWithKey:ADJUserDefaultsDepplinkUrk];
    _deeplinkClickTime = [ADJV4UserDefaultsData dateWithKey:ADJUserDefaultsDepplinkClickTime];
    _disableThirdPartySharingNumberBool = [ADJV4UserDefaultsData numberBoolWithKey:ADJUserDefaultsDisableThirdPartySharing];
    _iAdErrors = [ADJV4UserDefaultsData dictionaryWithKey:ADJUserDefaultsIadErrors];
    _adServicesTrackedNumberBool = [ADJV4UserDefaultsData numberBoolWithKey:ADJUserDefaultsAdServicesTracked];
    _skadRegisterCallTimestamp = [ADJV4UserDefaultsData dateWithKey:ADJUserDefaultsSkadRegisterCallTime];
    _migrationCompletedNumberBool = [ADJV4UserDefaultsData numberBoolWithKey:ADJUserDefaultsMigrationCompleted];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)isMigrationCompleted {
    return (self.migrationCompletedNumberBool) ? [self.migrationCompletedNumberBool boolValue] : NO;
}

- (void)setMigrationCompleted {
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:ADJUserDefaultsMigrationCompleted];
}

#pragma mark Internal Methods
+ (nullable NSNumber *)numberBoolWithKey:(nonnull NSString *)key {
    id _Nullable numberBoolValue = [NSUserDefaults.standardUserDefaults objectForKey:key];
    
    if (numberBoolValue == nil || ! [numberBoolValue isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    return (NSNumber *)numberBoolValue;
}

+ (nullable NSString *)stringWithKey:(nonnull NSString *)key {
    id _Nullable stringValue = [NSUserDefaults.standardUserDefaults objectForKey:key];
    
    if (stringValue == nil || ! [stringValue isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    return (NSString *)stringValue;
}

+ (nullable NSData *)dataWithKey:(nonnull NSString *)key {
    id _Nullable dataValue = [NSUserDefaults.standardUserDefaults objectForKey:key];
    
    if (dataValue == nil || ! [dataValue isKindOfClass:[NSData class]]) {
        return nil;
    }
    
    return (NSData *)dataValue;
}

+ (nullable NSDate *)dateWithKey:(nonnull NSString *)key {
    id _Nullable dateValue = [NSUserDefaults.standardUserDefaults objectForKey:key];
    
    if (dateValue == nil || ! [dateValue isKindOfClass:[NSDate class]]) {
        return nil;
    }
    
    return (NSDate *)dateValue;
}

+ (nullable NSURL *)urlWithKey:(nonnull NSString *)key {
    return [NSUserDefaults.standardUserDefaults URLForKey:key];
}

+ (nullable NSDictionary *)dictionaryWithKey:(nonnull NSString *)key {
    return [NSUserDefaults.standardUserDefaults dictionaryForKey:key];
}

+ (void)removeObjectWithKey:(nonnull NSString *)key {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:key];
}

@end
