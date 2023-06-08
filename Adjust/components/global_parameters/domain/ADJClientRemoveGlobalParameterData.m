//
//  ADJClientRemoveGlobalParameterData.m
//  Adjust
//
//  Created by Aditi Agrawal on 25/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientRemoveGlobalParameterData.h"

#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJClientActionData.h"
#import "ADJUtilMap.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *keyToRemove;
 */

#pragma mark - Public constants
NSString *const ADJClientRemoveGlobalParameterDataMetadataTypeValue =
    @"ClientRemoveGlobalParameterData";

#pragma mark - Private constants
static NSString *const kKeyToRemoveKey = @"keyToRemove";

@implementation ADJClientRemoveGlobalParameterData
#pragma mark Instantiation
+ (nullable instancetype)
    instanceFromClientWithAdjustConfigWithKeyToRemove:(nullable NSString *)keyToRemove
    globalParameterType:(nonnull NSString *)globalParameterType
    logger:(nonnull ADJLogger *)logger
{
    ADJResult<ADJNonEmptyString *> *_Nonnull keyToRemoveResult =
        [ADJNonEmptyString instanceFromString:keyToRemove];
    if (keyToRemoveResult.fail != nil) {
        [logger errorClient:@"Invalid key to remove parameter"
                        key:@"gloabal parameter type"
                      value:globalParameterType
                 resultFail:keyToRemoveResult.fail];
        return nil;
    }

    return [[self alloc] initWithKeyToRemove:keyToRemoveResult.value];
}

+ (nullable instancetype)
    instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
    globalParameterType:(nonnull NSString *)globalParameterType
    logger:(nonnull ADJLogger *)logger
{
    ADJNonEmptyString *_Nullable clientActionTypeValue =
        [clientActionInjectedIoData.metadataMap pairValueWithKey:ADJClientActionTypeKey];
    if (clientActionTypeValue == nil) {
        [logger debugDev:@"Cannot create ClientRemoveGlobalParameterData"
            " from client action io data without client action type value"
               issueType:ADJIssueStorageIo];
        return nil;
    }

    if (! [ADJClientRemoveGlobalParameterDataMetadataTypeValue
           isEqualToString:clientActionTypeValue.stringValue])
    {
        [logger debugDev:
         @"Cannot create ClientRemoveGlobalParameterData from client action io data"
         " with different client action type"
           expectedValue:ADJClientRemoveGlobalParameterDataMetadataTypeValue
               actualValue:clientActionTypeValue.stringValue
                 issueType:ADJIssueStorageIo];
        return nil;
    }

    ADJNonEmptyString *_Nullable keyToRemove =
        [clientActionInjectedIoData.propertiesMap pairValueWithKey:kKeyToRemoveKey];

    return [self
                instanceFromClientWithAdjustConfigWithKeyToRemove:
                    keyToRemove != nil ? keyToRemove.stringValue : nil
                globalParameterType:globalParameterType
                logger:logger];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithKeyToRemove:(nonnull ADJNonEmptyString *)keyToRemove {
    self = [super init];

    _keyToRemove = keyToRemove;

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
                                constValue:ADJClientRemoveGlobalParameterDataMetadataTypeValue];

    ADJStringMapBuilder *_Nonnull propertiesMapBuilder = clientActionIoDataBuilder.propertiesMapBuilder;

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kKeyToRemoveKey
                       ioValueSerializable:self.keyToRemove];
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientRemoveGlobalParameterDataMetadataTypeValue,
            kKeyToRemoveKey, self.keyToRemove,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + [self.keyToRemove hash];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJClientRemoveGlobalParameterData class]]) {
        return NO;
    }

    ADJClientRemoveGlobalParameterData *other = (ADJClientRemoveGlobalParameterData *)object;
    return [ADJUtilObj objectEquals:self.keyToRemove other:other.keyToRemove];
}

@end


