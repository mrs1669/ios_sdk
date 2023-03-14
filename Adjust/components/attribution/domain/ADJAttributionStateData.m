//
//  ADJAttributionStateData.m
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAttributionStateData.h"

#import "ADJBooleanWrapper.h"
#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public constants
ADJAttributionStateStatus const ADJAttributionStateDataMetadataTypeValue = @"AttributionStateData";
ADJAttributionStateStatus const ADJAttributionStateStatusWaitingForInstallSessionTracking =
    @"WaitingForInstallSessionTracking";
ADJAttributionStateStatus const ADJAttributionStateStatusCanAsk = @"CanAsk";
ADJAttributionStateStatus const ADJAttributionStateStatusIsAsking = @"IsAsking";
ADJAttributionStateStatus const ADJAttributionStateStatusHasAttribution = @"HasAttribution";
ADJAttributionStateStatus const ADJAttributionStateStatusUnavailable = @"Unavailable";

#pragma mark - Public properties
/* .h
 @property (readonly, assign, nonatomic) BOOL installSessionTracked;
 @property (readonly, assign, nonatomic) BOOL unavailableAttribution;
 @property (readonly, assign, nonatomic) BOOL isAsking;
 @property (nullable, readonly, strong, nonatomic) ADJAttributionData *attributionData;
 */

#pragma mark - Private constants
static NSString *const kInstallSessionTrackedKey = @"installSessionTracked";
static NSString *const kUnavailableAttributionKey = @"unavailableAttribution";
static NSString *const kIsAskingKey = @"isAsking";
static NSString *const kAttributionDataMapName = @"2_ATTRIBUTION_MAP";

@implementation ADJAttributionStateData
#pragma mark Instantiation
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJResultNN<ADJAttributionStateData *> *> *)
    instanceFromIoData:(nonnull ADJIoData *)ioData
{
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
        [ioData isExpectedMetadataTypeValue:ADJAttributionStateDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [[ADJCollectionAndValue alloc] initWithValue:
                [ADJResultNN
                 failWithMessage:@"Cannot create attribution state data from io data"
                 key:@"unexpected metadata type value fail"
                 value:[unexpectedMetadataTypeValueFail foundationDictionary]]];
    }

    ADJResultNN<ADJBooleanWrapper *> *_Nonnull installSessionTrackedResult =
        [ADJBooleanWrapper instanceFromIoValue:
         [ioData.propertiesMap pairValueWithKey:kInstallSessionTrackedKey]];
    if (installSessionTrackedResult.fail != nil) {
        return [[ADJCollectionAndValue alloc] initWithValue:
                [ADJResultNN
                failWithMessage:@"Cannot create attribution state data from io data"
                key:@"installSessionTracked fail"
                value:[installSessionTrackedResult.fail foundationDictionary]]];
    }

    ADJResultNN<ADJBooleanWrapper *> *_Nonnull unavailableAttributionResult =
        [ADJBooleanWrapper instanceFromIoValue:
         [ioData.propertiesMap pairValueWithKey:kUnavailableAttributionKey]];
    if (unavailableAttributionResult.fail != nil) {
        return [[ADJCollectionAndValue alloc] initWithValue:
                [ADJResultNN
                failWithMessage:@"Cannot create attribution state data from io data"
                key:@"unavailableAttribution fail"
                value:[unavailableAttributionResult.fail foundationDictionary]]];
    }

    ADJResultNN<ADJBooleanWrapper *> *_Nonnull isAskingResult =
        [ADJBooleanWrapper instanceFromIoValue:
         [ioData.propertiesMap pairValueWithKey:kIsAskingKey]];
    if (isAskingResult.fail != nil) {
        return [[ADJCollectionAndValue alloc] initWithValue:
                [ADJResultNN
                failWithMessage:@"Cannot create attribution state data from io data"
                key:@"isAsking fail"
                value:[isAskingResult.fail foundationDictionary]]];
    }

    ADJAttributionData *_Nullable attributionData = nil;
    NSArray<ADJResultFail *> *_Nullable optionalFails = nil;

    ADJStringMap *_Nullable attributionDataMap = [ioData mapWithName:kAttributionDataMapName];
    if (attributionDataMap != nil) {
        ADJCollectionAndValue<ADJResultFail *, ADJAttributionData *> *_Nonnull
        attributionDataResultWithOptionalFails =
            [ADJAttributionData instanceFromIoDataMap:attributionDataMap];

        optionalFails = attributionDataResultWithOptionalFails.collection;
        attributionData = attributionDataResultWithOptionalFails.value;
    }

    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFails
            value:[[ADJAttributionStateData alloc]
                   initWithAttributionData:attributionData
                   installSessionTracked:installSessionTrackedResult.value.boolValue
                   unavailableAttribution:unavailableAttributionResult.value.boolValue
                   isAsking:isAskingResult.value.boolValue]];
}

- (nonnull instancetype)initWithIntialState {
    return [self initWithAttributionData:nil
                   installSessionTracked:NO
                  unavailableAttribution:NO
                                isAsking:NO];
}

- (nonnull instancetype)initWithAttributionData:(nullable ADJAttributionData *)attributionData
                          installSessionTracked:(BOOL)installSessionTracked
                         unavailableAttribution:(BOOL)unavailableAttribution
                                       isAsking:(BOOL)isAsking
{
    self = [super init];
    _attributionData = attributionData;
    _installSessionTracked = installSessionTracked;
    _unavailableAttribution = unavailableAttribution;
    _isAsking = isAsking;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull ADJAttributionStateStatus)attributionStateStatus {
    if (self.isAsking) {
        return ADJAttributionStateStatusIsAsking;
    }
    if (self.unavailableAttribution && self.installSessionTracked) {
        return ADJAttributionStateStatusUnavailable;
    }
    if (self.attributionData != nil) {
        return ADJAttributionStateStatusHasAttribution;
    }
    if (self.installSessionTracked) {
        return ADJAttributionStateStatusCanAsk;
    } else {
        return ADJAttributionStateStatusWaitingForInstallSessionTracking;
    }
}

- (BOOL)isAskingStatus {
    return [self attributionStateStatus] == ADJAttributionStateStatusIsAsking;
}
- (BOOL)unavailableStatus {
    return [self attributionStateStatus] == ADJAttributionStateStatusUnavailable;
}
- (BOOL)hasAttributionStatus {
    return [self attributionStateStatus] == ADJAttributionStateStatusHasAttribution;
}
- (BOOL)canAskStatus {
    return [self attributionStateStatus] == ADJAttributionStateStatusCanAsk;
}
- (BOOL)waitingForInstallSessionTrackingStatus {
    return [self attributionStateStatus] == ADJAttributionStateStatusWaitingForInstallSessionTracking;
}

- (BOOL)hasAcceptedResponseFromBackend {
    return self.unavailableAttribution || self.attributionData != nil;
}

- (nonnull ADJAttributionStateData *)withNewIsAsking:(BOOL)newIsAsking {
    return [[ADJAttributionStateData alloc] initWithAttributionData:self.attributionData
                                              installSessionTracked:self.installSessionTracked
                                             unavailableAttribution:self.unavailableAttribution
                                                           isAsking:newIsAsking];
}
- (nonnull ADJAttributionStateData *)withInstallSessionTracked {
    return [[ADJAttributionStateData alloc] initWithAttributionData:self.attributionData
                                              installSessionTracked:YES
                                             unavailableAttribution:self.unavailableAttribution
                                                           isAsking:self.isAsking];
}
- (nonnull ADJAttributionStateData *)withUnavailableAttribution {
    return [[ADJAttributionStateData alloc] initWithAttributionData:nil
                                              installSessionTracked:self.installSessionTracked
                                             unavailableAttribution:YES
                                                           isAsking:self.isAsking];
}

- (nonnull ADJAttributionStateData *)withAvailableAttribution:
    (nonnull ADJAttributionData *)attributionData
{
    return [[ADJAttributionStateData alloc] initWithAttributionData:attributionData
                                              installSessionTracked:self.installSessionTracked
                                             unavailableAttribution:NO
                                                           isAsking:self.isAsking];
}

#pragma mark - ADJIoDataSerializable
#define injectBoolean(var, paramKey)                                                    \
     [ADJUtilMap injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder          \
                                        key:paramKey                                    \
                         ioValueSerializable:[ADJBooleanWrapper instanceFromBool:var]]  \

- (nonnull ADJIoData *)toIoData {
    ADJIoDataBuilder *_Nonnull ioDataBuilder =
    [[ADJIoDataBuilder alloc]
     initWithMetadataTypeValue:ADJAttributionStateDataMetadataTypeValue];

    injectBoolean(self.installSessionTracked, kInstallSessionTrackedKey);
    injectBoolean(self.unavailableAttribution, kUnavailableAttributionKey);
    injectBoolean(self.isAsking, kIsAskingKey);

    if (self.attributionData != nil) {
        ADJStringMapBuilder *_Nonnull stringMapBuilder =
            [ioDataBuilder addAndReturnNewMapBuilderByName:kAttributionDataMapName];

        [self.attributionData injectIntoIoDataMapBuilder:stringMapBuilder];
    }

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJAttributionStateDataMetadataTypeValue,
            kInstallSessionTrackedKey, @(self.installSessionTracked),
            kUnavailableAttributionKey, @(self.unavailableAttribution),
            kIsAskingKey, @(self.isAsking),
            kAttributionDataMapName, self.attributionData,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + @(self.installSessionTracked).hash;
    hashCode = ADJHashCodeMultiplier * hashCode + @(self.unavailableAttribution).hash;
    hashCode = ADJHashCodeMultiplier * hashCode + @(self.isAsking).hash;
    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.attributionData];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJAttributionStateData class]]) {
        return NO;
    }

    ADJAttributionStateData *other = (ADJAttributionStateData *)object;
    return self.installSessionTracked == other.installSessionTracked
        && self.unavailableAttribution == other.unavailableAttribution
        && self.isAsking == other.isAsking
        && [ADJUtilObj objectEquals:self.attributionData other:other.attributionData];
}

@end
