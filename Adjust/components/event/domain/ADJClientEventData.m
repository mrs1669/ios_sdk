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
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *eventToken;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deduplicationId;
 @property (nullable, readonly, strong, nonatomic) ADJMoney *revenue;
 @property (nullable, readonly, strong, nonatomic) ADJStringMap *callbackParameters;
 @property (nullable, readonly, strong, nonatomic) ADJStringMap *partnerParameters;
 */

#pragma mark - Public constants
NSString *const ADJClientEventDataMetadataTypeValue = @"ClientEventData";

#pragma mark - Private constants
static NSString *const kEventTokenKey = @"eventToken";
static NSString *const kDeduplicationIdKey = @"deduplicationId";
static NSString *const kRevenueAmountKey = @"revenueAmount";
static NSString *const kRevenueCurrencyKey = @"revenueCurrency";
static NSString *const kCallbackParametersMapName = @"CALLBACK_PARAMETER_MAP";
static NSString *const kPartnerParametersMapName = @"PARTNER_PARAMETER_MAP";

@implementation ADJClientEventData
#pragma mark Instantiation
+ (nullable instancetype)
    instanceFromClientWithAdjustEvent:(nullable ADJAdjustEvent *)adjustEvent
    callbackParameterKeyValueArray:(nullable NSArray *)callbackParameterKeyValueArray
    partnerParameterKeyValueArray:(nullable NSArray *)partnerParameterKeyValueArray
    logger:(nonnull ADJLogger *)logger
{
    if (adjustEvent == nil) {
        [logger errorClient:@"Cannot create event with nil adjust event value"];
        return nil;
    }
    
    ADJResult<ADJNonEmptyString *> *_Nonnull eventTokenResult =
        [ADJNonEmptyString instanceFromString:adjustEvent.eventToken];
    if (eventTokenResult.fail != nil) {
        [logger errorClient:@"Cannot create event with invalid event token"
                 resultFail:eventTokenResult.fail];
        return nil;
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull deduplicationIdResult =
        [ADJNonEmptyString instanceFromString:adjustEvent.deduplicationId];
    if (deduplicationIdResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot set invalid deduplication id"
                  resultFail:deduplicationIdResult.fail];
    }

    ADJResult<ADJMoney *> *_Nonnull revenueResult = [self revenueWithAdjustEvent:adjustEvent];
    if (revenueResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot set invalid revenue"
                  resultFail:revenueResult.fail];
    }

    ADJOptionalFailsNN<ADJResult<ADJStringMap *> *> *_Nonnull callbackParametersOptFails =
        [ADJUtilConv convertToStringMapWithKeyValueArray:
         callbackParameterKeyValueArray ?: adjustEvent.callbackParameterKeyValueArray];

    for (ADJResultFail *_Nonnull optionalFail in callbackParametersOptFails.optionalFails) {
        [logger noticeClient:@"Issue while adding to event callback parameters"
                  resultFail:optionalFail];
    }

    ADJStringMap *_Nullable callbackParameters = nil;

    ADJResult<ADJStringMap *> *_Nonnull callbackParametersResult =
        callbackParametersOptFails.value;
    if (callbackParametersResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot use event callback parameters"
                  resultFail:callbackParametersResult.fail];
    } else if (callbackParametersResult.value != nil) {
        if ([callbackParametersResult.value isEmpty]) {
            [logger noticeClient:@"Could not use any valid event callback parameter"];
        } else {
            callbackParameters = callbackParametersResult.value;
        }
    }

    ADJOptionalFailsNN<ADJResult<ADJStringMap *> *> *_Nonnull partnerParametersOptFails =
        [ADJUtilConv convertToStringMapWithKeyValueArray:
         partnerParameterKeyValueArray ?: adjustEvent.partnerParameterKeyValueArray];

    for (ADJResultFail *_Nonnull optionalFail in callbackParametersOptFails.optionalFails) {
        [logger noticeClient:@"Issue while adding to event partner parameters"
                  resultFail:optionalFail];
    }

    ADJStringMap *_Nullable partnerParameters = nil;

    ADJResult<ADJStringMap *> *_Nonnull partnerParametersResult =
        partnerParametersOptFails.value;
    if (callbackParametersResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot use event partner parameters"
                  resultFail:partnerParametersResult.fail];
    } else if (partnerParametersResult.value != nil) {
        if ([partnerParametersResult.value isEmpty]) {
            [logger noticeClient:@"Could not use any valid event partner parameter"];
        } else {
            partnerParameters = partnerParametersResult.value;
        }
    }

    return [[ADJClientEventData alloc] initWithEventToken:eventTokenResult.value
                                          deduplicationId:deduplicationIdResult.value
                                                  revenue:revenueResult.value
                                       callbackParameters:callbackParameters
                                        partnerParameters:partnerParameters];
}

+ (nullable instancetype)
    instanceFromClientActionInjectedIoDataWithData:
        (nonnull ADJIoData *)clientActionInjectedIoData
    logger:(nonnull ADJLogger *)logger
{
    ADJStringMap *_Nonnull propertiesMap = clientActionInjectedIoData.propertiesMap;
    
    ADJNonEmptyString *_Nullable eventToken =
        [propertiesMap pairValueWithKey:kEventTokenKey];
    
    ADJAdjustEvent *_Nonnull adjustEvent =
        [[ADJAdjustEvent alloc] initWithEventToken:
         eventToken != nil ? eventToken.stringValue : nil];
    
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
                                  callbackParameterKeyValueArray:nil
                                   partnerParameterKeyValueArray:nil
                                                          logger:logger];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithEventToken:(nonnull ADJNonEmptyString *)eventToken
                           deduplicationId:(nullable ADJNonEmptyString *)deduplicationId
                                   revenue:(nullable ADJMoney *)revenue
                        callbackParameters:(nullable ADJStringMap *)callbackParameters
                         partnerParameters:(nullable ADJStringMap *)partnerParameters
{
    self = [super init];
    
    _eventToken = eventToken;
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
                                       key:kEventTokenKey
                       ioValueSerializable:self.eventToken];
    
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

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientEventDataMetadataTypeValue,
            kEventTokenKey, self.eventToken,
            kDeduplicationIdKey, self.deduplicationId,
            kRevenueAmountKey, self.revenue != nil ? self.revenue.amount : nil,
            kRevenueCurrencyKey, self.revenue != nil ? self.revenue.currency : nil,
            kCallbackParametersMapName, self.callbackParameters,
            kPartnerParametersMapName, self.partnerParameters,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    
    hashCode = ADJHashCodeMultiplier * hashCode + self.eventToken.hash;
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
    return [ADJUtilObj objectEquals:self.eventToken other:other.eventToken]
        && [ADJUtilObj objectEquals:self.deduplicationId other:other.deduplicationId]
        && [ADJUtilObj objectEquals:self.revenue other:other.revenue]
        && [ADJUtilObj objectEquals:self.callbackParameters other:other.callbackParameters]
        && [ADJUtilObj objectEquals:self.partnerParameters other:other.partnerParameters];
}

#pragma mark Internal Methods
+ (nonnull ADJResult<ADJMoney *> *)revenueWithAdjustEvent:(nonnull ADJAdjustEvent *)adjustEvent {
    if (adjustEvent.revenueAmountDecimalNumber == nil) {
        return [ADJMoney instanceFromAmountDoubleNumber:adjustEvent.revenueAmountDoubleNumber
                                               currency:adjustEvent.revenueCurrency];
    } else {
        return [ADJMoney instanceFromAmountDecimalNumber:adjustEvent.revenueAmountDecimalNumber
                                                currency:adjustEvent.revenueCurrency];
    }
}

+ (void)setRevenueWithAdjustEvent:(nonnull ADJAdjustEvent *)adjustEvent
                    propertiesMap:(nonnull ADJStringMap *)propertiesMap
                           logger:(nonnull ADJLogger *)logger
{
    ADJNonEmptyString *_Nullable revenueAmountIoValue =
        [propertiesMap pairValueWithKey:kRevenueAmountKey];
    ADJResult<ADJMoneyAmountBase *> *_Nonnull revenueAmountResult =
        [ADJMoneyAmountBase instanceFromIoValue:revenueAmountIoValue];
    if (revenueAmountResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot set invalid revenue amount from adjust event"
                  resultFail:revenueAmountResult.fail];
    }

    ADJNonEmptyString *_Nullable revenueCurrency =
        [propertiesMap pairValueWithKey:kRevenueCurrencyKey];
    
    if (revenueAmountResult.value == nil && revenueCurrency == nil) {
        return;
    }
    
    if ([revenueAmountResult.value isKindOfClass:[ADJMoneyDecimalAmount class]]) {
        ADJMoneyDecimalAmount *_Nonnull revenueDecimalAmount =
            (ADJMoneyDecimalAmount *)revenueAmountResult.value;
        
        [adjustEvent
         setRevenueWithNSDecimalNumber:revenueDecimalAmount.decimalNumberValue
         currency:revenueCurrency != nil ? revenueCurrency.stringValue : nil];
        
        return;
    }
    
    [adjustEvent
        setRevenueWithDoubleNumber:
         revenueAmountResult.value != nil ? @(revenueAmountResult.value.doubleValue) : nil
        currency:revenueCurrency != nil ? revenueCurrency.stringValue : nil];
}

@end
