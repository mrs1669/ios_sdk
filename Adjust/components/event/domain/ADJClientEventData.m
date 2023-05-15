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
#import "ADJMoneyDoubleAmount.h"

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
    instanceFromClientWithLogger:(nonnull ADJLogger *)logger
    adjustEvent:(nullable ADJAdjustEvent *)adjustEvent
    externalCallbackParameterKeyValueArray:
        (nullable NSArray *)externalCallbackParameterKeyValueArray
    externalPartnerParameterKeyValueArray:
        (nullable NSArray *)externalPartnerParameterKeyValueArray
    externalCallbackParametersStringMap:
        (nullable ADJStringMap *)externalCallbackParametersStringMap
    externalPartnerParametersStringMap:(nullable ADJStringMap *)externalPartnerParametersStringMap
    externalRevenue:(nullable ADJMoney *)externalRevenue
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

    ADJMoney *_Nullable revenue = nil;
    if (externalRevenue != nil) {
        revenue = externalRevenue;
    } else {
        revenue = [self revenueWithLogger:logger adjustEvent:adjustEvent];
    }

    ADJStringMap *_Nullable callbackParameters = nil;
    if (externalCallbackParametersStringMap != nil) {
        callbackParameters = externalCallbackParametersStringMap;
    } else {
        callbackParameters =
            [ADJUtilConv
             clientStringMapWithKeyValueArray:
                 externalCallbackParameterKeyValueArray
                ?: adjustEvent.callbackParameterKeyValueArray
             logger:logger
             processingFailMessage:@"Cannot use event callback parameters"
             addingFailMessage:@"Issue while adding to event callback parameters"
             emptyFailMessage:@"Could not use any valid event callback parameter"];
    }

    ADJStringMap *_Nullable partnerParameters = nil;
    if (externalPartnerParametersStringMap != nil) {
        partnerParameters = externalPartnerParametersStringMap;
    } else {
        partnerParameters =
            [ADJUtilConv
             clientStringMapWithKeyValueArray:
                 externalPartnerParameterKeyValueArray
                ?: adjustEvent.partnerParameterKeyValueArray
             logger:logger
             processingFailMessage:@"Cannot use event partner parameters"
             addingFailMessage:@"Issue while adding to event partner parameters"
             emptyFailMessage:@"Could not use any valid event partner parameter"];
    }

    return [[ADJClientEventData alloc] initWithEventToken:eventTokenResult.value
                                          deduplicationId:deduplicationIdResult.value
                                                  revenue:revenue
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

    ADJResult<ADJMoney *> *_Nonnull revenueResult =
        [ADJMoney
         instanceFromAmountIoValue:[propertiesMap pairValueWithKey:kRevenueAmountKey]
         currencyIoValue:[propertiesMap pairValueWithKey:kRevenueCurrencyKey]];
    if (revenueResult.failNonNilInput != nil) {
        [logger debugDev:@"Invalid revenue money from client action injected io data"
              resultFail:revenueResult.fail
               issueType:ADJIssueStorageIo];
    }

    ADJStringMap *_Nullable callbackParametersMap =
        [clientActionInjectedIoData mapWithName:kCallbackParametersMapName];

    ADJStringMap *_Nullable partnerParametersMap =
        [clientActionInjectedIoData mapWithName:kPartnerParametersMapName];

    return [ADJClientEventData instanceFromClientWithLogger:logger
                                                adjustEvent:adjustEvent
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
+ (nullable ADJMoney *)revenueWithLogger:(nonnull ADJLogger *)logger
                             adjustEvent:(nonnull ADJAdjustEvent *)adjustEvent
{
    if (adjustEvent.revenueCurrency == nil
        && adjustEvent.revenueAmountDoubleNumber == nil
        && adjustEvent.revenueAmountDecimalNumber == nil)
    {
        return nil;
    }

    if (adjustEvent.revenueAmountDoubleNumber != nil
        && adjustEvent.revenueAmountDecimalNumber != nil)
    {
        [logger noticeClient:@"Both double and decimal formats were used for event revenue."
         " Will default to double"];
    }
    { // process possible double amount
        ADJResult<ADJMoneyDoubleAmount *> *_Nonnull moneyDoubleAmountResult =
            [ADJMoneyDoubleAmount instanceFromDoubleNumberValue:
             adjustEvent.revenueAmountDoubleNumber];
        if (moneyDoubleAmountResult.failNonNilInput != nil) {
            [logger errorClient:@"Cannot use invalid double amount in event"
                     resultFail:moneyDoubleAmountResult.fail];
            return nil;
        }
        if (moneyDoubleAmountResult.value != nil) {
            ADJResult<ADJMoney *> *_Nonnull moneyDoubleResult =
                [ADJMoney instanceFromAmount:moneyDoubleAmountResult.value
                                    currency:adjustEvent.revenueCurrency];
            if (moneyDoubleResult.fail != nil) {
                [logger errorClient:@"Cannot use invalid revenue with double amount in event"
                         resultFail:moneyDoubleResult.fail];
                return nil;
            }
            return moneyDoubleResult.value;
        }
    }
    { // process possible decimal amount
        ADJResult<ADJMoneyDecimalAmount *> *_Nonnull moneyDecimalAmountResult =
            [ADJMoneyDecimalAmount instanceFromDecimalNumberValue:
             adjustEvent.revenueAmountDecimalNumber];
        if (moneyDecimalAmountResult.failNonNilInput != nil) {
            [logger errorClient:@"Cannot use invalid decimal amount in event"
                     resultFail:moneyDecimalAmountResult.fail];
            return nil;
        }
        if (moneyDecimalAmountResult.value != nil) {
            ADJResult<ADJMoney *> *_Nonnull moneyDecimalResult =
                [ADJMoney instanceFromAmount:moneyDecimalAmountResult.value
                                    currency:adjustEvent.revenueCurrency];
            if (moneyDecimalResult.fail != nil) {
                [logger errorClient:@"Cannot use invalid revenue with decimal amount in event"
                         resultFail:moneyDecimalResult.fail];
                return nil;
            }
            return moneyDecimalResult.value;
        }
    }

    [logger errorClient:@"Cannot use revenue without any amount"];
    return nil;
}

@end
