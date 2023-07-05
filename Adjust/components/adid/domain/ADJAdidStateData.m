//
//  ADJAdidStateData.m
//  Adjust
//
//  Created by Pedro Silva on 13.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJAdidStateData.h"

#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adid;
 */

#pragma mark - Public constants
NSString *const ADJAdidStateDataMetadataTypeValue = @"AdidStateData";

#pragma mark - Private constants
static NSString *const kAdidKey = @"adid";

@implementation ADJAdidStateData
#pragma mark Instantiation
+ (nonnull ADJResult<ADJAdidStateData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData {
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
        [ioData isExpectedMetadataTypeValue:ADJAdidStateDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [ADJResult failWithMessage:@"Cannot create adid state data from io data"
                                      key:@"unexpected metadata type value fail"
                                otherFail:unexpectedMetadataTypeValueFail];
    }

    ADJNonEmptyString *_Nullable adid = [ioData.propertiesMap pairValueWithKey:kAdidKey];

    return [ADJResult okWithValue:[[ADJAdidStateData alloc] initWithAdid:adid]];
}

- (nonnull instancetype)initWithInitialState {
    return [self initWithAdid:nil];
}

- (nonnull instancetype)initWithAdid:(nullable ADJNonEmptyString *)adid {
    self = [super init];

    _adid = adid;

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
         initWithMetadataTypeValue:ADJAdidStateDataMetadataTypeValue];

    [ADJUtilMap
     injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
     key:kAdidKey
     ioValueSerializable:self.adid];

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJAdidStateDataMetadataTypeValue,
            kAdidKey, self.adid,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.adid];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJAdidStateData class]]) {
        return NO;
    }

    ADJAdidStateData *other = (ADJAdidStateData *)object;
    return [ADJUtilObj objectEquals:self.adid other:other.adid];
}

@end
