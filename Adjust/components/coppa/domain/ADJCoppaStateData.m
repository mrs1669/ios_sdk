//
//  ADJCoppaStateData.m
//  Adjust
//
//  Created by Pedro Silva on 28.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJCoppaStateData.h"

#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJBooleanWrapper *isCoppaEnabled;
 */

#pragma mark - Public constants
NSString *const ADJCoppaStateDataMetadataTypeValue = @"CoppaStateData";

#pragma mark - Private constants
static NSString *const kIsCoppaEnabledKey = @"isCoppaEnabled";

@implementation ADJCoppaStateData
#pragma mark Instantiation
+ (nonnull ADJResult<ADJCoppaStateData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData {
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
    [ioData isExpectedMetadataTypeValue:ADJCoppaStateDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [ADJResult failWithMessage:@"Cannot create coppa state data from io data"
                                      key:@"unexpected metadata type value fail"
                                otherFail:unexpectedMetadataTypeValueFail];
    }

    ADJResult<ADJBooleanWrapper *> *_Nonnull isCoppaEnabledResult =
    [ADJBooleanWrapper instanceFromIoValue:
     [ioData.propertiesMap pairValueWithKey:kIsCoppaEnabledKey]];

    if (isCoppaEnabledResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot create coppa state data from io data without isCoppaEnabledResult"
                                      key:@"boolean parse fail"
                                otherFail:isCoppaEnabledResult.fail];
    }

    return [ADJResult okWithValue:
            [[ADJCoppaStateData alloc] initWithIsCoppaEnabled:isCoppaEnabledResult.value]];
}

- (nonnull instancetype)initWithInitialState {
    return [[ADJCoppaStateData alloc]
            initWithIsCoppaEnabled:[ADJBooleanWrapper instanceFromBool:NO]];
}

- (nonnull instancetype)initWithIsCoppaEnabled:(nonnull ADJBooleanWrapper *)isCoppaEnabled {
    self = [super init];

    _isCoppaEnabled = isCoppaEnabled;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
#pragma mark - ADJIoDataSerializable
- (nonnull ADJIoData *)toIoData {
    ADJIoDataBuilder *_Nonnull ioDataBuilder =
        [[ADJIoDataBuilder alloc]
         initWithMetadataTypeValue:ADJCoppaStateDataMetadataTypeValue];

    [ADJUtilMap
     injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
     key:kIsCoppaEnabledKey
     ioValueSerializable:self.isCoppaEnabled];

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJCoppaStateDataMetadataTypeValue,
            kIsCoppaEnabledKey, self.isCoppaEnabled,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.isCoppaEnabled];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJCoppaStateData class]]) {
        return NO;
    }

    ADJCoppaStateData *other = (ADJCoppaStateData *)object;
    return [ADJUtilObj objectEquals:self.isCoppaEnabled other:other.isCoppaEnabled];
}

@end
