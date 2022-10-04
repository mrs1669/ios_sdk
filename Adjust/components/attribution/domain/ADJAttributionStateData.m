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
NSString *const ADJAttributionStateDataMetadataTypeValue = @"AttributionStateData";

NSString *const ADJAttributionStateStatusWaitingForSessionResponse = @"WaitingForSessionResponse";
NSString *const ADJAttributionStateStatusReceivedSessionResponse = @"ReceivedSessionResponse";
NSString *const ADJAttributionStateStatusAskingFromSdk = @"AskingFromSdk";
NSString *const ADJAttributionStateStatusAskingFromBackend = @"AskingFromBackend";
NSString *const ADJAttributionStateStatusAskingFromBackendAndSdk = @"AskingFromBackendAndSdk";
NSString *const ADJAttributionStateStatusHasAttribution = @"HasAttribution";
NSString *const ADJAttributionStateStatusUnavailable = @"Unavailable";

#pragma mark - Public properties
/* .h
 @property (readonly, assign, nonatomic) BOOL receivedSessionResponse;
 @property (readonly, assign, nonatomic) BOOL unavailableAttribution;
 @property (readonly, assign, nonatomic) BOOL askingFromSdk;
 @property (readonly, assign, nonatomic) BOOL askingFromBackend;
 @property (nullable, readonly, strong, nonatomic) ADJAttributionData *attributionData;
 */

#pragma mark - Private constants
static NSString *const kReceivedSessionResponseKey = @"receivedSessionResponse";
static NSString *const kUnavailableAttributionKey = @"unavailableAttribution";
static NSString *const kAskingFromSdkKey = @"askingFromSdk";
static NSString *const kAskingFromBackendKey = @"askingFromBackend";
static NSString *const kAttributionDataMapName = @"2_ATTRIBUTION_MAP";

@implementation ADJAttributionStateData
#pragma mark Instantiation
#define extractBoolean(varName, paramKey)                                                   \
ADJBooleanWrapper *_Nullable varName =                                                 \
[ADJBooleanWrapper                                                                 \
instanceFromIoValue:                                                            \
[ioData.propertiesMap pairValueWithKey:paramKey]                            \
logger:logger];                                                                 \
if (varName == nil) {                                                                   \
[logger error:@"Cannot create instance from Io data without valid %@", paramKey];   \
return nil;                                                                         \
}                                                                                       \

+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger {
    if (! [ioData
           isExpectedMetadataTypeValue:ADJAttributionStateDataMetadataTypeValue
           logger:logger])
    {
        return nil;
    }

    extractBoolean(receivedSessionResponse, kReceivedSessionResponseKey)
    extractBoolean(unavailableAttribution, kUnavailableAttributionKey)
    extractBoolean(askingFromSdk, kAskingFromSdkKey)
    extractBoolean(askingFromBackend, kAskingFromBackendKey)

    ADJAttributionData *_Nullable attributionData = nil;

    ADJStringMap *_Nullable attributionDataMap = [ioData mapWithName:kAttributionDataMapName];
    if (attributionDataMap != nil) {
        attributionData = [ADJAttributionData instanceFromIoDataMap:attributionDataMap
                                                             logger:logger];
    }

    return [[self alloc] initWithAttributionData:attributionData
                         receivedSessionResponse:receivedSessionResponse.boolValue
                          unavailableAttribution:unavailableAttribution.boolValue
                                   askingFromSdk:askingFromSdk.boolValue
                               askingFromBackend:askingFromBackend.boolValue];
}

- (nonnull instancetype)initWithIntialState {
    return [self initWithAttributionData:nil
                 receivedSessionResponse:NO
                  unavailableAttribution:NO
                           askingFromSdk:NO
                       askingFromBackend:NO];
}

- (nonnull instancetype)initWithAttributionData:(nullable ADJAttributionData *)attributionData
                        receivedSessionResponse:(BOOL)receivedSessionResponse
                         unavailableAttribution:(BOOL)unavailableAttribution
                                  askingFromSdk:(BOOL)askingFromSdk
                              askingFromBackend:(BOOL)askingFromBackend {
    self = [super init];

    _attributionData = attributionData;
    _receivedSessionResponse = receivedSessionResponse;
    _unavailableAttribution = unavailableAttribution;
    _askingFromSdk = askingFromSdk;
    _askingFromBackend = askingFromBackend;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull NSString *)attributionStateStatus {
    if (self.askingFromSdk && self.askingFromBackend) {
        return ADJAttributionStateStatusAskingFromBackendAndSdk;
    }
    if (self.askingFromSdk) {
        return ADJAttributionStateStatusAskingFromSdk;
    }
    if (self.askingFromBackend) {
        return ADJAttributionStateStatusAskingFromBackend;
    }
    if (self.unavailableAttribution && self.receivedSessionResponse) {
        return ADJAttributionStateStatusUnavailable;
    }
    if (self.attributionData != nil) {
        return ADJAttributionStateStatusHasAttribution;
    }
    if (self.receivedSessionResponse) {
        return ADJAttributionStateStatusReceivedSessionResponse;
    } else {
        return ADJAttributionStateStatusWaitingForSessionResponse;
    }
}

- (BOOL)askingFromBackendAndSdkStatus {
    return [self attributionStateStatus] == ADJAttributionStateStatusAskingFromBackendAndSdk;
}

- (BOOL)askingFromSdkStatus {
    return [self attributionStateStatus] == ADJAttributionStateStatusAskingFromSdk;
}

- (BOOL)askingFromBackendStatus {
    return [self attributionStateStatus] == ADJAttributionStateStatusAskingFromBackend;
}

- (BOOL)unavailableStatus {
    return [self attributionStateStatus] == ADJAttributionStateStatusUnavailable;
}

- (BOOL)hasAttributionStatus {
    return [self attributionStateStatus] == ADJAttributionStateStatusHasAttribution;
}

- (BOOL)receivedSessionResponseStatus {
    return [self attributionStateStatus] == ADJAttributionStateStatusReceivedSessionResponse;
}

- (BOOL)waitingForSessionResponseStatus {
    return [self attributionStateStatus] == ADJAttributionStateStatusWaitingForSessionResponse;
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

    injectBoolean(self.receivedSessionResponse, kReceivedSessionResponseKey);
    injectBoolean(self.unavailableAttribution, kUnavailableAttributionKey);
    injectBoolean(self.askingFromSdk, kAskingFromSdkKey);
    injectBoolean(self.askingFromBackend, kAskingFromBackendKey);

    if (self.attributionData != nil) {
        ADJStringMapBuilder *_Nonnull stringMapBuilder =
        [ioDataBuilder addAndReturnNewMapBuilderByName:
         kAttributionDataMapName];
        [self.attributionData injectIntoIoDataMapBuilder:stringMapBuilder];
    }

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJAttributionStateDataMetadataTypeValue,
            kReceivedSessionResponseKey, @(self.receivedSessionResponse),
            kUnavailableAttributionKey, @(self.unavailableAttribution),
            kAskingFromSdkKey, @(self.askingFromSdk),
            kAskingFromBackendKey, @(self.askingFromBackend),
            kAttributionDataMapName, self.attributionData,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + @(self.receivedSessionResponse).hash;
    hashCode = ADJHashCodeMultiplier * hashCode + @(self.unavailableAttribution).hash;
    hashCode = ADJHashCodeMultiplier * hashCode + @(self.askingFromSdk).hash;
    hashCode = ADJHashCodeMultiplier * hashCode + @(self.askingFromBackend).hash;
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
    return self.receivedSessionResponse == other.receivedSessionResponse
    && self.unavailableAttribution == other.unavailableAttribution
    && self.askingFromSdk == other.askingFromSdk
    && self.askingFromBackend == other.askingFromBackend
    && [ADJUtilObj objectEquals:self.attributionData other:other.attributionData];
}

@end


