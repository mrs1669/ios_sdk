//
//  ADJClientMeasurementConsentData.m
//  Adjust
//
//  Created by Genady Buchatsky on 10.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJClientMeasurementConsentData.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJUtilMap.h"

#pragma mark - Public constants
NSString *const ADJClientMeasurementConsentDataMetadataTypeValue = @"ClientMeasurementConsentData";

#pragma mark - Private constants
static NSString *const kWasMeasurementConsentActivatedKey = @"wasMeasurementConsentActivated";


@implementation ADJClientMeasurementConsentData

// instantiation
+ (nullable instancetype)instanceWithActivateConsent {
    return [[ADJClientMeasurementConsentData alloc]
            initWithActivateConsent:[ADJBooleanWrapper instanceFromBool:YES]];
}

+ (nullable instancetype)instanceWithInactivateConsent {
    return [[ADJClientMeasurementConsentData alloc]
            initWithActivateConsent:[ADJBooleanWrapper instanceFromBool:NO]];
}

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger {

    ADJStringMap *_Nonnull propertiesMap = clientActionInjectedIoData.propertiesMap;
    ADJNonEmptyString *_Nullable ioValue = [propertiesMap
                                            pairValueWithKey:kWasMeasurementConsentActivatedKey];
    ADJBooleanWrapper *_Nullable wasMeasurementConsentActivated =
        [ADJBooleanWrapper instanceFromIoValue:ioValue logger:logger];

    if (wasMeasurementConsentActivated == nil) {
        [logger debugDev:@"Could not recreate ClientMeasurementConsentData from ClientAction. "
               issueType:ADJIssueStorageIo];
        return nil;
    }

    return [[ADJClientMeasurementConsentData alloc]
            initWithActivateConsent:wasMeasurementConsentActivated];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithActivateConsent:(ADJBooleanWrapper *)activateConsent {
    self = [super init];
    _measurementConsentWasActivated = activateConsent;
    return self;
}

- (void)injectIntoClientActionIoDataBuilder:(nonnull ADJIoDataBuilder *)clientActionIoDataBuilder {

    ADJStringMapBuilder *_Nonnull propertiesMapBuilder =
    clientActionIoDataBuilder.propertiesMapBuilder;

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kWasMeasurementConsentActivatedKey
                       ioValueSerializable:self.measurementConsentWasActivated];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientMeasurementConsentDataMetadataTypeValue,
            kWasMeasurementConsentActivatedKey, self.measurementConsentWasActivated,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    hashCode = ADJHashCodeMultiplier * hashCode + self.measurementConsentWasActivated.hash;
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJClientMeasurementConsentData class]]) {
        return NO;
    }

    ADJClientMeasurementConsentData *other = (ADJClientMeasurementConsentData *)object;
    return [ADJUtilObj objectEquals:self.measurementConsentWasActivated
                              other:other.measurementConsentWasActivated];
}

@end
