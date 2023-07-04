//
//  ADJClientAdRevenueData.m
//  Adjust
//
//  Created by Aditi Agrawal on 23/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientAdRevenueData.h"

#import "ADJMoneyDoubleAmount.h"
#import "ADJUtilF.h"
#import "ADJUtilConv.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJUtilMap.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *source;
 @property (nullable, readonly, strong, nonatomic) ADJMoney *revenue;
 @property (nullable, readonly, strong, nonatomic) ADJNonNegativeInt *adImpressionsCount;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *network;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *unit;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *placement;
 @property (nullable, readonly, strong, nonatomic) ADJStringMap *callbackParameters;
 @property (nullable, readonly, strong, nonatomic) ADJStringMap *partnerParameters;
 */

#pragma mark - Public constants
NSString *const ADJClientAdRevenueDataMetadataTypeValue = @"ClientAdRevenueData";

NSString *const ADJAdRevenueSourceAppLovinMAX = @"applovin_max_sdk";
NSString *const ADJAdRevenueSourceMopub = @"mopub";
NSString *const ADJAdRevenueSourceAdMob = @"admob_sdk";
NSString *const ADJAdRevenueSourceIronSource = @"ironsource_sdk";
NSString *const ADJAdRevenueSourceAdMost = @"admost_sdk";
NSString *const ADJAdRevenueSourceUnity = @"unity_sdk";
NSString *const ADJAdRevenueSourceHeliumChartboost = @"helium_chartboost_sdk";
NSString *const ADJAdRevenueSourcePublisher = @"publisher_sdk";

#pragma mark - Private constants
static NSString *const kSourceKey = @"source";
static NSString *const kRevenueAmountKey = @"revenueAmount";
static NSString *const kRevenueCurrencyKey = @"revenueCurrency";
static NSString *const kAdImpressionsCountKey = @"adImpressionsCount";
static NSString *const kNetworkKey = @"network";
static NSString *const kUnitKey = @"unit";
static NSString *const kPlacementKey = @"placement";
static NSString *const kCallbackParametersMapName = @"CALLBACK_PARAMETER_MAP";
static NSString *const kPartnerParametersMapName = @"PARTNER_PARAMETER_MAP";

static NSSet<NSString *> *adRevenueSourceSet = nil;
static dispatch_once_t adRevenueSourceSetOnceToken = 0;

@implementation ADJClientAdRevenueData
#pragma mark Instantiation
+ (nullable instancetype)
    instanceFromClientWithLogger:(nonnull ADJLogger *)logger
    adjustAdRevenue:(nullable ADJAdjustAdRevenue *)adjustAdRevenue
    externalCallbackParameterKeyValueArray:
        (nullable NSArray *)externalCallbackParameterKeyValueArray
    externalPartnerParameterKeyValueArray:
        (nullable NSArray *)externalPartnerParameterKeyValueArray
    externalCallbackParametersStringMap:
        (nullable ADJStringMap *)externalCallbackParametersStringMap
    externalPartnerParametersStringMap:(nullable ADJStringMap *)externalPartnerParametersStringMap
    externalRevenue:(nullable ADJMoney *)externalRevenue
{
    if (adjustAdRevenue == nil) {
        [logger errorClient:@"Cannot create ad revenue with nil adjust ad revenue value"];
        return nil;
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull sourceResult =
        [ADJNonEmptyString instanceFromString:adjustAdRevenue.source];
    if (sourceResult.fail != nil) {
        [logger errorClient:@"Cannot create ad revenue with invalid source"
                resultFail:sourceResult.fail];
        return nil;
    }

    dispatch_once(&adRevenueSourceSetOnceToken, ^{
        adRevenueSourceSet = [NSSet setWithObjects:
                              ADJAdRevenueSourceAppLovinMAX,
                              ADJAdRevenueSourceMopub,
                              ADJAdRevenueSourceAdMob,
                              ADJAdRevenueSourceIronSource,
                              ADJAdRevenueSourceAdMost,
                              ADJAdRevenueSourceUnity,
                              ADJAdRevenueSourceHeliumChartboost,
                              ADJAdRevenueSourcePublisher,
                              nil];
    });

    if (! [adRevenueSourceSet containsObject:sourceResult.value.stringValue]) {
        [logger noticeClient:
         @"Cannot match ad revenue source to an expected one, but will be used as is"
                         key:@"ad revenue source"
                 stringValue:sourceResult.value.stringValue];
    }

    ADJMoney *_Nullable revenue = nil;
    if (externalRevenue != nil) {
        revenue = externalRevenue;
    } else {
        ADJResult<ADJMoney *> *_Nonnull revenueResult =
            [ADJMoney
             instanceFromAmountDoubleNumber:adjustAdRevenue.revenueAmountDoubleNumber
             currency:adjustAdRevenue.revenueCurrency];
        if (revenueResult.failNonNilInput != nil) {
            [logger noticeClient:@"Cannot use invalid revenue in ad revenue"
                      resultFail:revenueResult.fail];
        }
        revenue = revenueResult.value;
    }
    if (revenue != nil && [revenue.amount isNegative]) {
        [logger infoClient:@"Ad revenue amount found to be negative."
         " Its validity will be determined server side"];
    }

    ADJResult<ADJNonNegativeInt *> *_Nonnull adImpressionsCountResult =
        [ADJNonNegativeInt instanceFromIntegerNumber:
         adjustAdRevenue.adImpressionsCountIntegerNumber];
    if (adImpressionsCountResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot use invalid ad impressions count in ad revenue"
                  resultFail:adImpressionsCountResult.fail];
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull networkResult =
        [ADJNonEmptyString instanceFromString:adjustAdRevenue.network];
    if (networkResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot use invalid network in ad revenue"
                 resultFail:networkResult.fail];
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull unitResult =
        [ADJNonEmptyString instanceFromString:adjustAdRevenue.unit];
    if (unitResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot use invalid unit in ad revenue"
                 resultFail:unitResult.fail];
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull placementResult =
        [ADJNonEmptyString instanceFromString:adjustAdRevenue.placement];
    if (unitResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot use invalid placement in ad revenue"
                 resultFail:unitResult.fail];
    }

    ADJStringMap *_Nullable callbackParameters = nil;
    if (externalCallbackParametersStringMap != nil) {
        callbackParameters = externalCallbackParametersStringMap;
    } else {
        callbackParameters =
            [ADJUtilConv
             clientStringMapWithKeyValueArray:
                 externalCallbackParameterKeyValueArray
                ?: adjustAdRevenue.callbackParameterKeyValueArray
             logger:logger
             processingFailMessage:@"Cannot use ad revenue callback parameters"
             addingFailMessage:@"Issue while adding to ad revenue callback parameters"
             emptyFailMessage:@"Could not use any valid ad revenue callback parameter"];
    }

    ADJStringMap *_Nullable partnerParameters = nil;
    if (externalPartnerParametersStringMap != nil) {
        partnerParameters = externalPartnerParametersStringMap;
    } else {
        partnerParameters =
            [ADJUtilConv
             clientStringMapWithKeyValueArray:
                 externalPartnerParameterKeyValueArray ?:
                adjustAdRevenue.partnerParameterKeyValueArray
             logger:logger
             processingFailMessage:@"Cannot use ad revenue partner parameters"
             addingFailMessage:@"Issue while adding to ad revenue partner parameters"
             emptyFailMessage:@"Could not use any valid ad revenue partner parameter"];
    }

    return [[ADJClientAdRevenueData alloc] initWithSource:sourceResult.value
                                                  revenue:revenue
                                       adImpressionsCount:adImpressionsCountResult.value
                                                  network:networkResult.value
                                                     unit:unitResult.value
                                                placement:placementResult.value
                                       callbackParameters:callbackParameters
                                        partnerParameters:partnerParameters];
}

+ (nullable instancetype)
    instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
    logger:(nonnull ADJLogger *)logger
{
    ADJStringMap *_Nonnull propertiesMap = clientActionInjectedIoData.propertiesMap;

    ADJNonEmptyString *_Nullable source = [propertiesMap pairValueWithKey:kSourceKey];

    ADJAdjustAdRevenue *_Nonnull adjustAdRevenue =
        [[ADJAdjustAdRevenue alloc] initWithSource:source != nil ? source.stringValue : nil];

    ADJResult<ADJMoney *> *_Nonnull revenueResult =
        [ADJMoney
         instanceFromAmountIoValue:[propertiesMap pairValueWithKey:kRevenueAmountKey]
         currencyIoValue:[propertiesMap pairValueWithKey:kRevenueCurrencyKey]];
    if (revenueResult.failNonNilInput != nil) {
        [logger debugDev:@"Invalid revenue money from client action injected io data"
              resultFail:revenueResult.fail
               issueType:ADJIssueStorageIo];
    }

    ADJResult<ADJNonNegativeInt *> *_Nonnull adImpressionsCountResult =
        [ADJNonNegativeInt instanceFromIoDataValue:
         [propertiesMap pairValueWithKey:kAdImpressionsCountKey]];
    if (adImpressionsCountResult.failNonNilInput != nil) {
        [logger debugDev:@"Invalid ad impressions count from client action injected io data"
             resultFail:adImpressionsCountResult.fail
               issueType:ADJIssueInvalidInput];
    }
    if (adImpressionsCountResult.value != nil) {
        [adjustAdRevenue setAdImpressionsCountWithInteger:
         adImpressionsCountResult.value.uIntegerValue];
    }

    ADJNonEmptyString *_Nullable network = [propertiesMap pairValueWithKey:kNetworkKey];
    if (network != nil) {
        [adjustAdRevenue setNetwork:network.stringValue];
    }

    ADJNonEmptyString *_Nullable unit = [propertiesMap pairValueWithKey:kUnitKey];
    if (unit != nil) {
        [adjustAdRevenue setUnit:unit.stringValue];
    }

    ADJNonEmptyString *_Nullable placement = [propertiesMap pairValueWithKey:kPlacementKey];
    if (placement != nil) {
        [adjustAdRevenue setPlacement:placement.stringValue];
    }

    ADJStringMap *_Nullable callbackParametersMap =
        [clientActionInjectedIoData mapWithName:kCallbackParametersMapName];

    ADJStringMap *_Nullable partnerParametersMap =
        [clientActionInjectedIoData mapWithName:kPartnerParametersMapName];

    return [self instanceFromClientWithLogger:logger
                              adjustAdRevenue:adjustAdRevenue
       externalCallbackParameterKeyValueArray:nil
        externalPartnerParameterKeyValueArray:nil
          externalCallbackParametersStringMap:callbackParametersMap
           externalPartnerParametersStringMap:partnerParametersMap
                              externalRevenue:revenueResult.value];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithSource:(nonnull ADJNonEmptyString *)source
                               revenue:(nullable ADJMoney *)revenue
                    adImpressionsCount:(nullable ADJNonNegativeInt *)adImpressionsCount
                               network:(nullable ADJNonEmptyString *)network
                                  unit:(nullable ADJNonEmptyString *)unit
                             placement:(nullable ADJNonEmptyString *)placement
                    callbackParameters:(nullable ADJStringMap *)callbackParameters
                     partnerParameters:(nullable ADJStringMap *)partnerParameters
{
    self = [super init];

    _source = source;
    _revenue = revenue;
    _adImpressionsCount = adImpressionsCount;
    _network = network;
    _unit = unit;
    _placement = placement;
    _callbackParameters = callbackParameters;
    _partnerParameters = partnerParameters;

    return self;
}

#pragma mark Public API
#pragma mark - ADJClientActionIoDataInjectable
- (void)injectIntoClientActionIoDataBuilder:(nonnull ADJIoDataBuilder *)clientActionIoDataBuilder {
    ADJStringMapBuilder *_Nonnull propertiesMapBuilder =
        clientActionIoDataBuilder.propertiesMapBuilder;

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kSourceKey
                       ioValueSerializable:self.source];

    if (self.revenue != nil) {
        [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                           key:kRevenueAmountKey
                           ioValueSerializable:self.revenue.amount];

        [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                           key:kRevenueCurrencyKey
                           ioValueSerializable:self.revenue.currency];
    }

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kAdImpressionsCountKey
                       ioValueSerializable:self.adImpressionsCount];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kNetworkKey
                       ioValueSerializable:self.network];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kUnitKey
                       ioValueSerializable:self.unit];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kPlacementKey
                       ioValueSerializable:self.placement];

    if (self.callbackParameters != nil) {
        ADJStringMapBuilder *_Nonnull callbackParametersMapBuilder =
        [clientActionIoDataBuilder
         addAndReturnNewMapBuilderByName:kCallbackParametersMapName];

        [callbackParametersMapBuilder addAllPairsWithStringMap:self.callbackParameters];
    }

    if (self.partnerParameters != nil) {
        ADJStringMapBuilder *_Nonnull partnerParametersMapBuilder =
        [clientActionIoDataBuilder
         addAndReturnNewMapBuilderByName:kPartnerParametersMapName];

        [partnerParametersMapBuilder addAllPairsWithStringMap:self.partnerParameters];
    }
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientAdRevenueDataMetadataTypeValue,
            kSourceKey, self.source,
            kRevenueAmountKey, self.revenue != nil ? self.revenue.amount : nil,
            kRevenueCurrencyKey, self.revenue != nil ? self.revenue.currency : nil,
            kAdImpressionsCountKey, self.adImpressionsCount,
            kNetworkKey, self.network,
            kUnitKey, self.unit,
            kPlacementKey, self.placement,
            kCallbackParametersMapName, self.callbackParameters,
            kPartnerParametersMapName, self.partnerParameters,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + self.source.hash;
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.revenue];
    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.adImpressionsCount];
    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.network];
    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.unit];
    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.placement];
    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.callbackParameters];
    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.partnerParameters];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJClientAdRevenueData class]]) {
        return NO;
    }

    ADJClientAdRevenueData *other = (ADJClientAdRevenueData *)object;
    return [ADJUtilObj objectEquals:self.source other:other.source]
    && [ADJUtilObj objectEquals:self.revenue other:other.revenue]
    && [ADJUtilObj objectEquals:self.adImpressionsCount other:other.adImpressionsCount]
    && [ADJUtilObj objectEquals:self.network other:other.network]
    && [ADJUtilObj objectEquals:self.unit other:other.unit]
    && [ADJUtilObj objectEquals:self.placement other:other.placement]
    && [ADJUtilObj objectEquals:self.callbackParameters other:other.callbackParameters]
    && [ADJUtilObj objectEquals:self.partnerParameters other:other.partnerParameters];
}

@end
