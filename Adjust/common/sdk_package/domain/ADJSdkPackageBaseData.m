//
//  ADJSdkPackageBaseData.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkPackageBaseData.h"

#import "ADJIoDataBuilder.h"
#import "ADJIoData.h"
#import "ADJUtilF.h"
#import "ADJUtilMap.h"
/*
#import "ADJAdRevenuePackageData.h"
#import "ADJAttributionPackageData.h"
#import "ADJBillingSubscriptionPackageData.h"
#import "ADJClickPackageData.h"
#import "ADJGdprForgetPackageData.h"
#import "ADJInfoPackageData.h"
#import "ADJLogPackageData.h"
 */
#import "ADJSessionPackageData.h"
#import "ADJEventPackageData.h"

//#import "ADJThirdPartySharingPackageData.h"

#pragma mark Fields
#pragma mark - Public properties
/* ADJSdkPackageData.h
 @property (nonnull, readonly, strong, nonatomic) NSString *path;
 @property (nonnull, readonly, strong, nonatomic) NSString *clientSdk;
 @property (readonly, assign, nonatomic) BOOL isPostOrElseGetNetworkMethod;
 @property (nonnull, readonly, strong, nonatomic) ADJStringMap *parameters;
 */

#pragma mark - Public constants
NSString *const ADJSdkPackageDataMetadataTypeValue = @"SdkPackageData";

#pragma mark - Private constants
static NSString *const kPathKey = @"path";
static NSString *const kClientSdkKey = @"clientSdk";
static NSString *const kParametersMapName = @"PARAMETERS_MAP";

@implementation ADJSdkPackageBaseData
#pragma mark - Synthesize protocol properties
@synthesize path = _path;
@synthesize clientSdk = _clientSdk;
@synthesize isPostOrElseGetNetworkMethod = _isPostOrElseGetNetworkMethod;
@synthesize parameters = _parameters;

#define pathToPackage(packageClass)                                             \
    if ([packageClass ## Path isEqualToString:path.stringValue]) {              \
        return [[packageClass alloc] initWithClientSdk:clientSdk.stringValue    \
                                            parameters:parameters               \
                                                ioData:ioData                   \
                                                logger:logger];                 \
    }

#pragma mark Instantiation
+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger
{
    if (! [ioData
            isExpectedMetadataTypeValue:ADJSdkPackageDataMetadataTypeValue
            logger:logger])
    {
        return nil;
    }

    ADJStringMap *_Nonnull propertiesMap = ioData.propertiesMap;

    ADJNonEmptyString *_Nullable path =
        [propertiesMap pairValueWithKey:kPathKey];
    if (path == nil) {
        [logger error:@"Cannot create instance from Io data without valid path"];
        return nil;
    }

    ADJNonEmptyString *_Nullable clientSdk =
        [propertiesMap pairValueWithKey:kClientSdkKey];
    if (clientSdk == nil) {
        [logger error:@"Cannot create instance from Io data without valid clientSdk"];
        return nil;
    }

    ADJStringMap *_Nullable parameters = [ioData mapWithName:kParametersMapName];
    if (parameters == nil) {
        [logger error:@"Cannot create instance from Io data without valid parameters"];
        return nil;
    }
/*
    pathToPackage(ADJAdRevenuePackageData)
    pathToPackage(ADJAttributionPackageData)
    pathToPackage(ADJBillingSubscriptionPackageData)
    pathToPackage(ADJClickPackageData)
    pathToPackage(ADJGdprForgetPackageData)
    pathToPackage(ADJInfoPackageData)
    pathToPackage(ADJLogPackageData)
 */
    pathToPackage(ADJSessionPackageData)
    pathToPackage(ADJEventPackageData)

    //pathToPackage(ADJThirdPartySharingPackageData)

    [logger error:@"Cannot create instance from Io data"
        " without matching %@ path to valid package type", path];

    return nil;
}

- (nonnull instancetype)initWithPath:(nonnull NSString *)path
                           clientSdk:(nonnull NSString *)clientSdk
        isPostOrElseGetNetworkMethod:(BOOL)isPostOrElseGetNetworkMethod
                          parameters:(nonnull ADJStringMap *)parameters
{
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJSdkPackageBaseData class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }

    self = [super init];

    _path = path;
    _clientSdk = clientSdk;
    _isPostOrElseGetNetworkMethod = isPostOrElseGetNetworkMethod;
    _parameters = parameters;

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
            initWithMetadataTypeValue:
                ADJSdkPackageDataMetadataTypeValue];

    ADJStringMapBuilder *_Nonnull propertiesMapBuilder = ioDataBuilder.propertiesMapBuilder;

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                          key:kPathKey
                        constValue:self.path];

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                          key:kClientSdkKey
                        constValue:self.clientSdk];

    ADJStringMapBuilder *_Nonnull parametersMap =
        [ioDataBuilder addAndReturnNewMapBuilderByName:kParametersMapName];

    [parametersMap addAllPairsWithStringMap:self.parameters];

    [self concreteInjectCustomSerializationWithIoDatabuilder:ioDataBuilder];

    return [[ADJIoData alloc] initWithIoDataBuider:ioDataBuilder];
}

#pragma mark - ADJSdkPackageData
- (nonnull ADJNonEmptyString *)generateShortDescription {
    return [self concreteGenerateShortDescription];
}

- (nonnull ADJNonEmptyString *)generateExtendedDescription {
    /*
    return [[ADJNonEmptyString alloc] initWithValidatedStringValue:
                [ADJUtilF formatNewlineKeyValuesWithName:
                    [self generateShortDescription].stringValue,
                    kPathKey, self.path,
                    kClientSdkKey, self.clientSdk,
                    @"Parameters", [ADJUtilF
                                        formatNewlineKeyValuesWithName:@""
                                        stringKeyDictionary:self.parameters.map],
                    nil]];
*/
    NSMutableString *_Nonnull sb = [NSMutableString stringWithFormat:@"\n"];

    [sb appendString:[self generateExtendDescriptionLineWithKey:kPathKey
                                                          value:self.path]];

    [sb appendString:[self generateExtendDescriptionLineWithKey:kClientSdkKey
                                                          value:self.clientSdk]];

    [sb appendString:@"Parameters"];

    for (NSString *_Nonnull key in self.parameters.map) {
        ADJNonEmptyString *_Nonnull value =
            [self.parameters.map objectForKey:key];

        [sb appendString:[self generateExtendMapLineWithKey:key value:value.stringValue]];
    }

    return [[ADJNonEmptyString alloc] initWithConstStringValue:(NSString *_Nonnull)sb];
}

#pragma mark Protected Methods
#pragma mark - Abstract
- (nonnull ADJNonEmptyString *)concreteGenerateShortDescription {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - With Default Implementation
- (void)concreteInjectCustomSerializationWithIoDatabuilder:(nonnull ADJIoDataBuilder *)ioDataBuilder {
    // default implementation does nothing
    //  override in sub-classes when ioData has extra information besides sdk package base
}

#pragma mark Internal Methods
- (nonnull NSString *)generateExtendDescriptionLineWithKey:(nonnull NSString *)key
                                                     value:(nonnull NSString *)value
{
    return [NSString stringWithFormat:@"%-25s%@\n",
            [NSString stringWithFormat:@"%@:", key].UTF8String,
            value];
}

- (nonnull NSString *)generateExtendMapLineWithKey:(nonnull NSString *)key
                                             value:(nonnull NSString *)value
{
    return [NSString stringWithFormat:@"\n\t%-25s%@",
            [NSString stringWithFormat:@"%@:", key].UTF8String,
            value];
}

@end
