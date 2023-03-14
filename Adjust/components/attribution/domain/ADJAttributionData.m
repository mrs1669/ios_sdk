//
//  ADJAttributionData.m
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAttributionData.h"

#import "ADJUtilObj.h"
#import "ADJUtilMap.h"
#import "ADJConstants.h"
#import "ADJConstantsParam.h"
#import "ADJMoneyDoubleAmount.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *trackerToken;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *trackerName;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *network;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *campaign;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adgroup;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *creative;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *clickLabel;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adid;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deeplink;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *state;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *costType;
 @property (nullable, readonly, strong, nonatomic) ADJMoneyAmountBase *costAmount;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *costCurrency;
 */

#pragma mark - Public constants
NSString *const ADJAttributionDataMetadataTypeValue = @"AttributionData";

#pragma mark - Private constants
static NSString *const kTrackerTokenKey = @"trackerToken";
static NSString *const kTrackerNameKey = @"trackerName";
static NSString *const kNetworkKey = @"network";
static NSString *const kCampaignKey = @"campaign";
static NSString *const kAdgroupKey = @"adgroup";
static NSString *const kCreativeKey = @"creative";
static NSString *const kClickLabelKey = @"clickLabel";
static NSString *const kAdidKey = @"adid";
static NSString *const kDeeplinkKey = @"deeplink";
static NSString *const kStateKey = @"state";
static NSString *const kCostTypeKey = @"costType";
static NSString *const kCostAmountKey = @"costAmount";
static NSString *const kCostCurrencyKey = @"costCurrency";

@implementation ADJAttributionData
#pragma mark Instantiation
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJAttributionData *> *)
    instanceFromIoDataMap:(nonnull ADJStringMap *)ioDataMap
{
    ADJNonEmptyString *_Nullable costAmountIoValue = [ioDataMap pairValueWithKey:kCostAmountKey];
    ADJResultNL<ADJMoneyAmountBase *> *_Nonnull costAmountResult =
        [ADJMoneyAmountBase instanceFromOptionalIoValue:costAmountIoValue];

    NSArray<ADJResultFail *> *optionalFails = nil;

    if (costAmountResult.fail != nil) {
        ADJResultFailBuilder *_Nonnull resultFailBuilder =
            [[ADJResultFailBuilder alloc] initWithMessage:
             @"Cannot use invalid cost amount in attribution data from io data map"];
        [resultFailBuilder withKey:@"costAmount fail"
                         otherFail:costAmountResult.fail];
        optionalFails = [NSArray arrayWithObject:[resultFailBuilder build]];
    }

    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFails
            value:[[ADJAttributionData alloc]
                   initWithTrackerToken:[ioDataMap pairValueWithKey:kTrackerTokenKey]
                   trackerName:[ioDataMap pairValueWithKey:kTrackerNameKey]
                   network:[ioDataMap pairValueWithKey:kNetworkKey]
                   campaign:[ioDataMap pairValueWithKey:kCampaignKey]
                   adgroup:[ioDataMap pairValueWithKey:kAdgroupKey]
                   creative:[ioDataMap pairValueWithKey:kCreativeKey]
                   clickLabel:[ioDataMap pairValueWithKey:kClickLabelKey]
                   adid:[ioDataMap pairValueWithKey:kAdidKey]
                   deeplink:[ioDataMap pairValueWithKey:kDeeplinkKey]
                   state:[ioDataMap pairValueWithKey:kStateKey]
                   costType:[ioDataMap pairValueWithKey:kCostTypeKey]
                   costAmount:costAmountResult.value
                   costCurrency:[ioDataMap pairValueWithKey:kCostCurrencyKey]]];
}

- (nullable ADJNonEmptyString *)convExternalWithValue:(nullable NSString *)value
                                              subject:(nonnull NSString *)subject
                                               logger:(nonnull ADJLogger *)logger
{
    ADJResultNL<ADJNonEmptyString *> *_Nonnull valueResult =
        [ADJNonEmptyString instanceFromOptionalString:value];
    if (valueResult.fail != nil) {
        [logger debugDev:@"Invalid string from external data"
               subject:subject
              resultFail:valueResult.fail
               issueType:ADJIssueInvalidInput];
    }
    return valueResult.value;
}

#define convExtCall(value, name) \
    [self convExternalWithValue:(value) subject:(name) logger:logger] \

- (nonnull instancetype)initFromExternalDataWithLogger:(nonnull ADJLogger *)logger
                                    trackerTokenString:(nullable NSString *)trackerTokenString
                                     trackerNameString:(nullable NSString *)trackerNameString
                                         networkString:(nullable NSString *)networkString
                                        campaignString:(nullable NSString *)campaignString
                                         adgroupString:(nullable NSString *)adgroupString
                                        creativeString:(nullable NSString *)creativeString
                                      clickLabelString:(nullable NSString *)clickLabelString
                                            adidString:(nullable NSString *)adidString
                                        costTypeString:(nullable NSString *)costTypeString
                                costAmountDoubleNumber:(nullable NSNumber *)costAmountDoubleNumber
                                    costCurrencyString:(nullable NSString *)costCurrencyString
{
    ADJResultNL<ADJMoneyDoubleAmount *> *_Nonnull costAmountDoubleResult =
        [ADJMoneyDoubleAmount instanceFromOptionalDoubleNumberValue:costAmountDoubleNumber];
    if (costAmountDoubleResult.fail != nil) {
        [logger debugDev:@"Invalid cost amount double from external data"
              resultFail:costAmountDoubleResult.fail
               issueType:ADJIssueInvalidInput];
    }

    return [self initWithTrackerToken:convExtCall(trackerTokenString, kTrackerTokenKey)
                          trackerName:convExtCall(trackerNameString, kTrackerNameKey)
                              network:convExtCall(networkString, kNetworkKey)
                             campaign:convExtCall(campaignString, kCampaignKey)
                              adgroup:convExtCall(adgroupString, kAdgroupKey)
                             creative:convExtCall(creativeString, kCreativeKey)
                           clickLabel:convExtCall(clickLabelString, kClickLabelKey)
                                 adid:convExtCall(adidString, kAdidKey)
                             deeplink:nil
                                state:nil
                             costType:convExtCall(costTypeString, kCostTypeKey)
                           costAmount:costAmountDoubleResult.value
                         costCurrency:convExtCall(costCurrencyString, kCostCurrencyKey)];
}

- (nullable ADJNonEmptyString *)extractJsonWithDictionary:(nonnull NSDictionary *)jsonDictionary
                                                      key:(nonnull NSString *)key
                                                   logger:(nonnull ADJLogger *)logger
{
    ADJResultNL<NSString *> *_Nonnull valueResult =
        [ADJUtilMap extractStringValueWithDictionary:jsonDictionary
                                                 key:key];
    if (valueResult.fail != nil) {
        [logger debugDev:@"Invalid string value in json dictionary"
                     key:@"key"
                   value:key
              resultFail:valueResult.fail
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    ADJResultNL<ADJNonEmptyString *> *_Nonnull parsedResult =
        [ADJNonEmptyString instanceFromOptionalString:valueResult.value];
    if (parsedResult.fail != nil) {
        [logger debugDev:@"Failed parsing string value in json dictionary"
                     key:@"key"
                   value:key
              resultFail:parsedResult.fail
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    return parsedResult.value;
}

#define extrJsonCall(dictKey) \
    [self extractJsonWithDictionary:jsonDictionary key:(dictKey) logger:logger] \

- (nonnull instancetype)initFromJsonWithDictionary:(nonnull NSDictionary *)jsonDictionary
                                              adid:(nonnull ADJNonEmptyString *)adid
                                            logger:(nonnull ADJLogger *)logger
{
    ADJResultNL<NSNumber *> *_Nonnull costAmountDoubleNumberResult =
        [ADJUtilMap extractDoubleNumberWithDictionary:jsonDictionary
                                                  key:ADJParamAttributionCostAmountKey];
    if (costAmountDoubleNumberResult.fail != nil) {
        [logger debugDev:@"Invalid cost amount double number in json dictionary"
              resultFail:costAmountDoubleNumberResult.fail
               issueType:ADJIssueInvalidInput];
    }
    ADJResultNL<ADJMoneyDoubleAmount *> *_Nullable costAmountDoubleResult =
        [ADJMoneyDoubleAmount instanceFromOptionalDoubleNumberValue:
         costAmountDoubleNumberResult.value];
    if (costAmountDoubleResult.fail != nil) {
        [logger debugDev:@"Failed parsing cost amount double"
              resultFail:costAmountDoubleResult.fail
               issueType:ADJIssueInvalidInput];
    }

    return [self
            initWithTrackerToken:extrJsonCall(ADJParamAttributionTrackerTokenKey)
            trackerName:extrJsonCall(ADJParamAttributionTrackerNameKey)
            network:extrJsonCall(ADJParamAttributionNetworkKey)
            campaign:extrJsonCall(ADJParamAttributionCampaignKey)
            adgroup:extrJsonCall(ADJParamAttributionAdGroupKey)
            creative:extrJsonCall(ADJParamAttributionCreativeKey)
            clickLabel:extrJsonCall(ADJParamAttributionClickLableKey)
            adid:adid
            deeplink:extrJsonCall(ADJParamAttributionDeeplinkKey)
            state:extrJsonCall(ADJParamAttributionStateKey)
            costType:extrJsonCall(ADJParamAttributionCostTypeKey)
            costAmount:costAmountDoubleResult.value
            costCurrency:extrJsonCall(ADJParamAttributionCostCurrencyKey)];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithTrackerToken:(nullable ADJNonEmptyString *)trackerToken
                                 trackerName:(nullable ADJNonEmptyString *)trackerName
                                     network:(nullable ADJNonEmptyString *)network
                                    campaign:(nullable ADJNonEmptyString *)campaign
                                     adgroup:(nullable ADJNonEmptyString *)adgroup
                                    creative:(nullable ADJNonEmptyString *)creative
                                  clickLabel:(nullable ADJNonEmptyString *)clickLabel
                                        adid:(nullable ADJNonEmptyString *)adid
                                    deeplink:(nullable ADJNonEmptyString *)deeplink
                                       state:(nullable ADJNonEmptyString *)state
                                    costType:(nullable ADJNonEmptyString *)costType
                                  costAmount:(nullable ADJMoneyAmountBase *)costAmount
                                costCurrency:(nullable ADJNonEmptyString *)costCurrency
{
    self = [super init];
    
    _trackerToken = trackerToken;
    _trackerName = trackerName;
    _network = network;
    _campaign = campaign;
    _adgroup = adgroup;
    _creative = creative;
    _clickLabel = clickLabel;
    _adid = adid;
    _deeplink = deeplink;
    _state = state;
    _costType = costType;
    _costAmount = costAmount;
    _costCurrency = costCurrency;
    
    return self;
}

#pragma mark Public API
- (nonnull ADJAdjustAttribution *)toAdjustAttribution {
    ADJAdjustAttribution *_Nonnull adjustAttribution = [[ADJAdjustAttribution alloc] init];
    
    adjustAttribution.trackerToken = [ADJAttributionData coallesceToEmptyStringWithValue:self.trackerToken];
    adjustAttribution.trackerName = [ADJAttributionData coallesceToEmptyStringWithValue:self.trackerName];
    adjustAttribution.network = [ADJAttributionData coallesceToEmptyStringWithValue:self.network];
    adjustAttribution.campaign = [ADJAttributionData coallesceToEmptyStringWithValue:self.campaign];
    adjustAttribution.adgroup = [ADJAttributionData coallesceToEmptyStringWithValue:self.adgroup];
    adjustAttribution.creative = [ADJAttributionData coallesceToEmptyStringWithValue:self.creative];
    adjustAttribution.clickLabel = [ADJAttributionData coallesceToEmptyStringWithValue:self.clickLabel];
    adjustAttribution.adid = [ADJAttributionData coallesceToEmptyStringWithValue:self.adid];
    adjustAttribution.deeplink = [ADJAttributionData coallesceToEmptyStringWithValue:self.deeplink];
    adjustAttribution.state = [ADJAttributionData coallesceToEmptyStringWithValue:self.state];
    adjustAttribution.costType = [ADJAttributionData coallesceToEmptyStringWithValue:self.costType];
    adjustAttribution.costAmount = self.costAmount != nil ? self.costAmount.doubleValue : -1.0;
    adjustAttribution.costCurrency = [ADJAttributionData coallesceToEmptyStringWithValue:self.costCurrency];
    
    return adjustAttribution;
}

#pragma mark - ADJIoDataMapBuilderInjectable

#define injectIoData(keyValue, ioValue)                         \
[ADJUtilMap injectIntoIoDataBuilderMap:ioDataMapBuilder    \
key:keyValue            \
ioValueSerializable:ioValue]            \

- (void)injectIntoIoDataMapBuilder:(nonnull ADJStringMapBuilder *)ioDataMapBuilder {
    injectIoData(kTrackerTokenKey, self.trackerToken);
    injectIoData(kTrackerNameKey, self.trackerName);
    injectIoData(kNetworkKey, self.network);
    injectIoData(kCampaignKey, self.campaign);
    injectIoData(kAdgroupKey, self.adgroup);
    injectIoData(kCreativeKey, self.creative);
    injectIoData(kClickLabelKey, self.clickLabel);
    injectIoData(kAdidKey, self.adid);
    injectIoData(kDeeplinkKey, self.deeplink);
    injectIoData(kStateKey, self.state);
    injectIoData(kCostTypeKey, self.costType);
    injectIoData(kCostAmountKey, self.costAmount);
    injectIoData(kCostCurrencyKey, self.costCurrency);
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJAttributionDataMetadataTypeValue,
            kTrackerTokenKey, self.trackerToken,
            kTrackerNameKey, self.trackerName,
            kNetworkKey, self.network,
            kCampaignKey, self.campaign,
            kAdgroupKey, self.adgroup,
            kCreativeKey, self.creative,
            kClickLabelKey, self.clickLabel,
            kAdidKey, self.adid,
            kDeeplinkKey, self.deeplink,
            kStateKey, self.state,
            kCostTypeKey, self.costType,
            kCostAmountKey, self.costAmount,
            kCostCurrencyKey, self.costCurrency,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.trackerToken];
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.trackerName];
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.network];
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.campaign];
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.adgroup];
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.creative];
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.clickLabel];
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.adid];
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.deeplink];
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.state];
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.costType];
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.costAmount];
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.costCurrency];
    
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[ADJAttributionData class]]) {
        return NO;
    }
    
    ADJAttributionData *other = (ADJAttributionData *)object;
    return [ADJUtilObj objectEquals:self.trackerToken other:other.trackerToken]
    && [ADJUtilObj objectEquals:self.trackerName other:other.trackerName]
    && [ADJUtilObj objectEquals:self.network other:other.network]
    && [ADJUtilObj objectEquals:self.campaign other:other.campaign]
    && [ADJUtilObj objectEquals:self.adgroup other:other.adgroup]
    && [ADJUtilObj objectEquals:self.creative other:other.creative]
    && [ADJUtilObj objectEquals:self.clickLabel other:other.clickLabel]
    && [ADJUtilObj objectEquals:self.adid other:other.adid]
    && [ADJUtilObj objectEquals:self.deeplink other:other.deeplink]
    && [ADJUtilObj objectEquals:self.state other:other.state]
    && [ADJUtilObj objectEquals:self.costType other:other.costType]
    && [ADJUtilObj objectEquals:self.costAmount other:other.costAmount]
    && [ADJUtilObj objectEquals:self.costCurrency other:other.costCurrency];
}

#pragma mark Internal Methods
+ (nonnull NSString *)coallesceToEmptyStringWithValue:(nullable ADJNonEmptyString *)value {
    return value != nil ? value.stringValue : @"";
}

@end
