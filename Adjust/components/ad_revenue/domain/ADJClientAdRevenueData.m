//
//  ADJClientAdRevenueData.m
//  Adjust
//
//  Created by Aditi Agrawal on 23/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientAdRevenueData.h"

#import "ADJUtilF.h"
#import "ADJUtilConv.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJUtilMap.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *adRevenueSource;
 @property (nullable, readonly, strong, nonatomic) ADJMoney *revenue;
 @property (nullable, readonly, strong, nonatomic) ADJNonNegativeInt *adImpressionsCount;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adRevenueNetwork;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adRevenueUnit;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adRevenuePlacement;
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
static NSString *const kAdRevenueNetworkKey = @"adRevenueNetwork";
static NSString *const kAdRevenueUnitKey = @"adRevenueUnit";
static NSString *const kAdRevenuePlacementKey = @"adRevenuePlacement";
static NSString *const kCallbackParametersMapName = @"CALLBACK_PARAMETER_MAP";
static NSString *const kPartnerParametersMapName = @"PARTNER_PARAMETER_MAP";

static NSSet<NSString *> *adRevenueSourceSet = nil;
static dispatch_once_t adRevenueSourceSetOnceToken = 0;

@implementation ADJClientAdRevenueData
#pragma mark Instantiation
+ (nullable instancetype)instanceFromClientWithAdjustAdRevenue:(nullable ADJAdjustAdRevenue *)adjustAdRevenue
                                                        logger:(nonnull ADJLogger *)logger {
    if (adjustAdRevenue == nil) {
        [logger error:@"Cannot create ad revenue with nil adjust ad revenue value"];
        return nil;
    }

    ADJNonEmptyString *_Nullable source =
    [ADJNonEmptyString instanceFromString:adjustAdRevenue.source
                        sourceDescription:@"ad revenue source"
                                   logger:logger];
    if (source == nil) {
        [logger error:@"Cannot create ad revenue without ad revenue source"];
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

    if (![adRevenueSourceSet containsObject:source.stringValue]) {
        [logger error:@"Cannot match ad revenue source to an expected one,"
         " but will be used as is"];
    }

    ADJMoney *_Nullable revenue = nil;
    if (adjustAdRevenue.revenueAmountDoubleNumber != nil || adjustAdRevenue.revenueCurrency != nil) {
        revenue = [ADJMoney instanceFromAmountDoubleNumber:adjustAdRevenue.revenueAmountDoubleNumber
                                                  currency:adjustAdRevenue.revenueCurrency
                                                    source:@"adrevenue revenue"
                                                    logger:logger];
    }

    ADJNonNegativeInt *_Nullable adImpressionsCount =
    [ADJNonNegativeInt
     instanceFromOptionalIntegerNumber:adjustAdRevenue.adImpressionsCountIntegerNumber
     logger:logger];

    ADJNonEmptyString *_Nullable adRevenueNetwork =
    [ADJNonEmptyString instanceFromOptionalString:adjustAdRevenue.adRevenueNetwork
                                sourceDescription:@"ad revenue network"
                                           logger:logger];

    ADJNonEmptyString *_Nullable adRevenueUnit =
    [ADJNonEmptyString instanceFromOptionalString:adjustAdRevenue.adRevenueUnit
                                sourceDescription:@"ad revenue unit"
                                           logger:logger];

    ADJNonEmptyString *_Nullable adRevenuePlacement =
    [ADJNonEmptyString instanceFromOptionalString:adjustAdRevenue.adRevenuePlacement
                                sourceDescription:@"ad revenue placement"
                                           logger:logger];

    ADJStringMap *_Nullable callbackParameters =
    [ADJUtilConv convertToStringMapWithKeyValueArray:adjustAdRevenue.callbackParameterKeyValueArray
                                   sourceDescription:@"ad revenue callback parameters"
                                              logger:logger];

    ADJStringMap *_Nullable partnerParameters =
    [ADJUtilConv convertToStringMapWithKeyValueArray:adjustAdRevenue.partnerParameterKeyValueArray
                                   sourceDescription:@"ad revenue partner parameters"
                                              logger:logger];

    return [[self alloc] initWithSource:source
                                revenue:revenue
                     adImpressionsCount:adImpressionsCount
                       adRevenueNetwork:adRevenueNetwork
                          adRevenueUnit:adRevenueUnit
                     adRevenuePlacement:adRevenuePlacement
                     callbackParameters:callbackParameters
                      partnerParameters:partnerParameters];
}

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger {

    ADJStringMap *_Nonnull propertiesMap = clientActionInjectedIoData.propertiesMap;

    ADJNonEmptyString *_Nullable source = [propertiesMap pairValueWithKey:kSourceKey];

    ADJAdjustAdRevenue *_Nonnull adjustAdRevenue = [[ADJAdjustAdRevenue alloc] initWithSource:source != nil ? source.stringValue : nil];

    ADJNonEmptyString *_Nullable revenueAmountIoValue = [propertiesMap pairValueWithKey:kRevenueAmountKey];
    ADJMoneyAmountBase *_Nullable revenueAmount = [ADJMoneyAmountBase instanceFromOptionalIoValue:revenueAmountIoValue
                                                                                             logger:logger];
    ADJNonEmptyString *_Nullable revenueCurrency = [propertiesMap pairValueWithKey:kRevenueCurrencyKey];
    if (revenueAmount != nil || revenueCurrency != nil) {
        [adjustAdRevenue
         setRevenueWithDoubleNumber:revenueAmount != nil? revenueAmount.numberValue : nil
         currency:revenueCurrency != nil ? revenueCurrency.stringValue : nil];
    }

    ADJNonEmptyString *_Nullable adImpressionsCountIoValue = [propertiesMap pairValueWithKey:kAdImpressionsCountKey];
    ADJNonNegativeInt *_Nullable adImpressionsCount = [ADJNonNegativeInt instanceFromOptionalIoDataValue:adImpressionsCountIoValue
                                                                                                    logger:logger];
    if (adImpressionsCount != nil) {
        [adjustAdRevenue setAdImpressionsCountWithInteger:adImpressionsCount.uIntegerValue];
    }

    ADJNonEmptyString *_Nullable adRevenueNetwork = [propertiesMap pairValueWithKey:kAdRevenueNetworkKey];
    if (adRevenueNetwork != nil) {
        [adjustAdRevenue setAdRevenueNetwork:adRevenueNetwork.stringValue];
    }

    ADJNonEmptyString *_Nullable adRevenueUnit = [propertiesMap pairValueWithKey:kAdRevenueUnitKey];
    if (adRevenueUnit != nil) {
        [adjustAdRevenue setAdRevenueUnit:adRevenueUnit.stringValue];
    }

    ADJNonEmptyString *_Nullable adRevenuePlacement = [propertiesMap pairValueWithKey:kAdRevenuePlacementKey];
    if (adRevenuePlacement != nil) {
        [adjustAdRevenue setAdRevenuePlacement:adRevenuePlacement.stringValue];
    }

    ADJStringMap *_Nullable callbackParametersMap = [clientActionInjectedIoData mapWithName:kCallbackParametersMapName];

    if (callbackParametersMap != nil) {
        for (NSString *_Nonnull callbackParameterKey in callbackParametersMap.map) {
            [adjustAdRevenue
             addCallbackParameterWithKey:callbackParameterKey
             value:[callbackParametersMap.map objectForKey:callbackParameterKey].stringValue];
        }
    }

    ADJStringMap *_Nullable partnerParametersMap = [clientActionInjectedIoData mapWithName:kPartnerParametersMapName];

    if (partnerParametersMap != nil) {
        for (NSString *_Nonnull partnerParameterKey in partnerParametersMap.map) {
            [adjustAdRevenue
             addPartnerParameterWithKey:partnerParameterKey
             value:[partnerParametersMap.map objectForKey:partnerParameterKey].stringValue];
        }
    }

    return [self instanceFromClientWithAdjustAdRevenue:adjustAdRevenue
                                                logger:logger];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithSource:(nonnull ADJNonEmptyString *)source
                               revenue:(nullable ADJMoney *)revenue
                    adImpressionsCount:(nullable ADJNonNegativeInt *)adImpressionsCount
                      adRevenueNetwork:(nullable ADJNonEmptyString *)adRevenueNetwork
                         adRevenueUnit:(nullable ADJNonEmptyString *)adRevenueUnit
                    adRevenuePlacement:(nullable ADJNonEmptyString *)adRevenuePlacement
                    callbackParameters:(nullable ADJStringMap *)callbackParameters
                     partnerParameters:(nullable ADJStringMap *)partnerParameters {
    self = [super init];

    _source = source;
    _revenue = revenue;
    _adImpressionsCount = adImpressionsCount;
    _adRevenueNetwork = adRevenueNetwork;
    _adRevenueUnit = adRevenueUnit;
    _adRevenuePlacement = adRevenuePlacement;
    _callbackParameters = callbackParameters;
    _partnerParameters = partnerParameters;

    return self;
}

#pragma mark Public API
#pragma mark - ADJClientActionIoDataInjectable
- (void)injectIntoClientActionIoDataBuilder:(nonnull ADJIoDataBuilder *)clientActionIoDataBuilder{
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
                                       key:kAdRevenueNetworkKey
                       ioValueSerializable:self.adRevenueNetwork];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kAdRevenueUnitKey
                       ioValueSerializable:self.adRevenueUnit];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kAdRevenuePlacementKey
                       ioValueSerializable:self.adRevenuePlacement];

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
            kAdRevenueNetworkKey, self.adRevenueNetwork,
            kAdRevenueUnitKey, self.adRevenueUnit,
            kAdRevenuePlacementKey, self.adRevenuePlacement,
            kCallbackParametersMapName, self.callbackParameters,
            kPartnerParametersMapName, self.partnerParameters,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + self.source.hash;
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.revenue];
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.adImpressionsCount];
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.adRevenueNetwork];
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.adRevenueUnit];
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.adRevenuePlacement];
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
    && [ADJUtilObj objectEquals:self.adRevenueNetwork other:other.adRevenueNetwork]
    && [ADJUtilObj objectEquals:self.adRevenueUnit other:other.adRevenueUnit]
    && [ADJUtilObj objectEquals:self.adRevenuePlacement other:other.adRevenuePlacement]
    && [ADJUtilObj objectEquals:self.callbackParameters other:other.callbackParameters]
    && [ADJUtilObj objectEquals:self.partnerParameters other:other.partnerParameters];
}

#pragma mark Internal Methods
+ (nullable ADJNonEmptyString *)extractNonEmptyStringJsonPayloadWithFoundation:(nullable id)foundationJsonPayload
                                                                          data:(nullable NSData *)dataJsonPayload
                                                                        string:(nullable NSString *)stringJsonPayload
                                                                        logger:(nonnull ADJLogger *)logger {
    id _Nullable localFoundationJsonPayload = foundationJsonPayload;
    NSData *_Nullable localDataJsonPayload = dataJsonPayload;
    NSString *_Nullable localStringJsonPayload = stringJsonPayload;

    if (localFoundationJsonPayload != nil) {
        NSError *error;
        localDataJsonPayload =
            [ADJUtilConv convertToJsonDataWithJsonFoundationValue:foundationJsonPayload
                                                         errorPtr:&error];
        if (error != nil) {
            [logger errorWithNSError:error message:@"ad revenue foundation Json payload"];
        }
    }

    if (localDataJsonPayload != nil) {
        localStringJsonPayload = [ADJUtilF jsonDataFormat:localDataJsonPayload];
    }

    return [ADJNonEmptyString instanceFromString:localStringJsonPayload
                               sourceDescription:@"ad revenue string json payload"
                                          logger:logger];
}

@end



