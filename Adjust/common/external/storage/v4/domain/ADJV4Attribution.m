//
//  ADJV4Attribution.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJV4Attribution.h"

#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kTrackerTokenKey = @"trackerToken";
static NSString *const kTrackerNameKey = @"trackerName";
static NSString *const kNetworkKey = @"network";
static NSString *const kCampaignKey = @"campaign";
static NSString *const kAdgroupKey = @"adgroup";
static NSString *const kCreativeKey = @"creative";
static NSString *const kClickLabelKey = @"click_label";
static NSString *const kAdidKey = @"adid";
static NSString *const kCostTypeKey = @"costType";
static NSString *const kCostAmountKey = @"costAmount";
static NSString *const kCostCurrencyKey = @"costCurrency";

#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSString *trackerToken;
 @property (nullable, readonly, strong, nonatomic) NSString *trackerName;
 @property (nullable, readonly, strong, nonatomic) NSString *network;
 @property (nullable, readonly, strong, nonatomic) NSString *campaign;
 @property (nullable, readonly, strong, nonatomic) NSString *adgroup;
 @property (nullable, readonly, strong, nonatomic) NSString *creative;
 @property (nullable, readonly, strong, nonatomic) NSString *clickLabel;
 @property (nullable, readonly, strong, nonatomic) NSString *adid;
 @property (nullable, readonly, strong, nonatomic) NSString *costType;
 @property (nullable, readonly, strong, nonatomic) NSNumber *costAmount;
 @property (nullable, readonly, strong, nonatomic) NSString *costCurrency;
 */

@implementation ADJV4Attribution
#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) return nil;
    
    if ([decoder containsValueForKey:kTrackerTokenKey]) {
        _trackerToken = [decoder decodeObjectForKey:kTrackerTokenKey];
    }
    if ([decoder containsValueForKey:kTrackerNameKey]) {
        _trackerName = [decoder decodeObjectForKey:kTrackerNameKey];
    }
    if ([decoder containsValueForKey:kNetworkKey]) {
        _network = [decoder decodeObjectForKey:kNetworkKey];
    }
    if ([decoder containsValueForKey:kCampaignKey]) {
        _campaign = [decoder decodeObjectForKey:kCampaignKey];
    }
    if ([decoder containsValueForKey:kAdgroupKey]) {
        _adgroup = [decoder decodeObjectForKey:kAdgroupKey];
    }
    if ([decoder containsValueForKey:kCreativeKey]) {
        _creative = [decoder decodeObjectForKey:kCreativeKey];
    }
    if ([decoder containsValueForKey:kClickLabelKey]) {
        _clickLabel = [decoder decodeObjectForKey:kClickLabelKey];
    }
    if ([decoder containsValueForKey:kAdidKey]) {
        _adid = [decoder decodeObjectForKey:kAdidKey];
    }
    if ([decoder containsValueForKey:kCostTypeKey]) {
        _costType = [decoder decodeObjectForKey:kCostTypeKey];
    }
    if ([decoder containsValueForKey:kCostAmountKey]) {
        _costAmount = [decoder decodeObjectForKey:kCostAmountKey];
    }
    if ([decoder containsValueForKey:kCostCurrencyKey]) {
        _costCurrency = [decoder decodeObjectForKey:kCostCurrencyKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            @"ADJV4Attribution",
            kTrackerTokenKey, self.trackerToken,
            kTrackerNameKey, self.trackerName,
            kNetworkKey, self.network,
            kCampaignKey, self.campaign,
            kAdgroupKey, self.adgroup,
            kCreativeKey, self.creative,
            kClickLabelKey, self.clickLabel,
            kAdidKey, self.adid,
            kCostTypeKey, self.costType,
            kCostAmountKey, self.costAmount,
            kCostCurrencyKey, self.costCurrency,
            nil];
}

@end
