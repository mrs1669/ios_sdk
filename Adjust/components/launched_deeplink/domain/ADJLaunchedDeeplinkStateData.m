//
//  ADJLaunchedDeeplinkStateData.m
//  Adjust
//
//  Created by Aditi Agrawal on 27/03/23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJLaunchedDeeplinkStateData.h"

#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *launchedDeeplink;
 */
#pragma mark - Public constants
NSString *const ADJLaunchedDeeplinkStateDataMetadataTypeValue = @"LaunchedDeeplinkStateData";

#pragma mark - Private constants
static NSString *const kLaunchedDeeplinkKey = @"launchedDeeplink";

@implementation ADJLaunchedDeeplinkStateData
#pragma mark Instantiation
+ (nonnull ADJResultNN<ADJLaunchedDeeplinkStateData *> *)
    instanceFromIoData:(nonnull ADJIoData *)ioData
{
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
        [ioData isExpectedMetadataTypeValue:ADJLaunchedDeeplinkStateDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [ADJResultNN
                failWithMessage:@"Cannot create launched deeplink statedata from io data"
                key:@"unexpected metadata type value fail"
                otherFail:unexpectedMetadataTypeValueFail];
    }


    ADJNonEmptyString *_Nullable launchedDeeplink =
        [ioData.propertiesMap pairValueWithKey:kLaunchedDeeplinkKey];

    return [ADJResultNN okWithValue:
            [[ADJLaunchedDeeplinkStateData alloc] initWithLaunchedDeeplink:launchedDeeplink]];
}

- (nonnull instancetype)initWithInitialState {
    return [self initWithLaunchedDeeplink:nil];
}

- (nonnull instancetype)initWithLaunchedDeeplink:(nullable ADJNonEmptyString *)launchedDeeplink {
    self = [super init];

    _launchedDeeplink = launchedDeeplink;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
#pragma mark - ADJIoDataSerializable

- (nonnull ADJIoData *)toIoData {
    ADJIoDataBuilder *_Nonnull ioDataBuilder = [[ADJIoDataBuilder alloc] initWithMetadataTypeValue:ADJLaunchedDeeplinkStateDataMetadataTypeValue];
    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
                                       key:kLaunchedDeeplinkKey
                       ioValueSerializable:self.launchedDeeplink];

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject

- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJLaunchedDeeplinkStateDataMetadataTypeValue,
            kLaunchedDeeplinkKey, self.launchedDeeplink,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    hashCode = ADJHashCodeMultiplier *
    hashCode + [ADJUtilObj objecNullableHash:self.launchedDeeplink];
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJLaunchedDeeplinkStateData class]]) {
        return NO;
    }

    ADJLaunchedDeeplinkStateData *other = (ADJLaunchedDeeplinkStateData *)object;
    return [ADJUtilObj objectEquals:self.launchedDeeplink other:other.launchedDeeplink];
}

@end


