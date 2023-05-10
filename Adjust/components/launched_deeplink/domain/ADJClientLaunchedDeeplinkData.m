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
+ (nullable instancetype)instanceFromClientWithAdjustLaunchedDeeplink:
(nullable ADJAdjustLaunchedDeeplink *)adjustLaunchedDeeplink
                                                               logger:(nonnull ADJLogger *)logger {
    if (adjustLaunchedDeeplink == nil) {
        [logger errorClient:
         @"Cannot create launched deeplink with nil adjust launched deeplink value"];
        return nil;
    }

    NSString *_Nullable stringLaunchedDeeplink = adjustLaunchedDeeplink.stringDeeplink;

    if (adjustLaunchedDeeplink.urlDeeplink != nil) {
        stringLaunchedDeeplink = adjustLaunchedDeeplink.urlDeeplink.absoluteString;
    }

    ADJNonEmptyString *_Nullable launchedDeeplink =
    [ADJNonEmptyString instanceFromString:stringLaunchedDeeplink
                        sourceDescription:@"launched deeplink"
                                   logger:logger];
    if (launchedDeeplink == nil) {
        [logger errorClient:@"Cannot create launched deeplink with invalid value"];
        return nil;
    }

    NSError *error = nil;
    NSRegularExpression *_Nullable excludedRegex =
    [self excludedRegexWithError:&error];

    if (excludedRegex == nil) {
        [logger errorClient:@"Cannot create launched deeplink without excludedRegex"
                    nserror:error];
        return nil;
    }

    if ([ADJUtilF matchesWithString:launchedDeeplink.stringValue
                              regex:excludedRegex])
    {
        [logger errorClient:@"Cannot create launched deeplink that matches excludedRegex"];
        return nil;
    }

    return [[self alloc] initWithaLaunchedDeeplink:launchedDeeplink];
}

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger {
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
+ (nullable NSRegularExpression *)excludedRegexWithError:(NSError **)errorPtr {
    static dispatch_once_t onceExcludedRegexInstanceToken;
    static NSRegularExpression* excludedRegexInstance;
    __block NSError *parserError = nil;

    dispatch_once(&onceExcludedRegexInstanceToken, ^{
        NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:kExcludedDeeplinksPattern
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:&parserError];

        excludedRegexInstance = regex;
    });
    
    if (errorPtr && parserError) {
        *errorPtr = parserError;
    }

    return excludedRegexInstance;
}

@end

