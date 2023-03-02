//
//  ADJClientAddGlobalParameterData.m
//  Adjust
//
//  Created by Aditi Agrawal on 03/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientAddGlobalParameterData.h"

#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJClientActionData.h"
#import "ADJUtilMap.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *keyToAdd;
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *valueToAdd;
 */

#pragma mark - Public constants
NSString *const ADJClientAddGlobalParameterDataMetadataTypeValue = @"ClientAddGlobalParameterData";

#pragma mark - Private constants
static NSString *const kKeyToAddKey = @"keyToAdd";
static NSString *const kValueToAddKey = @"valueToAdd";

@implementation ADJClientAddGlobalParameterData
#pragma mark Instantiation
+ (nullable instancetype)
    instanceFromClientWithAdjustConfigWithKeyToAdd:(nullable NSString *)keyToAdd
    valueToAdd:(nullable NSString *)valueToAdd
    globalParameterType:(nonnull NSString *)globalParameterType
    logger:(nonnull ADJLogger *)logger;
{
    ADJResultNN<ADJNonEmptyString *> *_Nonnull keyToAddResult =
        [ADJNonEmptyString instanceFromString:keyToAdd];
    if (keyToAddResult.fail != nil) {
        [logger errorClient:@"Invalid add global parameter key"
                        key:@"global parameter type"
                      value:globalParameterType
                 resultFail:keyToAddResult.fail];
        return nil;
    }

    ADJResultNN<ADJNonEmptyString *> *_Nonnull valueToAddResult =
        [ADJNonEmptyString instanceFromString:valueToAdd];
    if (valueToAddResult.fail != nil) {
        [logger errorClient:@"Invalid add global parameter value"
                        key:@"global parameter type"
                      value:globalParameterType
                 resultFail:valueToAddResult.fail];
        return nil;
    }

    return [[ADJClientAddGlobalParameterData alloc]
            initWithKeyToAdd:keyToAddResult.value
            valueToAdd:valueToAddResult.value];
}

+ (nullable instancetype)
    instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
    globalParameterType:(nonnull NSString *)globalParameterType
    logger:(nonnull ADJLogger *)logger;
{
    ADJNonEmptyString *_Nullable clientActionTypeValue = [clientActionInjectedIoData.metadataMap
                                                          pairValueWithKey:ADJClientActionTypeKey];
    if (clientActionTypeValue == nil) {
        [logger debugDev:@"Cannot create ClientAddGlobalParameterData"
            " from client action io data without client action type"
            issueType:ADJIssueStorageIo];
        return nil;
    }

    if (! [ADJClientAddGlobalParameterDataMetadataTypeValue
           isEqualToString:clientActionTypeValue.stringValue])
    {
        [logger debugDev:
         @"Cannot create ClientAddGlobalParameterData from client action io data"
         " with different client action type"
         expectedValue:ADJClientAddGlobalParameterDataMetadataTypeValue
             actualValue:clientActionTypeValue.stringValue
               issueType:ADJIssueStorageIo];
         return nil;
    }

    ADJNonEmptyString *_Nullable keyToAdd =
        [clientActionInjectedIoData.propertiesMap pairValueWithKey:kKeyToAddKey];

    ADJNonEmptyString *_Nullable valueToAdd =
        [clientActionInjectedIoData.propertiesMap pairValueWithKey:kValueToAddKey];

    return [self
            instanceFromClientWithAdjustConfigWithKeyToAdd:
                (keyToAdd != nil) ? keyToAdd.stringValue : nil
            valueToAdd:(valueToAdd != nil) ? valueToAdd.stringValue : nil
            globalParameterType:globalParameterType
            logger:logger];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithKeyToAdd:(nonnull ADJNonEmptyString *)keyToAdd
                              valueToAdd:(nonnull ADJNonEmptyString *)valueToAdd {
    self = [super init];

    _keyToAdd = keyToAdd;
    _valueToAdd = valueToAdd;

    return self;
}

#pragma mark Public API
#pragma mark - ADJClientActionIoDataInjectable
- (void)injectIntoClientActionIoDataBuilder:(nonnull ADJIoDataBuilder *)clientActionIoDataBuilder {
    ADJStringMapBuilder *_Nonnull metadataMapBuilder = clientActionIoDataBuilder.metadataMapBuilder;

    // add client action type to metadata map to distinguish between add/remove/clear
    //  when handler needs to deserialize and reconstruct data
    [ADJUtilMap injectIntoIoDataBuilderMap:metadataMapBuilder
                                       key:ADJClientActionTypeKey
                                constValue:ADJClientAddGlobalParameterDataMetadataTypeValue];

    ADJStringMapBuilder *_Nonnull propertiesMapBuilder = clientActionIoDataBuilder.propertiesMapBuilder;

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kKeyToAddKey
                       ioValueSerializable:self.keyToAdd];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kValueToAddKey
                       ioValueSerializable:self.valueToAdd];
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientAddGlobalParameterDataMetadataTypeValue,
            kKeyToAddKey, self.keyToAdd,
            kValueToAddKey, self.valueToAdd,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + [self.keyToAdd hash];
    hashCode = ADJHashCodeMultiplier * hashCode + [self.valueToAdd hash];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJClientAddGlobalParameterData class]]) {
        return NO;
    }

    ADJClientAddGlobalParameterData *other = (ADJClientAddGlobalParameterData *)object;
    return [ADJUtilObj objectEquals:self.keyToAdd other:other.keyToAdd]
    && [ADJUtilObj objectEquals:self.valueToAdd other:other.valueToAdd];
}

@end


