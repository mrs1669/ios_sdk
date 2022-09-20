//
//  ADJClientEventData.m
//  Adjust
//
//  Created by Pedro S. on 18.03.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJClientEventData.h"

#import "ADJUtilObj.h"
#import "ADJUtilConv.h"
#import "ADJConstants.h"
#import "ADJUtilMap.h"
#import "ADJMoneyDecimalAmount.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *eventId;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deduplicationId;
 @property (nullable, readonly, strong, nonatomic) ADJMoney *revenue;
 @property (nullable, readonly, strong, nonatomic) ADJStringMap *callbackParameters;
 @property (nullable, readonly, strong, nonatomic) ADJStringMap *partnerParameters;
 */

#pragma mark - Public constants
NSString *const ADJClientEventDataMetadataTypeValue = @"ClientEventData";

#pragma mark - Private constants
static NSString *const kEventIdKey = @"eventId";
static NSString *const kDeduplicationIdKey = @"deduplicationId";
static NSString *const kRevenueAmountKey = @"revenueAmount";
static NSString *const kRevenueCurrencyKey = @"revenueCurrency";
static NSString *const kCallbackParametersMapName = @"CALLBACK_PARAMETER_MAP";
static NSString *const kPartnerParametersMapName = @"PARTNER_PARAMETER_MAP";

@implementation ADJClientEventData
#pragma mark Instantiation
+ (nullable instancetype)instanceFromClientWithAdjustEvent:(nullable ADJAdjustEvent *)adjustEvent
                                                    logger:(nonnull ADJLogger *)logger {
    if (adjustEvent == nil) {
        [logger error:@"Cannot create event with nil adjust event value"];
        return nil;
    }
    
    ADJNonEmptyString *_Nullable eventId =
    [ADJNonEmptyString instanceFromString:adjustEvent.eventId
                        sourceDescription:@"event id"
                                   logger:logger];
    if (eventId == nil) {
        return nil;
    }
    
    ADJNonEmptyString *_Nullable deduplicationId =
    [ADJNonEmptyString instanceFromOptionalString:adjustEvent.deduplicationId
                                sourceDescription:@"deduplication id"
                                           logger:logger];
    
    ADJMoney *_Nullable revenue = [self revenueWithAdjustEvent:adjustEvent
                                                        logger:logger];
    
    ADJStringMap *_Nullable callbackParameters =
    [ADJUtilConv convertToStringMapWithKeyValueArray:adjustEvent.callbackParameterKeyValueArray
                                   sourceDescription:@"event callback parameters"
                                              logger:logger];
    
    ADJStringMap *_Nullable partnerParameters =
    [ADJUtilConv convertToStringMapWithKeyValueArray:adjustEvent.partnerParameterKeyValueArray
                                   sourceDescription:@"event partner parameters"
                                              logger:logger];
    
    return [[self alloc] initWithEventId:eventId
                         deduplicationId:deduplicationId
                                 revenue:revenue
                      callbackParameters:callbackParameters
                       partnerParameters:partnerParameters];
}

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:
(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger {
    ADJStringMap *_Nonnull propertiesMap = clientActionInjectedIoData.propertiesMap;
    
    ADJNonEmptyString *_Nullable eventId =
    [propertiesMap pairValueWithKey:kEventIdKey];
    
    ADJAdjustEvent *_Nonnull adjustEvent =
    [[ADJAdjustEvent alloc] initWithEventId:eventId != nil ? eventId.stringValue : nil];
    
    ADJNonEmptyString *_Nullable deduplicationId =
    [propertiesMap pairValueWithKey:kDeduplicationIdKey];
    if (deduplicationId != nil) {
        [adjustEvent setDeduplicationId:deduplicationId.stringValue];
    }
    
    [self setRevenueWithAdjustEvent:adjustEvent
                      propertiesMap:propertiesMap
                             logger:logger];
    
    ADJStringMap *_Nullable callbackParametersMap =
    [clientActionInjectedIoData mapWithName:kCallbackParametersMapName];
    
    if (callbackParametersMap != nil) {
        for (NSString *_Nonnull callbackParameterKey in callbackParametersMap.map) {
            [adjustEvent
             addCallbackParameterWithKey:callbackParameterKey
             value:[callbackParametersMap.map objectForKey:callbackParameterKey].stringValue];
        }
    }
    
    ADJStringMap *_Nullable partnerParametersMap =
    [clientActionInjectedIoData mapWithName:kPartnerParametersMapName];
    
    if (partnerParametersMap != nil) {
        for (NSString *_Nonnull partnerParameterKey in partnerParametersMap.map) {
            [adjustEvent
             addPartnerParameterWithKey:partnerParameterKey
             value:[partnerParametersMap.map objectForKey:partnerParameterKey].stringValue];
        }
    }
    
    return [ADJClientEventData instanceFromClientWithAdjustEvent:adjustEvent
                                                          logger:logger];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithEventId:(nonnull ADJNonEmptyString *)eventId
                        deduplicationId:(nullable ADJNonEmptyString *)deduplicationId
                                revenue:(nullable ADJMoney *)revenue
                     callbackParameters:(nullable ADJStringMap *)callbackParameters
                      partnerParameters:(nullable ADJStringMap *)partnerParameters {
    self = [super init];
    
    _eventId = eventId;
    _deduplicationId = deduplicationId;
    _revenue = revenue;
    _callbackParameters = callbackParameters;
    _partnerParameters = partnerParameters;
    
    return self;
}

#pragma mark Public API
#pragma mark - ADJClientActionIoDataInjectable
- (void)injectIntoClientActionIoDataBuilder: (nonnull ADJIoDataBuilder *)clientActionIoDataBuilder {
    ADJStringMapBuilder *_Nonnull propertiesMapBuilder =
    clientActionIoDataBuilder.propertiesMapBuilder;
    
    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kEventIdKey
                       ioValueSerializable:self.eventId];
    
    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kDeduplicationIdKey
                       ioValueSerializable:self.deduplicationId];
    
    if (self.revenue != nil) {
        [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                           key:kRevenueAmountKey
                           ioValueSerializable:self.revenue.amount];
        
        [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                           key:kRevenueCurrencyKey
                           ioValueSerializable:self.revenue.currency];
    }
    
    if (self.callbackParameters != nil) {
        ADJStringMapBuilder *_Nonnull callbackParametersMapBuider =
        [clientActionIoDataBuilder
         addAndReturnNewMapBuilderByName:kCallbackParametersMapName];
        
        [callbackParametersMapBuider addAllPairsWithStringMap:self.callbackParameters];
    }
    
    if (self.partnerParameters != nil) {
        ADJStringMapBuilder *_Nonnull partnerParametersMapBuider =
        [clientActionIoDataBuilder
         addAndReturnNewMapBuilderByName:kPartnerParametersMapName];
        
        [partnerParametersMapBuider addAllPairsWithStringMap:self.partnerParameters];
    }
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientEventDataMetadataTypeValue,
            kEventIdKey, self.eventId,
            kDeduplicationIdKey, self.deduplicationId,
            kRevenueAmountKey, self.revenue != nil ? self.revenue.amount : nil,
            kRevenueCurrencyKey, self.revenue != nil ? self.revenue.currency : nil,
            kCallbackParametersMapName, self.callbackParameters,
            kPartnerParametersMapName, self.partnerParameters,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    
    hashCode = ADJHashCodeMultiplier * hashCode + self.eventId.hash;
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.deduplicationId];
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.revenue];
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
    
    if (![object isKindOfClass:[ADJClientEventData class]]) {
        return NO;
    }
    
    ADJClientEventData *other = (ADJClientEventData *)object;
    return [ADJUtilObj objectEquals:self.eventId other:other.eventId]
    && [ADJUtilObj objectEquals:self.deduplicationId other:other.deduplicationId]
    && [ADJUtilObj objectEquals:self.revenue other:other.revenue]
    && [ADJUtilObj objectEquals:self.callbackParameters other:other.callbackParameters]
    && [ADJUtilObj objectEquals:self.partnerParameters other:other.partnerParameters];
}

#pragma mark Internal Methods
+ (nullable ADJMoney *)revenueWithAdjustEvent:(nonnull ADJAdjustEvent *)adjustEvent
                                       logger:(nonnull ADJLogger *)logger {
    if (adjustEvent.revenueCurrency == nil
        && adjustEvent.revenueAmountDoubleNumber == nil
        && adjustEvent.revenueAmountDecimalNumber == nil)
    {
        return nil;
    }
    
    if (adjustEvent.revenueAmountDecimalNumber == nil) {
        return [ADJMoney instanceFromAmountDoubleNumber:adjustEvent.revenueAmountDoubleNumber
                                               currency:adjustEvent.revenueCurrency
                                                 source:@"event double revenue"
                                                 logger:logger];
    }
    
    return [ADJMoney instanceFromAmountDecimalNumber:adjustEvent.revenueAmountDecimalNumber
                                            currency:adjustEvent.revenueCurrency
                                              source:@"event decimal revenue"
                                              logger:logger];
}

+ (void)setRevenueWithAdjustEvent:(nonnull ADJAdjustEvent *)adjustEvent
                    propertiesMap:(nonnull ADJStringMap *)propertiesMap
                           logger:(nonnull ADJLogger *)logger {
    ADJNonEmptyString *_Nullable revenueAmountIoValue =
    [propertiesMap pairValueWithKey:kRevenueAmountKey];
    ADJMoneyAmountBase *_Nullable revenueAmount =
    [ADJMoneyAmountBase instanceFromOptionalIoValue:revenueAmountIoValue
                                             logger:logger];
    ADJNonEmptyString *_Nullable revenueCurrency =
    [propertiesMap pairValueWithKey:kRevenueCurrencyKey];
    
    if (revenueAmount == nil && revenueCurrency == nil) {
        return;
    }
    
    if ([revenueAmount isKindOfClass:[ADJMoneyDecimalAmount class]]) {
        ADJMoneyDecimalAmount *_Nonnull revenueDecimalAmount =
        (ADJMoneyDecimalAmount *)revenueAmount;
        
        [adjustEvent
         setRevenueWithNSDecimalNumber:revenueDecimalAmount.decimalNumberValue
         currency:revenueCurrency != nil ? revenueCurrency.stringValue : nil];
        
        return;
    }
    
    [adjustEvent setRevenueWithDoubleNumber:revenueAmount != nil ? @(revenueAmount.doubleValue) : nil
                                   currency:revenueCurrency != nil ? revenueCurrency.stringValue : nil];
}

@end

