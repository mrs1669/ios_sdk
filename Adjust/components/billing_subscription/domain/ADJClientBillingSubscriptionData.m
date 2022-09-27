//
//  ADJClientBillingSubscriptionData.m
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientBillingSubscriptionData.h"

#import "ADJUtilConv.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJUtilMap.h"
#import "ADJConstantsParam.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJMoney *price;
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *transactionId;
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *receiptDataString;
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *billingStore;
 @property (nullable, readonly, strong, nonatomic) ADJTimestampMilli *transactionTimestamp;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *salesRegion;
 @property (nullable, readonly, strong, nonatomic) ADJStringMap *callbackParameters;
 @property (nullable, readonly, strong, nonatomic) ADJStringMap *partnerParameters;
 */

#pragma mark - Public constants
NSString *const ADJClientBillingSubcriptionDataMetadataTypeValue = @"ClientBillingSubcriptionData";

#pragma mark - Private constants
static NSString *const kPriceAmountKey = @"priceAmount";
static NSString *const kPriceCurrencyKey = @"priceCurrency";
static NSString *const kTransactionIdKey = @"transactionId";
static NSString *const kReceiptDataStringKey = @"receiptDataString";
static NSString *const kTransactionTimestampKey = @"transactionTimestamp";
static NSString *const kSalesRegionKey = @"salesRegion";
static NSString *const kCallbackParametersMapName = @"CALLBACK_PARAMETER_MAP";
static NSString *const kPartnerParametersMapName = @"PARTNER_PARAMETER_MAP";

@implementation ADJClientBillingSubscriptionData
+ (nullable instancetype)instanceFromClientWithAdjustBillingSubscription:
(nullable ADJAdjustBillingSubscription *)adjustBillingSubscription
                                                                  logger:(nonnull ADJLogger *)logger {
    if (adjustBillingSubscription == nil) {
        [logger error:@"Cannot create billing subscription"
         " with nil adjust billing subscription value"];
        return nil;
    }

    ADJMoney *_Nullable price =
    [ADJMoney instanceFromAmountDecimalNumber:adjustBillingSubscription.priceDecimalNumber
                                     currency:adjustBillingSubscription.currency
                                       source:@"billing subscription price"
                                       logger:logger];
    if (price == nil) {
        [logger error:@"Cannot create billing subscription"
         " without a valid price"];
        return nil;
    }

    ADJNonEmptyString *_Nullable transactionId =
    [ADJNonEmptyString instanceFromString:adjustBillingSubscription.transactionId
                        sourceDescription:@"transaction id"
                                   logger:logger];
    if (transactionId == nil) {
        [logger error:@"Cannot create billing subscription"
         " without a valid transaction id"];
        return nil;
    }

    ADJNonEmptyString *_Nullable receiptDataString =
    [ADJNonEmptyString
     instanceFromString:
         [ADJUtilConv convertToBase64StringWithDataValue:
          adjustBillingSubscription.receiptData]
     sourceDescription:@"billing subscription receipt data string"
     logger:logger];

    if (receiptDataString == nil) {
        [logger error:@"Cannot create billing subscription"
         " without a valid receiptData"];
        return nil;
    }

    ADJTimestampMilli *_Nullable transactionTimestamp =
    [ADJTimestampMilli instanceWithNSDateValue:adjustBillingSubscription.transactionDate
                                        logger:logger];
    if (transactionTimestamp == nil) {
        [logger error:@"Cannot create billing subscription"
         " without a valid transaction timestamp"];
        return nil;
    }

    ADJNonEmptyString *_Nullable salesRegion =
    [ADJNonEmptyString instanceFromOptionalString:adjustBillingSubscription.salesRegion
                                sourceDescription:@"billing subscription sales region"
                                           logger:logger];

    ADJStringMap *_Nullable callbackParameters =
    [ADJUtilConv
     convertToStringMapWithKeyValueArray:
         adjustBillingSubscription.callbackParameterKeyValueArray
     sourceDescription:@"billing subscription callback parameters"
     logger:logger];

    ADJStringMap *_Nullable partnerParameters =
    [ADJUtilConv
     convertToStringMapWithKeyValueArray:
         adjustBillingSubscription.partnerParameterKeyValueArray
     sourceDescription:@"billing subscription partner parameters"
     logger:logger];

    return [[self alloc] initWithPrice:price
                         transactionId:transactionId
                     receiptDataString:receiptDataString
                  transactionTimestamp:transactionTimestamp
                           salesRegion:salesRegion
                    callbackParameters:callbackParameters
                     partnerParameters:partnerParameters];
}

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:
(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger {
    ADJStringMap *_Nonnull propertiesMap = clientActionInjectedIoData.propertiesMap;

    ADJNonEmptyString *_Nullable priceAmountIoValue =
    [propertiesMap pairValueWithKey:kPriceAmountKey];
    ADJMoneyAmountBase *_Nullable priceAmount =
    [ADJMoneyAmountBase instanceFromIoValue:priceAmountIoValue
                                     logger:logger];

    if (priceAmount == nil) {
        [logger error:@"Cannot decode ClientBillingSubscriptionData"
         " without valid price amount"];
        return nil;
    }

    ADJNonEmptyString *_Nullable priceCurrency =
    [propertiesMap pairValueWithKey:kPriceCurrencyKey];

    if (priceCurrency == nil) {
        [logger error:@"Cannot decode ClientBillingSubscriptionData"
         " without valid price currency"];
        return nil;
    }

    ADJNonEmptyString *_Nullable transactionId =
    [propertiesMap pairValueWithKey:kTransactionIdKey];
    if (transactionId == nil) {
        [logger error:@"Cannot decode ClientBillingSubscriptionData"
         " without valid transaction id"];
        return nil;
    }

    ADJNonEmptyString *_Nullable receiptDataString =
    [propertiesMap pairValueWithKey:kReceiptDataStringKey];

    if (receiptDataString == nil) {
        [logger error:@"Cannot decode ClientBillingSubscriptionData"
         " without valid receipt data string"];
        return nil;
    }

    ADJTimestampMilli *_Nullable transactionTimestamp =
    [ADJTimestampMilli
     instanceFromOptionalIoDataValue:
         [propertiesMap pairValueWithKey:kTransactionTimestampKey]
     logger:logger];

    ADJNonEmptyString *_Nullable salesRegion =
    [propertiesMap pairValueWithKey:kSalesRegionKey];

    ADJStringMap *_Nullable callbackParametersMap =
    [clientActionInjectedIoData mapWithName:kCallbackParametersMapName];

    ADJStringMap *_Nullable partnerParametersMap =
    [clientActionInjectedIoData mapWithName:kPartnerParametersMapName];

    return [[self alloc] initWithPrice:[[ADJMoney alloc] initWithAmount:priceAmount
                                                               currency:priceCurrency]
                         transactionId:transactionId
                     receiptDataString:receiptDataString
                  transactionTimestamp:transactionTimestamp
                           salesRegion:salesRegion
                    callbackParameters:callbackParametersMap
                     partnerParameters:partnerParametersMap];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithPrice:(nonnull ADJMoney *)price
                        transactionId:(nonnull ADJNonEmptyString *)transactionId
                    receiptDataString:(nonnull ADJNonEmptyString *)receiptDataString
                 transactionTimestamp:(nullable ADJTimestampMilli *)transactionTimestamp
                          salesRegion:(nullable ADJNonEmptyString *)salesRegion
                   callbackParameters:(nullable ADJStringMap *)callbackParameters
                    partnerParameters:(nullable ADJStringMap *)partnerParameters {
    self = [super init];

    _price = price;
    _transactionId = transactionId;
    _receiptDataString = receiptDataString;
    _transactionTimestamp = transactionTimestamp;
    _billingStore = [[ADJNonEmptyString alloc]
                     initWithConstStringValue:ADJParamSubscriptionBillingStoreValue];
    _salesRegion = salesRegion;
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
                                       key:kPriceAmountKey
                       ioValueSerializable:self.price.amount];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kPriceCurrencyKey
                       ioValueSerializable:self.price.currency];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kTransactionIdKey
                       ioValueSerializable:self.transactionId];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kReceiptDataStringKey
                       ioValueSerializable:self.receiptDataString];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kTransactionTimestampKey
                       ioValueSerializable:self.transactionTimestamp];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kSalesRegionKey
                       ioValueSerializable:self.salesRegion];

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

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientBillingSubcriptionDataMetadataTypeValue,
            kPriceAmountKey, self.price.amount,
            kPriceCurrencyKey, self.price.currency,
            kTransactionIdKey, self.transactionId,
            kReceiptDataStringKey, self.receiptDataString,
            kTransactionTimestampKey, self.transactionTimestamp,
            kSalesRegionKey, self.salesRegion,
            kCallbackParametersMapName, self.callbackParameters,
            kPartnerParametersMapName, self.partnerParameters,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + self.price.hash;
    hashCode = ADJHashCodeMultiplier * hashCode + self.transactionId.hash;
    hashCode = ADJHashCodeMultiplier * hashCode + self.receiptDataString.hash;
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.transactionTimestamp];
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.salesRegion];
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

    if (![object isKindOfClass:[ADJClientBillingSubscriptionData class]]) {
        return NO;
    }

    ADJClientBillingSubscriptionData *other = (ADJClientBillingSubscriptionData *)object;
    return [ADJUtilObj objectEquals:self.price other:other.price]
    && [ADJUtilObj objectEquals:self.transactionId other:other.transactionId]
    && [ADJUtilObj objectEquals:self.receiptDataString other:other.receiptDataString]
    && [ADJUtilObj objectEquals:self.transactionTimestamp other:other.transactionTimestamp]
    && [ADJUtilObj objectEquals:self.salesRegion other:other.salesRegion]
    && [ADJUtilObj objectEquals:self.callbackParameters other:other.callbackParameters]
    && [ADJUtilObj objectEquals:self.partnerParameters other:other.partnerParameters];
}

@end
