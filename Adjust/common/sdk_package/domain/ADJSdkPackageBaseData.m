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
#import "ADJGdprForgetPackageData.h"
#import "ADJLogPackageData.h"
#import "ADJAttributionPackageData.h"
#import "ADJBillingSubscriptionPackageData.h"
#import "ADJAdRevenuePackageData.h"
#import "ADJSessionPackageData.h"
#import "ADJEventPackageData.h"
#import "ADJInfoPackageData.h"
#import "ADJClickPackageData.h"
#import "ADJThirdPartySharingPackageData.h"
#import "ADJMeasurementConsentPackageData.h"
#import "ADJV4ActivityPackage.h"

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

#define pathToPackage(packageClass)                                         \
    if ([packageClass ## Path isEqualToString:path.stringValue]) {          \
        return [ADJResult okWithValue:                                      \
            [[packageClass alloc] initWithClientSdk:clientSdk.stringValue   \
                                         parameters:parameters              \
                                             ioData:ioData]];               \
    }                                                                       \

#pragma mark Instantiation
+ (nonnull ADJResult<ADJSdkPackageBaseData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData {
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
        [ioData isExpectedMetadataTypeValue:ADJSdkPackageDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [ADJResult failWithMessage:@"Cannot create sdk package data from io data"
                                      key:@"unexpected metadata type value fail"
                                otherFail:unexpectedMetadataTypeValueFail];
    }

    ADJStringMap *_Nonnull propertiesMap = ioData.propertiesMap;

    ADJNonEmptyString *_Nullable path = [propertiesMap pairValueWithKey:kPathKey];
    if (path == nil) {
        return [ADJResult
                failWithMessage:@"Cannot create sdk package data from io data without path"];
    }

    ADJNonEmptyString *_Nullable clientSdk =
        [propertiesMap pairValueWithKey:kClientSdkKey];
    if (clientSdk == nil) {
        return [ADJResult
                failWithMessage:@"Cannot create sdk package data from io data without client sdk"];
    }

    ADJStringMap *_Nullable parameters = [ioData mapWithName:kParametersMapName];
    if (parameters == nil) {
        return [ADJResult
                failWithMessage:@"Cannot create sdk package data from io data without parameters"
                key:@"parametersMapName"
                stringValue:kParametersMapName];
    }

    pathToPackage(ADJLogPackageData)
    pathToPackage(ADJGdprForgetPackageData)
    pathToPackage(ADJAttributionPackageData)
    pathToPackage(ADJBillingSubscriptionPackageData)
    pathToPackage(ADJAdRevenuePackageData)
    pathToPackage(ADJClickPackageData)
    pathToPackage(ADJSessionPackageData)
    pathToPackage(ADJEventPackageData)
    pathToPackage(ADJInfoPackageData)
    pathToPackage(ADJThirdPartySharingPackageData)
    pathToPackage(ADJMeasurementConsentPackageData)

    return [ADJResult
            failWithMessage:@"Cannot create sdk package data from io data"
            " without matching path to valid package type"
            key:@""
            stringValue:path.stringValue];
}

+ (nonnull ADJOptionalFailsNL<NSArray<id<ADJSdkPackageData>> *> *)
    instanceArrayFromV4WithActivityPackageArray:(nullable NSArray *)v4ActivityPackageArray
{
    if (v4ActivityPackageArray == nil) {
        return [[ADJOptionalFailsNL alloc] initWithOptionalFails:nil value:nil];
    }

    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    NSMutableArray<id<ADJSdkPackageData>> *_Nonnull activityPackageArryMut =
        [[NSMutableArray alloc] init];

    for (id _Nonnull activityPackageObject in v4ActivityPackageArray) {
        id<ADJSdkPackageData> _Nullable sdkPackageData =
            [ADJSdkPackageBaseData convertV4PackageWithActivityPackageObject:activityPackageObject
                                                            optionalFailsMut:optionalFailsMut];

        if (sdkPackageData != nil) {
            [activityPackageArryMut addObject:sdkPackageData];
        }
    }

    if (activityPackageArryMut.count == 0) {
        return [[ADJOptionalFailsNL alloc]
                initWithOptionalFails:optionalFailsMut
                value:nil];
    }

    return [[ADJOptionalFailsNL alloc] initWithOptionalFails:optionalFailsMut
                                                       value:activityPackageArryMut];
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
    ADJIoDataBuilder *_Nonnull ioDataBuilder = [[ADJIoDataBuilder alloc]
                                                initWithMetadataTypeValue:ADJSdkPackageDataMetadataTypeValue];

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

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - ADJSdkPackageData
- (nonnull ADJNonEmptyString *)generateShortDescription {
    return [self concreteGenerateShortDescription];
}

- (nonnull NSDictionary<NSString *, NSString *> *)foundationStringMap {
    NSMutableDictionary<NSString *, NSString *> *_Nonnull builder =
        [[NSMutableDictionary alloc] initWithDictionary:[self.parameters foundationStringMap]];

    [builder setObject:self.path forKey:kPathKey];
    [builder setObject:self.clientSdk forKey:kClientSdkKey];

    return builder;
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
+ (nullable id<ADJSdkPackageData>)
    convertV4PackageWithActivityPackageObject:
        (nullable id)activityPackageObject
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    // is expected to be ADJV4ActivityPackage class
    //  because when read, name @"ADJActivityPackage" was set to ADJV4ActivityPackage
    if (! [activityPackageObject isKindOfClass:[ADJV4ActivityPackage class]]) {
        [optionalFailsMut addObject:
         [[ADJResultFail alloc]
          initWithMessage:@"Could not cast object as a v4 activity package"
          key:@"unexpected class"
          stringValue:NSStringFromClass([activityPackageObject class])]];

        return nil;
    }

    ADJV4ActivityPackage *_Nonnull v4ActivityPackage =
        (ADJV4ActivityPackage *)activityPackageObject;

    ADJResult<ADJNonEmptyString *> *_Nonnull v4ClientSdkResult =
        [ADJNonEmptyString instanceFromString:v4ActivityPackage.clientSdk];

    if (v4ClientSdkResult.fail != nil) {
        [optionalFailsMut addObject:[[ADJResultFail alloc]
                                     initWithMessage:@"Could not parse client sdk"
                                     key:@"client sdk parse fail"
                                     otherFail:v4ClientSdkResult.fail]];
        return nil;
    }

    ADJResult<ADJStringMap *> * _Nonnull parametersResult =
        [ADJSdkPackageBaseData convertV4ParametersWithV4ActivityPackage:v4ActivityPackage
                                                       optionalFailsMut:optionalFailsMut];
    if (parametersResult.fail != nil) {
        [optionalFailsMut addObject:parametersResult.fail];

        return nil;
    }

    ADJResult<ADJSdkPackageBaseData *> *_Nonnull sdkPackageDataResult =
        [ADJSdkPackageBaseData convertSdkPackageFromV4WithV4Path:v4ActivityPackage.path
                                                     v4ClientSdk:v4ClientSdkResult.value
                                                      parameters:parametersResult.value];

    if (sdkPackageDataResult.fail != nil) {
        [optionalFailsMut addObject:sdkPackageDataResult.fail];
        return nil;
    }

    return (id<ADJSdkPackageData>)sdkPackageDataResult.value;
}

+ (nonnull ADJResult<ADJStringMap *> *)
    convertV4ParametersWithV4ActivityPackage:(nonnull ADJV4ActivityPackage *)v4ActivityPackage
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    if (v4ActivityPackage.parameters == nil) {
        return [ADJResult failWithMessage:@"Cannot use nil v4 activity package parameters"];
    }
    if (v4ActivityPackage.parameters.count == 0) {
        return [ADJResult failWithMessage:@"Cannot use empty v4 activity package parameters"];
    }

    ADJStringMapBuilder *_Nonnull parametersBuilder =
        [[ADJStringMapBuilder alloc] initWithEmptyMap];

    for (NSString *key in v4ActivityPackage.parameters) {
        ADJResult<ADJNonEmptyString *> *_Nonnull keyResult =
            [ADJNonEmptyString instanceFromString:key];
        if (keyResult.fail != nil) {
            [optionalFailsMut addObject:[[ADJResultFail alloc]
                                         initWithMessage:
                                             @"Cannot parse key of v4 activity package parameter"
                                         key:@"key parsing fail"
                                         otherFail:keyResult.fail]];
            continue;
        }

        ADJResult<ADJNonEmptyString *> *_Nonnull valueResult =
            [ADJNonEmptyString instanceFromString:
             [v4ActivityPackage.parameters objectForKey:keyResult.value.stringValue]];
        if (valueResult.fail != nil) {
            [optionalFailsMut addObject:[[ADJResultFail alloc]
                                         initWithMessage:
                                             @"Cannot parse value of v4 activity package parameter"
                                         key:@"value parsing fail"
                                         otherFail:valueResult.fail]];
            continue;
        }

        [parametersBuilder addPairWithValue:valueResult.value
                                        key:keyResult.value.stringValue];
    }

    return [ADJResult okWithValue:
            [[ADJStringMap alloc] initWithStringMapBuilder:parametersBuilder]];
}

#define v4PathToPackage(v4PathConst, packageClass)                                  \
    if ([v4Path isEqualToString:v4PathConst]) {                                     \
        return [ADJResult okWithValue:                                              \
                [[packageClass alloc] initWithClientSdk:v4ClientSdk.stringValue     \
                                             parameters:parameters]];               \
}

+ (nonnull ADJResult<ADJSdkPackageBaseData *> *)
    convertSdkPackageFromV4WithV4Path:(nullable NSString *)v4Path
    v4ClientSdk:(nonnull ADJNonEmptyString *)v4ClientSdk
    parameters:(nonnull ADJStringMap *)parameters
{
    if (v4Path == nil) {
        return [ADJResult failWithMessage:@"Cannot create package with nil v4 path"];
    }

    v4PathToPackage(ADJV4PurchasePath, ADJBillingSubscriptionPackageData)
    v4PathToPackage(ADJV4SessionPath, ADJSessionPackageData)
    v4PathToPackage(ADJV4EventPath, ADJEventPackageData)
    v4PathToPackage(ADJV4AdRevenuePath, ADJAdRevenuePackageData)
    v4PathToPackage(ADJV4InfoPath, ADJInfoPackageData)
    v4PathToPackage(ADJV4ThirdPartySharingPath, ADJThirdPartySharingPackageData)

    // there are no attribution, click or gdpr packages in v4 main queue
    // TODO: Add more package types, if they are added to v4

    if ([v4Path isEqualToString:ADJV4DisableThirdPartySharingPath]) {
        return [ADJResult okWithValue:
                [[ADJThirdPartySharingPackageData alloc]
                 initV4DisableThirdPartySharingMigratedWithClientSdk:v4ClientSdk.stringValue
                 parameters:parameters]];
    }

    return [ADJResult failWithMessage:@"Cannot create package from unknown v4 path"
                                  key:@"v4 path"
                          stringValue:v4Path];
}

@end
