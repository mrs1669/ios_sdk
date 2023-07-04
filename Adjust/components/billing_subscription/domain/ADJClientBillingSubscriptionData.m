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
+ (nullable instancetype)
    instanceFromClientWithLogger:(nonnull ADJLogger *)logger
    adjustBillingSubscription:(nullable ADJAdjustBillingSubscription *)adjustBillingSubscription
    externalCallbackParameterKeyValueArray:
        (nullable NSArray *)externalCallbackParameterKeyValueArray
    externalPartnerParameterKeyValueArray:
        (nullable NSArray *)externalPartnerParameterKeyValueArray
{
    if (adjustBillingSubscription == nil) {
        [logger errorClient:
            @"Cannot create billing subscription with nil adjust billing subscription value"];
        return nil;
    }

    ADJResult<ADJMoney *> *_Nonnull priceResult =
        [ADJMoney
         instanceFromAmountDecimalNumber:adjustBillingSubscription.priceDecimalNumber
         currency:adjustBillingSubscription.currency];
    if (priceResult.fail != nil) {
        [logger errorClient:@"Cannot create billing subscription with an invalid price"
                 resultFail:priceResult.fail];
        return nil;
    }
    if ([priceResult.value.amount isNegative]) {
        [logger infoClient:@"Price amount of billing subscription found to be negative."
         " Its validity will be determined server side"];
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull transactionIdResult =
        [ADJNonEmptyString instanceFromString:adjustBillingSubscription.transactionId];
    if (transactionIdResult.fail != nil) {
        [logger errorClient:@"Cannot create billing subscription with an invalid transaction id"
                 resultFail:transactionIdResult.fail];
        return nil;
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull receiptDataStringResult =
        [ADJNonEmptyString
            instanceFromString:[ADJUtilConv convertToBase64StringWithDataValue:
                                adjustBillingSubscription.receiptData]];
    if (receiptDataStringResult.fail != nil) {
        [logger errorClient:@"Cannot create billing subscription with an invalid receipt data"
                 resultFail:receiptDataStringResult.fail];
        return nil;
    }

    ADJResult<ADJTimestampMilli *> *_Nonnull transactionTimestampResult =
        [ADJTimestampMilli instanceWithNumberDoubleSecondsSince1970:
         adjustBillingSubscription.transactionDate != nil
         ? @(adjustBillingSubscription.transactionDate.timeIntervalSince1970) : nil];
    if (transactionTimestampResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot use invalid transaction date"
                  resultFail:transactionTimestampResult.fail];
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull salesRegionResult =
        [ADJNonEmptyString instanceFromString:adjustBillingSubscription.salesRegion];
    if (salesRegionResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot use invalid sales region in billing subscription"
                  resultFail:salesRegionResult.fail];
    }

    ADJStringMap *_Nullable callbackParameters =
        [ADJUtilConv
         clientStringMapWithKeyValueArray:
             externalCallbackParameterKeyValueArray
            ?: adjustBillingSubscription.callbackParameterKeyValueArray
         logger:logger
         processingFailMessage:@"Cannot use billing subscription callback parameters"
         addingFailMessage:@"Issue while adding to billing subscription callback parameters"
         emptyFailMessage:@"Could not use any valid billing subscription callback parameter"];

    ADJStringMap *_Nullable partnerParameters =
        [ADJUtilConv
         clientStringMapWithKeyValueArray:
             externalPartnerParameterKeyValueArray
            ?: adjustBillingSubscription.partnerParameterKeyValueArray
         logger:logger
         processingFailMessage:@"Cannot use billing subscription partner parameters"
         addingFailMessage:@"Issue while adding to billing subscription partner parameters"
         emptyFailMessage:@"Could not use any valid billing subscription partner parameter"];


    return [[ADJClientBillingSubscriptionData alloc]
            initWithPrice:priceResult.value
            transactionId:transactionIdResult.value
            receiptDataString:receiptDataStringResult.value
            transactionTimestamp:transactionTimestampResult.value
            salesRegion:salesRegionResult.value
            callbackParameters:callbackParameters
            partnerParameters:partnerParameters];
}

+ (nullable instancetype)
    instanceFromClientActionInjectedIoDataWithData:
        (nonnull ADJIoData *)clientActionInjectedIoData
    logger:(nonnull ADJLogger *)logger
{
    ADJStringMap *_Nonnull propertiesMap = clientActionInjectedIoData.propertiesMap;

    ADJResult<ADJMoney *> *_Nonnull priceResult =
        [ADJMoney instanceFromAmountIoValue:[propertiesMap pairValueWithKey:kPriceAmountKey]
                            currencyIoValue:[propertiesMap pairValueWithKey:kPriceCurrencyKey]];
    if (priceResult.fail != nil) {
        [logger debugDev:@"Invalid price money from client action injected io data"
              resultFail:priceResult.fail
               issueType:ADJIssueStorageIo];
        return nil;
    }

    ADJNonEmptyString *_Nullable transactionId =
        [propertiesMap pairValueWithKey:kTransactionIdKey];
    if (transactionId == nil) {
        [logger debugDev:
            @"Cannot decode ClientBillingSubscriptionData without valid transaction id"
            issueType:ADJIssueStorageIo];
        return nil;
    }

    ADJNonEmptyString *_Nullable receiptDataString =
        [propertiesMap pairValueWithKey:kReceiptDataStringKey];

    if (receiptDataString == nil) {
        [logger debugDev:
            @"Cannot decode ClientBillingSubscriptionData without valid receipt data string"
            issueType:ADJIssueStorageIo];
        return nil;
    }

    ADJResult<ADJTimestampMilli *> *_Nonnull transactionTimestampResult =
        [ADJTimestampMilli
         instanceFromIoDataValue:[propertiesMap pairValueWithKey:kTransactionTimestampKey]];
    if (transactionTimestampResult.failNonNilInput) {
        [logger debugDev:
            @"Cannot decode transactionTimestampResult from ClientBillingSubscriptionData io data"
              resultFail:transactionTimestampResult.fail
               issueType:ADJIssueStorageIo];
    }

    ADJNonEmptyString *_Nullable salesRegion =
        [propertiesMap pairValueWithKey:kSalesRegionKey];

    ADJStringMap *_Nullable callbackParametersMap =
        [clientActionInjectedIoData mapWithName:kCallbackParametersMapName];

    ADJStringMap *_Nullable partnerParametersMap =
        [clientActionInjectedIoData mapWithName:kPartnerParametersMapName];

    return [[ADJClientBillingSubscriptionData alloc]
            initWithPrice:priceResult.value
            transactionId:transactionId
            receiptDataString:receiptDataString
            transactionTimestamp:transactionTimestampResult.value
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
