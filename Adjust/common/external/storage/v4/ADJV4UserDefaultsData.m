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
 @property (nullable, readonly, strong, nonatomic)
 NSDictionary<NSString *, NSNumber *> *iAdErrors;
 @property (nullable, readonly, strong, nonatomic) NSNumber *adServicesTrackedNumberBool;
 @property (nullable, readonly, strong, nonatomic) NSDate * skadRegisterCallTimestamp;
 */

@implementation ADJV4UserDefaultsData
- (nonnull instancetype)initWithLogger:(nonnull ADJLogger *)logger {
    self = [super init];
    
    _pushTokenData = [ADJV4UserDefaultsData dataWithKey:@"adj_push_token"];
    
    _pushTokenString = [ADJV4UserDefaultsData stringWithKey:@"adj_push_token_string"];
    
    _installTrackedNumberBool = [ADJV4UserDefaultsData numberBoolWithKey:@"adj_install_tracked"];
    
    _gdprForgetMeNumberBool = [ADJV4UserDefaultsData numberBoolWithKey:@"adj_gdpr_forget_me"];
    
    _deeplinkUrl = [ADJV4UserDefaultsData urlWithKey:@"adj_deeplink_url"];
    
    _deeplinkClickTime = [ADJV4UserDefaultsData dateWithKey:@"adj_deeplink_click_time"];
    
    _disableThirdPartySharingNumberBool =
    [ADJV4UserDefaultsData numberBoolWithKey:@"adj_disable_third_party_sharing"];
    
    _iAdErrors = [ADJV4UserDefaultsData dictionaryWithKey:@"adj_iad_errors"];
    
    _adServicesTrackedNumberBool =
    [ADJV4UserDefaultsData numberBoolWithKey:@"adj_adservices_tracked"];
    
    _skadRegisterCallTimestamp = [ADJV4UserDefaultsData dateWithKey:@"adj_skad_register_call_time"];
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
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
