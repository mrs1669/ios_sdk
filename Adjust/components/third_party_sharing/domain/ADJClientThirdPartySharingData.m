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

    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *_Nullable
     granularOptionsByName =
        [ADJUtilConv
         convertToStringMapCollectionByNameBuilderWithNameKeyValueArray:
             adjustThirdPartySharing.granularOptionsByNameArray
         sourceDescription:@"third party sharing granular options array parsing"
         logger:logger];
    ADJNonEmptyString *_Nullable stringGranularOptionsByName =
        [ADJNonEmptyString
         instanceFromOptionalString:[ADJUtilF jsonFoundationValueFormat:granularOptionsByName]
         sourceDescription:@"third party sharing granular options string parsing"
         logger:logger];

    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *_Nullable
     partnerSharingSettingsByName =
        [ADJUtilConv
         convertToNumberBooleanMapCollectionByNameBuilderWithNameKeyValueArray:
             adjustThirdPartySharing.partnerSharingSettingsByNameArray
         sourceDescription:@"third party sharing partner sharing settings array parsing"
         logger:logger];
    ADJNonEmptyString *_Nullable stringPartnerSharingSettingsByName =
        [ADJNonEmptyString
         instanceFromOptionalString:
             [ADJUtilF jsonFoundationValueFormat:partnerSharingSettingsByName]
         sourceDescription:@"third party sharing partner sharing settings string parsing"
         logger:logger];

    return [[self alloc] initWithEnabledOrElseDisabledSharing:enabledOrElseDisabledSharing
                                  stringGranularOptionsByName:stringGranularOptionsByName
                           stringPartnerSharingSettingsByName:stringPartnerSharingSettingsByName];
}

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger {
    ADJStringMap *_Nonnull propertiesMap = clientActionInjectedIoData.propertiesMap;

    ADJNonEmptyString *_Nullable enabledOrElseDisabledSharingIoValue =
    [propertiesMap pairValueWithKey:kEnabledOrElseDisabledSharingKey];

    ADJBooleanWrapper *_Nullable enabledOrElseDisabledSharing =
    [ADJBooleanWrapper instanceFromIoValue:enabledOrElseDisabledSharingIoValue
                                    logger:logger];

    ADJNonEmptyString *_Nullable stringGranularOptionsByName =
    [propertiesMap pairValueWithKey:kStringGranularOptionsByNameKey];

    ADJNonEmptyString *_Nullable stringPartnerSharingSettingsByName =
    [propertiesMap pairValueWithKey:kStringPartnerSharingSettingsByNameKey];

    return [[self alloc] initWithEnabledOrElseDisabledSharing:enabledOrElseDisabledSharing
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