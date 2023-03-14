//
//  ADJAsaAttributionStateData.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAsaAttributionStateData.h"

#import "ADJBooleanWrapper.h"
#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (readonly, assign, nonatomic) BOOL hasReceivedValidAsaClickResponse;
 @property (readonly, assign, nonatomic) BOOL hasReceivedAdjustAttribution;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *cachedToken;
 @property (nullable, readonly, strong, nonatomic) ADJTimestampMilli *cacheReadTimestamp;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *errorReason;
 */

#pragma mark - Public constants
NSString *const ADJAsaAttributionStateDataMetadataTypeValue = @"AsaAttributionStateData";

#pragma mark - Private constants
static NSString *const kHasReceivedValidAsaClickResponseKey = @"hasReceivedValidAsaClickResponse";
static NSString *const kHasReceivedAdjustAttributionKey = @"hasReceivedAdjustAttribution";
static NSString *const kCachedTokenKey = @"cachedToken";
static NSString *const kCacheReadTimestampKey = @"cacheReadTimestamp";
static NSString *const kErrorReasonKey = @"errorReason";

@implementation ADJAsaAttributionStateData
// instantiation
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJResultNN<ADJAsaAttributionStateData *> *> *)
    instanceFromIoData:(nonnull ADJIoData *)ioData
{
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
        [ioData isExpectedMetadataTypeValue:ADJAsaAttributionStateDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [[ADJCollectionAndValue alloc] initWithValue:
                [ADJResultNN
                 failWithMessage:@"Cannot create asa attribution state data from io data"
                 key:@"unexpected metadata type value fail"
                 value:[unexpectedMetadataTypeValueFail foundationDictionary]]];
    }

    ADJResultNN<ADJBooleanWrapper *> *_Nonnull hasReceivedValidAsaClickResponseResult =
        [ADJBooleanWrapper instanceFromIoValue:
         [ioData.propertiesMap pairValueWithKey:kHasReceivedValidAsaClickResponseKey]];
    if (hasReceivedValidAsaClickResponseResult.fail != nil) {
        return [[ADJCollectionAndValue alloc] initWithValue:
                [ADJResultNN
                failWithMessage:@"Cannot create asa attribution state data from io data"
                key:@"hasReceivedValidAsaClickResponse fail"
                value:[hasReceivedValidAsaClickResponseResult.fail foundationDictionary]]];
    }

    ADJResultNN<ADJBooleanWrapper *> *_Nonnull hasReceivedAdjustAttributionResult =
        [ADJBooleanWrapper instanceFromIoValue:
         [ioData.propertiesMap pairValueWithKey:kHasReceivedAdjustAttributionKey]];
    if (hasReceivedAdjustAttributionResult.fail != nil) {
        return [[ADJCollectionAndValue alloc] initWithValue:
                [ADJResultNN
                failWithMessage:@"Cannot create asa attribution state data from io data"
                key:@"hasReceivedAdjustAttributionResult fail"
                value:[hasReceivedAdjustAttributionResult.fail foundationDictionary]]];
    }

    ADJNonEmptyString *_Nullable cachedToken =
        [ioData.propertiesMap pairValueWithKey:kCachedTokenKey];

    NSArray<ADJResultFail *> *_Nullable optionalFails = nil;

    ADJResultNL<ADJTimestampMilli *> *_Nonnull cacheReadTimestampResult =
        [ADJTimestampMilli instanceFromOptionalIoDataValue:
         [ioData.propertiesMap pairValueWithKey:kCacheReadTimestampKey]];
    if (cacheReadTimestampResult.fail != nil) {
        ADJResultFailBuilder *_Nonnull resultFailBuilder =
            [[ADJResultFailBuilder alloc] initWithMessage:
             @"Cannot use invalid cache read timestamp in asa attribution state data from io data"];
        [resultFailBuilder withKey:@"cacheReadTimestamp fail"
                             value:[cacheReadTimestampResult.fail foundationDictionary]];
        optionalFails = [NSArray arrayWithObject:[resultFailBuilder build]];
    }

    ADJNonEmptyString *_Nullable errorReason =
        [ioData.propertiesMap pairValueWithKey:kErrorReasonKey];

    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFails
            value:[[ADJAsaAttributionStateData alloc]
                   initWithHasReceivedValidAsaClickResponse:
                       hasReceivedValidAsaClickResponseResult.value.boolValue
                   hasReceivedAdjustAttribution:hasReceivedAdjustAttributionResult.value.boolValue
                   cachedToken:cachedToken
                   cacheReadTimestamp:cacheReadTimestampResult.value
                   errorReason:errorReason]];
}

- (nonnull instancetype)initWithIntialState {
    return [self initWithHasReceivedValidAsaClickResponse:NO
                             hasReceivedAdjustAttribution:NO
                                              cachedToken:nil
                                       cacheReadTimestamp:nil
                                              errorReason:nil];
}

- (nonnull instancetype)
    initWithHasReceivedValidAsaClickResponse:(BOOL)hasReceivedValidAsaClickResponse
    hasReceivedAdjustAttribution:(BOOL)hasReceivedAdjustAttribution
    cachedToken:(nullable ADJNonEmptyString *)cachedToken
    cacheReadTimestamp:(nullable ADJTimestampMilli *)cacheReadTimestamp
    errorReason:(nullable ADJNonEmptyString *)errorReason
{
    self = [super init];

    _hasReceivedValidAsaClickResponse = hasReceivedValidAsaClickResponse;
    _hasReceivedAdjustAttribution = hasReceivedAdjustAttribution;
    _cachedToken = cachedToken;
    _cacheReadTimestamp = cacheReadTimestamp;
    _errorReason = errorReason;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull ADJAsaAttributionStateData *)withHasReceivedValidAsaClickResponse {
    return [[ADJAsaAttributionStateData alloc]
            initWithHasReceivedValidAsaClickResponse:YES
            hasReceivedAdjustAttribution:self.hasReceivedAdjustAttribution
            cachedToken:self.cachedToken
            cacheReadTimestamp:self.cacheReadTimestamp
            errorReason:self.errorReason];
}
- (nonnull ADJAsaAttributionStateData *)withHasReceivedAdjustAttribution {
    return [[ADJAsaAttributionStateData alloc]
            initWithHasReceivedValidAsaClickResponse:self.hasReceivedValidAsaClickResponse
            hasReceivedAdjustAttribution:YES
            cachedToken:self.cachedToken
            cacheReadTimestamp:self.cacheReadTimestamp
            errorReason:self.errorReason];
}
- (nonnull ADJAsaAttributionStateData *)withToken:(nullable ADJNonEmptyString *)token
                                        timestamp:(nullable ADJTimestampMilli *)timestamp
                                      errorReason:(nullable ADJNonEmptyString *)errorReason
{
    return [[ADJAsaAttributionStateData alloc]
            initWithHasReceivedValidAsaClickResponse:self.hasReceivedValidAsaClickResponse
            hasReceivedAdjustAttribution:self.hasReceivedAdjustAttribution
            cachedToken:token
            cacheReadTimestamp:timestamp
            errorReason:errorReason];
}

#pragma mark - ADJIoDataSerializable
- (nonnull ADJIoData *)toIoData {
    ADJIoDataBuilder *_Nonnull ioDataBuilder =
    [[ADJIoDataBuilder alloc]
     initWithMetadataTypeValue:ADJAsaAttributionStateDataMetadataTypeValue];

    [ADJUtilMap
     injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
     key:kHasReceivedValidAsaClickResponseKey
     ioValueSerializable:
         [ADJBooleanWrapper instanceFromBool:self.hasReceivedValidAsaClickResponse]];

    [ADJUtilMap
     injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
     key:kHasReceivedAdjustAttributionKey
     ioValueSerializable:
         [ADJBooleanWrapper instanceFromBool:self.hasReceivedAdjustAttribution]];

    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
                                       key:kCachedTokenKey
                       ioValueSerializable:self.cachedToken];

    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
                                       key:kCacheReadTimestampKey
                       ioValueSerializable:self.cacheReadTimestamp];

    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
                                       key:kErrorReasonKey
                       ioValueSerializable:self.errorReason];

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJAsaAttributionStateDataMetadataTypeValue,
            kHasReceivedValidAsaClickResponseKey, @(self.hasReceivedValidAsaClickResponse),
            kHasReceivedAdjustAttributionKey, @(self.hasReceivedAdjustAttribution),
            kCachedTokenKey, self.cachedToken,
            kCacheReadTimestampKey, self.cacheReadTimestamp,
            kErrorReasonKey, self.errorReason,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + @(self.hasReceivedValidAsaClickResponse).hash;
    hashCode = ADJHashCodeMultiplier * hashCode + @(self.hasReceivedAdjustAttribution).hash;
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.cachedToken];
    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.cacheReadTimestamp];
    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.errorReason];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJAsaAttributionStateData class]]) {
        return NO;
    }

    ADJAsaAttributionStateData *other = (ADJAsaAttributionStateData *)object;
    return self.hasReceivedValidAsaClickResponse == other.hasReceivedValidAsaClickResponse
        && self.hasReceivedAdjustAttribution == other.hasReceivedAdjustAttribution
        && [ADJUtilObj objectEquals:self.cachedToken other:other.cachedToken]
        && [ADJUtilObj objectEquals:self.cacheReadTimestamp other:other.cacheReadTimestamp]
        && [ADJUtilObj objectEquals:self.errorReason other:other.errorReason];
}

@end

