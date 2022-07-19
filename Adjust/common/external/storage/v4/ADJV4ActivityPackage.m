//
//  ADJV4ActivityPackage.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJV4ActivityPackage.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJV4SessionPath = @"/session";
NSString *const ADJV4EventPath = @"/event";
NSString *const ADJV4InfoPath = @"/sdk_info";
NSString *const ADJV4AdRevenuePath = @"/ad_revenue";
NSString *const ADJV4ClickPath = @"/sdk_click";
NSString *const ADJV4AttributionPath = @"/attribution";
NSString *const ADJV4GdprForgetDevicePath = @"/gdpr_forget_device";
NSString *const ADJV4DisableThirdPartySharingPath = @"/disable_third_party_sharing";
NSString *const ADJV4ThirdPartySharingPath = @"/third_party_sharing";
NSString *const ADJV4MeasuringConsentPath = @"/measurement_consent";
NSString *const ADJV4PurchasePath = @"/v2/purchase";

#pragma mark - Private constants
static NSString *const kPathKey = @"path";
static NSString *const kClientSdkKey = @"clientSdk";
static NSString *const kRetries = @"retries";
static NSString *const kParametersKey = @"parameters";
static NSString *const kPartnerParametersKey = @"partnerParameters";
static NSString *const kCallbackParametersKey = @"callbackParameters";
static NSString *const kSuffixKey = @"suffix";
static NSString *const kKindKey = @"kind";

#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSString *path;
 @property (nullable, readonly, strong, nonatomic) NSString *clientSdk;
 @property (nullable, readonly, strong, nonatomic) NSNumber *retriesNumberInt;
 @property (nullable, readonly, strong, nonatomic) NSMutableDictionary *parameters;
 @property (nullable, readonly, strong, nonatomic) NSDictionary *partnerParameters;
 @property (nullable, readonly, strong, nonatomic) NSDictionary *callbackParameters;
 @property (nullable, readonly, strong, nonatomic) NSString *suffix;
 @property (nullable, readonly, strong, nonatomic) NSString *kind;

 */
@implementation ADJV4ActivityPackage
#pragma mark Instantiation
- (id)init {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    return self;
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];

    if (self == nil) {
        return self;
    }

    if ([decoder containsValueForKey:kPathKey]) {
        _path = [decoder decodeObjectForKey:kPathKey];
    }
    if ([decoder containsValueForKey:kSuffixKey]) {
        _suffix = [decoder decodeObjectForKey:kSuffixKey];
    }
    if ([decoder containsValueForKey:kClientSdkKey]) {
        _clientSdk = [decoder decodeObjectForKey:kClientSdkKey];
    }
    if ([decoder containsValueForKey:kParametersKey]) {
        _parameters = [decoder decodeObjectForKey:kParametersKey];
    }
    if ([decoder containsValueForKey:kPartnerParametersKey]) {
        _partnerParameters = [decoder decodeObjectForKey:kPartnerParametersKey];
    }
    if ([decoder containsValueForKey:kCallbackParametersKey]) {
        _callbackParameters = [decoder decodeObjectForKey:kCallbackParametersKey];
    }
    if ([decoder containsValueForKey:kCallbackParametersKey]) {
        _callbackParameters = [decoder decodeObjectForKey:kCallbackParametersKey];
    }
    if ([decoder containsValueForKey:kKindKey]) {
        _kind = [decoder decodeObjectForKey:kKindKey];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
}

@end
