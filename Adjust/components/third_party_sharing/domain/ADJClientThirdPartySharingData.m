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
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *stringGranularOptionsByName;
 */

#pragma mark - Public constants
NSString *const ADJClientThirdPartySharingDataMetadataTypeValue = @"ClientThirdPartySharingData";

#pragma mark - Private constants
static NSString *const kEnabledOrElseDisabledSharingKey = @"enabledOrElseDisabledSharing";
static NSString *const kStringGranularOptionsByNameKey = @"stringGranularOptionsByName";
static NSString *const kStringPartnerSharingSettingsByNameKey = @"stringPartnerSharingSettingsByName";


@implementation ADJClientThirdPartySharingData
#pragma mark Instantiation
+ (nullable instancetype)
    instanceFromClientWithAdjustThirdPartySharing:
        (nullable ADJAdjustThirdPartySharing *)adjustThirdPartySharing
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

    ADJNonEmptyString *_Nullable stringGranularOptionsByName =
        [self
         stringWithGranularOptionsByNameArray:adjustThirdPartySharing.granularOptionsByNameArray
         logger:logger];

    ADJNonEmptyString *_Nullable stringPartnerSharingSettingsByName =
        [self
         stringWithPartnerSharingSettingsByNameArray:
             adjustThirdPartySharing.partnerSharingSettingsByNameArray
         logger:logger];

    return [[self alloc] initWithEnabledOrElseDisabledSharing:enabledOrElseDisabledSharing
                                  stringGranularOptionsByName:stringGranularOptionsByName
                           stringPartnerSharingSettingsByName:stringPartnerSharingSettingsByName];
}
+ (nullable ADJNonEmptyString *)
    stringWithGranularOptionsByNameArray:(nullable NSArray<NSString *> *)granularOptionsByNameArray
    logger:(nonnull ADJLogger *)logger
{
    ADJOptionalFailsNN<ADJResult<NSDictionary<NSString *, ADJStringKeyDict> *> *> *_Nonnull
    granularOptionsByNameOptFails =
        [ADJUtilConv
         convertToStringMapCollectionByNameBuilderWithNameKeyValueArray:granularOptionsByNameArray];

    for (ADJResultFail *_Nonnull optionalFail in granularOptionsByNameOptFails.optionalFails) {
        [logger noticeClient:@"Issue while adding granular option by name to third party sharing"
                  resultFail:optionalFail];
    }

    ADJResult<NSDictionary<NSString *, ADJStringKeyDict> *> *_Nonnull
    granularOptionsByNameResult = granularOptionsByNameOptFails.value;

    if (granularOptionsByNameResult.value == nil) {
        if (granularOptionsByNameResult.failNonNilInput != nil) {
            [logger noticeClient:
             @"Could not parse granular options from map collection in third party sharing"
                      resultFail:granularOptionsByNameResult.fail];
        }
        return nil;
    }

    if ([granularOptionsByNameResult.value count] == 0) {
        [logger noticeClient:
         @"Could not use any valid granular option by name to third party sharing"];
        return nil;
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull granularOptionsByNameStringResult =
        [ADJUtilF jsonFoundationValueFormat:granularOptionsByNameResult.value];
    if (granularOptionsByNameStringResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot use invalid granular options in third party sharing"
                  resultFail:granularOptionsByNameStringResult.fail];
    }

    return granularOptionsByNameStringResult.value;
}
+ (nullable ADJNonEmptyString *)
    stringWithPartnerSharingSettingsByNameArray:
        (nullable NSArray *)partnerSharingSettingsByNameArray
    logger:(nonnull ADJLogger *)logger
{
    ADJOptionalFailsNN<ADJResult<NSDictionary<NSString *, ADJStringKeyDict> *> *> *_Nonnull
    partnerSharingSettingsByNameOptFails =
        [ADJUtilConv
         convertToNumberBooleanMapCollectionByNameBuilderWithNameKeyValueArray:
             partnerSharingSettingsByNameArray];

    for (ADJResultFail *_Nonnull optionalFail in
         partnerSharingSettingsByNameOptFails.optionalFails)
    {
        [logger noticeClient:@"Issue while partner sharing setting by name to third party sharing"
                  resultFail:optionalFail];
    }

    ADJResult<NSDictionary<NSString *, ADJStringKeyDict> *> *_Nonnull
    partnerSharingSettingsByNameResult = partnerSharingSettingsByNameOptFails.value;

    if (partnerSharingSettingsByNameResult.value == nil) {
        if (partnerSharingSettingsByNameResult.failNonNilInput != nil) {
            [logger noticeClient:
             @"Could not parse partner sharing setting from map collection in third party sharing"
                      resultFail:partnerSharingSettingsByNameResult.fail];
        }
        return nil;
    }

    if ([partnerSharingSettingsByNameResult.value count] == 0) {
        [logger noticeClient:
         @"Could not use any valid partner sharing setting by name to third party sharing"];
        return nil;
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull partnerSharingSettingsStringResult =
        [ADJUtilF jsonFoundationValueFormat:partnerSharingSettingsByNameResult.value];
    if (partnerSharingSettingsStringResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot use invalid partner sharing setting in third party sharing"
                  resultFail:partnerSharingSettingsStringResult.fail];
    }

    return partnerSharingSettingsStringResult.value;
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

    ADJNonEmptyString *_Nullable stringGranularOptionsByName =
        [propertiesMap pairValueWithKey:kStringGranularOptionsByNameKey];

    ADJNonEmptyString *_Nullable stringPartnerSharingSettingsByName =
        [propertiesMap pairValueWithKey:kStringPartnerSharingSettingsByNameKey];

    return [[ADJClientThirdPartySharingData alloc]
            initWithEnabledOrElseDisabledSharing:enabledOrElseDisabledSharingResult.value
            stringGranularOptionsByName:stringGranularOptionsByName
            stringPartnerSharingSettingsByName:stringPartnerSharingSettingsByName];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithEnabledOrElseDisabledSharing:(nullable ADJBooleanWrapper *)enabledOrElseDisabledSharing
                                 stringGranularOptionsByName:(nullable ADJNonEmptyString *)stringGranularOptionsByName
                                 stringPartnerSharingSettingsByName:(nullable ADJNonEmptyString *)stringPartnerSharingSettingsByName {
    self = [super init];

    _enabledOrElseDisabledSharing = enabledOrElseDisabledSharing;
    _stringGranularOptionsByName = stringGranularOptionsByName;
    _stringPartnerSharingSettingsByName = stringPartnerSharingSettingsByName;

    return self;
}

#pragma mark Public API
#pragma mark - ADJClientActionIoDataInjectable
- (void)injectIntoClientActionIoDataBuilder:(nonnull ADJIoDataBuilder *)clientActionIoDataBuilder{
    ADJStringMapBuilder *_Nonnull propertiesMapBuilder = clientActionIoDataBuilder.propertiesMapBuilder;

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kEnabledOrElseDisabledSharingKey
                       ioValueSerializable:self.enabledOrElseDisabledSharing];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kStringGranularOptionsByNameKey
                       ioValueSerializable:self.stringGranularOptionsByName];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kStringPartnerSharingSettingsByNameKey
                       ioValueSerializable:self.stringPartnerSharingSettingsByName];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientThirdPartySharingDataMetadataTypeValue,
            kEnabledOrElseDisabledSharingKey, self.enabledOrElseDisabledSharing,
            kStringGranularOptionsByNameKey, self.stringGranularOptionsByName,
            kStringPartnerSharingSettingsByNameKey, self.stringPartnerSharingSettingsByName,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.enabledOrElseDisabledSharing];
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.stringGranularOptionsByName];
    hashCode = ADJHashCodeMultiplier * hashCode +
    [ADJUtilObj objecNullableHash:self.stringPartnerSharingSettingsByName];

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
    && [ADJUtilObj objectEquals:self.stringGranularOptionsByName
                          other:other.stringGranularOptionsByName]
    && [ADJUtilObj objectEquals:self.stringPartnerSharingSettingsByName
                          other:other.stringPartnerSharingSettingsByName];
}

@end
