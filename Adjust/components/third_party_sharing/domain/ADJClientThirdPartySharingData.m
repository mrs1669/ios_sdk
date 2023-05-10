//
//  ADJClientThirdPartySharingData.m
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientThirdPartySharingData.h"

#import "ADJUtilF.h"
#import "ADJUtilConv.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJUtilMap.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJBooleanWrapper *enabledOrElseDisabledSharing;
 @property (nullable, readonly, strong, nonatomic)
     ADJNonEmptyString *granularOptionsByNameJsonString;
 @property (nullable, readonly, strong, nonatomic)
     ADJNonEmptyString *partnerSharingSettingsByNameJsonString;
 */

#pragma mark - Public constants
NSString *const ADJClientThirdPartySharingDataMetadataTypeValue = @"ClientThirdPartySharingData";

#pragma mark - Private constants
static NSString *const kEnabledOrElseDisabledSharingKey = @"enabledOrElseDisabledSharing";
static NSString *const kGranularOptionsByNameJsonStringKey = @"granularOptionsByNameJsonString";
static NSString *const kPartnerSharingSettingsByNameJsonStringKey =
    @"partnerSharingSettingsByNameJsonString";

@implementation ADJClientThirdPartySharingData
#pragma mark Instantiation
+ (nullable instancetype)
    instanceFromClientWithAdjustThirdPartySharing:
        (nullable ADJAdjustThirdPartySharing *)adjustThirdPartySharing
    granularOptionsByNameArray:(nullable NSArray *)granularOptionsByNameArray
    partnerSharingSettingsByNameArray:(nullable NSArray *)partnerSharingSettingsByNameArray
    logger:(nonnull ADJLogger *)logger
{
    if (adjustThirdPartySharing == nil) {
        [logger errorClient:
         @"Cannot create third party sharing with nil adjust third party sharing value"];
        return nil;
    }

    ADJBooleanWrapper *_Nonnull enabledOrElseDisabledSharing =
        adjustThirdPartySharing.enabledOrElseDisabledSharingNumberBool != nil
            ? [ADJBooleanWrapper instanceFromBool:
               adjustThirdPartySharing.enabledOrElseDisabledSharingNumberBool.boolValue]
            : nil;

    ADJNonEmptyString *_Nullable granularOptionsByNameJsonString =
        [self
         granularOptionsByNameJsonStringWithArray:
             granularOptionsByNameArray ?: adjustThirdPartySharing.granularOptionsByNameArray
         logger:logger];

    ADJNonEmptyString *_Nullable partnerSharingSettingsByNameJsonString =
        [self
         partnerSharingSettingsByNameJsonStringWithArray:
             partnerSharingSettingsByNameArray ?:
            adjustThirdPartySharing.partnerSharingSettingsByNameArray
         logger:logger];

    return [[ADJClientThirdPartySharingData alloc]
            initWithEnabledOrElseDisabledSharing:enabledOrElseDisabledSharing
            granularOptionsByNameJsonString:granularOptionsByNameJsonString
            partnerSharingSettingsByNameJsonString:partnerSharingSettingsByNameJsonString];
}
+ (nullable ADJNonEmptyString *)
    granularOptionsByNameJsonStringWithArray:
        (nullable NSArray *)granularOptionsByNameArray
    logger:(nonnull ADJLogger *)logger
{
    ADJOptionalFailsNN<ADJResult<ADJNonEmptyString *> *> *_Nonnull
    granularOptionsByNameJsonStringOptFails =
        [ADJUtilConv jsonStringFromNameKeyStringValueArray:granularOptionsByNameArray];

    for (ADJResultFail *_Nonnull optionalFail in
         granularOptionsByNameJsonStringOptFails.optionalFails)
    {
        [logger noticeClient:@"Issue while adding granular option by name to third party sharing"
                  resultFail:optionalFail];
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull
        granularOptionsByNameJsonStringResult = granularOptionsByNameJsonStringOptFails.value;

    if (granularOptionsByNameJsonStringResult.failNonNilInput != nil) {
        [logger noticeClient:
         @"Could not parse granular options from map collection in third party sharing"
                  resultFail:granularOptionsByNameJsonStringResult.fail];
    }

    return granularOptionsByNameJsonStringResult.value;
}
+ (nullable ADJNonEmptyString *)
    partnerSharingSettingsByNameJsonStringWithArray:
        (nullable NSArray *)partnerSharingSettingsByNameArray
    logger:(nonnull ADJLogger *)logger
{
    ADJOptionalFailsNN<ADJResult<ADJNonEmptyString *> *> *_Nonnull
    partnerSharingSettingsByNameJsonStringOptFails =
        [ADJUtilConv jsonStringFromNameKeyBooleanValueArray:partnerSharingSettingsByNameArray];

    for (ADJResultFail *_Nonnull optionalFail in
         partnerSharingSettingsByNameJsonStringOptFails.optionalFails)
    {
        [logger noticeClient:@"Issue while partner sharing setting by name to third party sharing"
                  resultFail:optionalFail];
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull
        partnerSharingSettingsByNameJsonStringResult =
            partnerSharingSettingsByNameJsonStringOptFails.value;

    if (partnerSharingSettingsByNameJsonStringResult.failNonNilInput != nil) {
        [logger noticeClient:
         @"Could not parse partner sharing setting from map collection in third party sharing"
                  resultFail:partnerSharingSettingsByNameJsonStringResult.fail];
    }

    return partnerSharingSettingsByNameJsonStringResult.value;
}

+ (nullable instancetype)
    instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
    logger:(nonnull ADJLogger *)logger
{
    ADJStringMap *_Nonnull propertiesMap = clientActionInjectedIoData.propertiesMap;

    ADJNonEmptyString *_Nullable enabledOrElseDisabledSharingIoValue =
        [propertiesMap pairValueWithKey:kEnabledOrElseDisabledSharingKey];

    ADJResult<ADJBooleanWrapper *> *_Nonnull enabledOrElseDisabledSharingResult =
        [ADJBooleanWrapper instanceFromIoValue:enabledOrElseDisabledSharingIoValue];
    if (enabledOrElseDisabledSharingResult.fail != nil) {
        [logger debugDev:@"Cannot use invalid enabledOrElseDisabledSharing value"
         " from client action injected io data"
              resultFail:enabledOrElseDisabledSharingResult.fail
               issueType:ADJIssueStorageIo];
    }

    ADJNonEmptyString *_Nullable granularOptionsByNameJsonString =
        [propertiesMap pairValueWithKey:kGranularOptionsByNameJsonStringKey];

    ADJNonEmptyString *_Nullable partnerSharingSettingsByNameJsonString =
        [propertiesMap pairValueWithKey:kPartnerSharingSettingsByNameJsonStringKey];

    return [[ADJClientThirdPartySharingData alloc]
            initWithEnabledOrElseDisabledSharing:enabledOrElseDisabledSharingResult.value
            granularOptionsByNameJsonString:granularOptionsByNameJsonString
            partnerSharingSettingsByNameJsonString:partnerSharingSettingsByNameJsonString];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)
    initWithEnabledOrElseDisabledSharing:(nullable ADJBooleanWrapper *)enabledOrElseDisabledSharing
    granularOptionsByNameJsonString:(nullable ADJNonEmptyString *)granularOptionsByNameJsonString
    partnerSharingSettingsByNameJsonString:
        (nullable ADJNonEmptyString *)partnerSharingSettingsByNameJsonString
{
    self = [super init];

    _enabledOrElseDisabledSharing = enabledOrElseDisabledSharing;
    _granularOptionsByNameJsonString = granularOptionsByNameJsonString;
    _partnerSharingSettingsByNameJsonString = partnerSharingSettingsByNameJsonString;

    return self;
}

#pragma mark Public API
#pragma mark - ADJClientActionIoDataInjectable
- (void)injectIntoClientActionIoDataBuilder:(nonnull ADJIoDataBuilder *)clientActionIoDataBuilder {
    ADJStringMapBuilder *_Nonnull propertiesMapBuilder =
        clientActionIoDataBuilder.propertiesMapBuilder;

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kEnabledOrElseDisabledSharingKey
                       ioValueSerializable:self.enabledOrElseDisabledSharing];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kGranularOptionsByNameJsonStringKey
                       ioValueSerializable:self.granularOptionsByNameJsonString];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kPartnerSharingSettingsByNameJsonStringKey
                       ioValueSerializable:self.partnerSharingSettingsByNameJsonString];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientThirdPartySharingDataMetadataTypeValue,
            kEnabledOrElseDisabledSharingKey, self.enabledOrElseDisabledSharing,
            kGranularOptionsByNameJsonStringKey, self.granularOptionsByNameJsonString,
            kPartnerSharingSettingsByNameJsonStringKey,
                self.partnerSharingSettingsByNameJsonString,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.enabledOrElseDisabledSharing];
    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.granularOptionsByNameJsonString];
    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.partnerSharingSettingsByNameJsonString];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJClientThirdPartySharingData class]]) {
        return NO;
    }

    ADJClientThirdPartySharingData *other = (ADJClientThirdPartySharingData *)object;
    return [ADJUtilObj objectEquals:self.enabledOrElseDisabledSharing
                              other:other.enabledOrElseDisabledSharing]
    && [ADJUtilObj objectEquals:self.granularOptionsByNameJsonString
                          other:other.granularOptionsByNameJsonString]
    && [ADJUtilObj objectEquals:self.partnerSharingSettingsByNameJsonString
                          other:other.partnerSharingSettingsByNameJsonString];
}

@end
