//
//  ADJClientLaunchedDeeplinkData.m
//  Adjust
//
//  Created by Aditi Agrawal on 08/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientLaunchedDeeplinkData.h"

#import "ADJUtilF.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJUtilMap.h"
#import "ADJResultErr.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *launchedDeeplink;
 */

#pragma mark - Public constants
NSString *const ADJClientLaunchedDeeplinkDataMetadataTypeValue = @"ClientLaunchedDeeplinkData";

#pragma mark - Private constants
static NSString *const kLaunchedDeeplinkKey = @"launchedDeeplink";
static NSString *const kExcludedDeeplinksPattern = @"^(fb|vk)[0-9]{5,}[^:]*://authorize.*access_token=.*";

@implementation ADJClientLaunchedDeeplinkData
#pragma mark Instantiation
+ (nullable instancetype)
    instanceFromClientWithAdjustLaunchedDeeplink:
        (nullable ADJAdjustLaunchedDeeplink *)adjustLaunchedDeeplink
    logger:(nonnull ADJLogger *)logger
{
    if (adjustLaunchedDeeplink == nil) {
        [logger errorClient:
         @"Cannot create launched deeplink with nil adjust launched deeplink value"];
        return nil;
    }

    NSString *_Nullable stringLaunchedDeeplink;
    if (adjustLaunchedDeeplink.urlDeeplink != nil) {
        stringLaunchedDeeplink = adjustLaunchedDeeplink.urlDeeplink.absoluteString;
    } else {
        stringLaunchedDeeplink = adjustLaunchedDeeplink.stringDeeplink;
    }

    ADJResultNN<ADJNonEmptyString *> *_Nullable launchedDeeplinkResult =
        [ADJNonEmptyString instanceFromString:stringLaunchedDeeplink];
    if (launchedDeeplinkResult.failMessage != nil) {
        [logger errorClient:@"Cannot create launched deeplink with invalid value"
                failMessage:launchedDeeplinkResult.failMessage];
        return nil;
    }

    ADJResultErr<NSRegularExpression *> *_Nonnull excludedRegexResult =
        [ADJClientLaunchedDeeplinkData excludedRegex];

    if (excludedRegexResult.error != nil) {
        [logger errorClient:@"Cannot create launched deeplink without excludedRegex"
                    nserror:excludedRegexResult.error];
        return nil;
    }
    if (excludedRegexResult.value == nil) {
        [logger errorClient:@"Cannot create launched deeplink without excludedRegex"];
        return nil;
    }

    if ([ADJUtilF matchesWithString:launchedDeeplinkResult.value.stringValue
                              regex:excludedRegexResult.value])
    {
        [logger errorClient:@"Cannot create launched deeplink that matches excludedRegex"];
        return nil;
    }

    return [[ADJClientLaunchedDeeplinkData alloc]
            initWithaLaunchedDeeplink:launchedDeeplinkResult.value];
}

+ (nullable instancetype)
    instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
    logger:(nonnull ADJLogger *)logger
{
    ADJStringMap *_Nonnull propertiesMap = clientActionInjectedIoData.propertiesMap;

    ADJNonEmptyString *_Nullable launchedDeeplink =
    [propertiesMap pairValueWithKey:kLaunchedDeeplinkKey];

    ADJAdjustLaunchedDeeplink *_Nullable adjustLaunchedDeeplink =
    [[ADJAdjustLaunchedDeeplink alloc] initWithString:
     launchedDeeplink != nil ? launchedDeeplink.stringValue : nil];

    return [self instanceFromClientWithAdjustLaunchedDeeplink:adjustLaunchedDeeplink
                                                       logger:logger];
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithaLaunchedDeeplink:(nonnull ADJNonEmptyString *)launchedDeeplink {
    self = [super init];

    _launchedDeeplink = launchedDeeplink;

    return self;
}

#pragma mark Public API
#pragma mark - ADJClientActionIoDataInjectable
- (void)injectIntoClientActionIoDataBuilder:(nonnull ADJIoDataBuilder *)clientActionIoDataBuilder {
    ADJStringMapBuilder *_Nonnull propertiesMapBuilder =
    clientActionIoDataBuilder.propertiesMapBuilder;

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kLaunchedDeeplinkKey
                       ioValueSerializable:self.launchedDeeplink];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientLaunchedDeeplinkDataMetadataTypeValue,
            kLaunchedDeeplinkKey, self.launchedDeeplink,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + self.launchedDeeplink.hash;

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJClientLaunchedDeeplinkData class]]) {
        return NO;
    }

    ADJClientLaunchedDeeplinkData *other = (ADJClientLaunchedDeeplinkData *)object;
    return [ADJUtilObj objectEquals:self.launchedDeeplink other:other.launchedDeeplink];
}

#pragma mark Internal Methods
+ (nonnull ADJResultErr<NSRegularExpression *> *)excludedRegex {
    static dispatch_once_t onceExcludedRegexInstanceToken;
    static ADJResultErr<NSRegularExpression *> *result;

    dispatch_once(&onceExcludedRegexInstanceToken, ^{
        NSError *error = nil;

        NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:kExcludedDeeplinksPattern
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:&error];

        if (error != nil) {
            result = [ADJResultErr failWithError:error];
        } else if (regex != nil) {
            result = [ADJResultErr okWithValue:regex];
        } else {
            result = [ADJResultErr okWithoutValue];
        }
    });
    
    if (result == nil) {
        return [ADJResultErr okWithoutValue];
    }

    return result;
}

@end

