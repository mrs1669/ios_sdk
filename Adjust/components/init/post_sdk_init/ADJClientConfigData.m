//
//  ADJClientConfigData.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientConfigData.h"

#import "ADJAdjustLogMessageData.h"
#import "ADJUtilF.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *appToken;
 @property (readonly, assign, nonatomic) BOOL isSandboxEnvironmentOrElseProduction;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *defaultTracker;
 @property (readonly, assign, nonatomic) BOOL doLogAll;
 @property (readonly, assign, nonatomic) BOOL doNotLogAny;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *urlStrategyBaseDomain;
 @property (nullable, readonly, strong, nonatomic) AdjustDataResidency dataResidency;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *externalDeviceId;
 @property (nullable, readonly, strong, nonatomic) ADJClientCustomEndpointData *clientCustomEndpointData;
 @property (readonly, assign, nonatomic) BOOL doNotOpenDeferredDeeplink;
 @property (readonly, assign, nonatomic) BOOL doNotReadAsaAttribution;
 @property (readonly, assign, nonatomic) BOOL canSendInBackground;
 @property (nullable, readonly, strong, nonatomic) ADJNonNegativeInt *eventIdDeduplicationMaxCapacity;
 @property (nullable, readonly, strong, nonatomic) id<ADJAdjustAttributionSubscriber> adjustAttributionSubscriber;
 @property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> adjustLogSubscriber;
 */

#pragma mark - Private constants
static NSString *const kDomainValidationRegexString =
    @"^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z]{2,6}";

@implementation ADJClientConfigData
#pragma mark Instantiation
+ (nullable instancetype)instanceFromClientWithAdjustConfig:(nullable ADJAdjustConfig *)adjustConfig
                                                     logger:(nonnull ADJLogger *)logger {
    if (adjustConfig == nil) {
        [logger errorClient:@"Cannot create config with null adjust config value"];
        return nil;
    }

    ADJResultNN<ADJNonEmptyString *> *_Nonnull appTokenResult =
        [ADJNonEmptyString instanceFromString:adjustConfig.appToken];
    if (appTokenResult.failMessage != nil) {
        [logger errorClient:@"Cannot create config with invalid app token"
                failMessage:appTokenResult.failMessage];
        return nil;
    }

    ADJResultNN<ADJNonEmptyString *> *_Nonnull environmentResult =
        [ADJNonEmptyString instanceFromString:adjustConfig.environment];
    if (environmentResult.failMessage != nil) {
        [logger errorClient:@"Cannot create config with invalid environment"
                failMessage:environmentResult.failMessage];
        return nil;
    }

    BOOL isSandboxEnvironment =
        [environmentResult.value.stringValue isEqualToString:ADJEnvironmentSandbox];
    BOOL isProductionEnvironment =
        [environmentResult.value.stringValue isEqualToString:ADJEnvironmentProduction];
    
    if (! isSandboxEnvironment && ! isProductionEnvironment) {
        [logger errorClient:@"Cannot create config with unexpected environment value"
              expectedValue:[NSString stringWithFormat:@"%@ or %@",
                             ADJEnvironmentSandbox, ADJEnvironmentProduction]
                actualValue:environmentResult.value.stringValue];
        return nil;
    }

    ADJResultNL<ADJNonEmptyString *> *_Nonnull defaultTrackerResult =
        [ADJNonEmptyString instanceFromOptionalString:adjustConfig.defaultTracker];
    if (defaultTrackerResult.failMessage != nil) {
        [logger noticeClient:@"Cannot set invalid default tracker"
                 failMessage:defaultTrackerResult.failMessage];
    }

    BOOL doNotLogAny =
        adjustConfig.doNotLogAnyNumberBool != nil
        && adjustConfig.doNotLogAnyNumberBool.boolValue;

    BOOL doLogAll =
        adjustConfig.doLogAllNumberBool != nil
        && adjustConfig.doLogAllNumberBool.boolValue;

    ADJNonEmptyString *_Nullable urlStrategyDomain =
        [ADJClientConfigData urlStrategyDomainWithClientData:adjustConfig.urlStrategyDomain
        logger:logger];

    ADJResultNL<ADJNonEmptyString *> *_Nonnull dataResidencyResult =
        [ADJClientConfigData dataResidencyWithClientData:adjustConfig.dataResidency];
    if (dataResidencyResult.failMessage != nil) {
        [logger noticeClient:@"Cannot set invalid data residency"
                 failMessage:dataResidencyResult.failMessage];
    }
    AdjustDataResidency _Nullable dataResidency =
        dataResidencyResult != nil ? dataResidencyResult.value.stringValue : nil;

    ADJResultNL<ADJNonEmptyString *> *_Nonnull externalDeviceIdResult =
        [ADJNonEmptyString instanceFromOptionalString:adjustConfig.externalDeviceId];
    if (externalDeviceIdResult.failMessage != nil) {
        [logger noticeClient:@"Cannot set invalid external device id"
                 failMessage:externalDeviceIdResult.failMessage];
    }

    ADJResultNL<ADJNonEmptyString *> *_Nonnull customEndpointUrlResult =
        [ADJNonEmptyString instanceFromOptionalString:adjustConfig.customEndpointUrl];
    if (customEndpointUrlResult.failMessage != nil) {
        [logger noticeClient:@"Cannot set invalid custom endpoint url"
                 failMessage:customEndpointUrlResult.failMessage];
    }

    ADJResultNL<ADJNonEmptyString *> *_Nonnull customEndpointPublicKeyHashResult =
        [ADJNonEmptyString instanceFromOptionalString:adjustConfig.customEndpointPublicKeyHash];
    if (customEndpointPublicKeyHashResult.failMessage != nil) {
        [logger noticeClient:@"Cannot set invalid custom endpoint public key hash"
                 failMessage:customEndpointPublicKeyHashResult.failMessage];
    }

    ADJClientCustomEndpointData *_Nullable clientCustomEndpointData = nil;
    if (customEndpointPublicKeyHashResult.value != nil
        && customEndpointUrlResult.value == nil)
    {
        [logger noticeClient:@"Cannot configure certificate pinning"
         " without a custom endpoint"];
    } else if (customEndpointUrlResult.value != nil) {
        clientCustomEndpointData =
            [[ADJClientCustomEndpointData alloc]
             initWithUrl:customEndpointUrlResult.value
             publicKeyHash:customEndpointPublicKeyHashResult.value];
    }

    BOOL doNotOpenDeferredDeeplink =
        adjustConfig.doNotOpenDeferredDeeplinkNumberBool != nil
        && adjustConfig.doNotOpenDeferredDeeplinkNumberBool.boolValue;

    BOOL doNotReadAsaAttribution =
        adjustConfig.doNotReadAppleSearchAdsAttributionNumberBool != nil
        && adjustConfig.doNotReadAppleSearchAdsAttributionNumberBool.boolValue;

    BOOL canSendInBackground =
        adjustConfig.canSendInBackgroundNumberBool != nil
        && adjustConfig.canSendInBackgroundNumberBool.boolValue;

    ADJNonNegativeInt *_Nullable eventIdDeduplicationMaxCapacity =
        [ADJNonNegativeInt
         instanceFromOptionalIntegerNumber:adjustConfig.eventIdDeduplicationMaxCapacityNumberInt
         logger:logger];
/* TODO: add at later commit
     ADJResultNL<ADJNonNegativeInt *> *_Nonnull eventIdDeduplicationMaxCapacityResult =
         [ADJNonNegativeInt
          instanceFromOptionalIntegerNumber:adjustConfig.eventIdDeduplicationMaxCapacityNumberInt];
    if (eventIdDeduplicationMaxCapacityResult.fail != nil) {
        [logger noticeClient:@"Cannot configure invalid max deduplication event capacity"];
                  resultFail:eventIdDeduplicationMaxCapacityResult.fail];
    }
*/
    return [[ADJClientConfigData alloc]
            initWithAppToken:appTokenResult.value
            isSandboxEnvironmentOrElseProduction:isSandboxEnvironment
            defaultTracker:defaultTrackerResult.value
            doLogAll:doLogAll
            doNotLogAny:doNotLogAny
            urlStrategyBaseDomain:urlStrategyDomain
            dataResidency:dataResidency
            externalDeviceId:externalDeviceIdResult.value
            clientCustomEndpointData:clientCustomEndpointData
            doNotOpenDeferredDeeplink:doNotOpenDeferredDeeplink
            doNotReadAsaAttribution:doNotReadAsaAttribution
            canSendInBackground:canSendInBackground
            eventIdDeduplicationMaxCapacity:eventIdDeduplicationMaxCapacity
            adjustAttributionSubscriber:adjustConfig.adjustAttributionSubscriber
            adjustLogSubscriber:adjustConfig.adjustLogSubscriber];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)
    initWithAppToken:(nonnull ADJNonEmptyString *)appToken
    isSandboxEnvironmentOrElseProduction:(BOOL)isSandboxEnvironmentOrElseProduction
    defaultTracker:(nullable ADJNonEmptyString *)defaultTracker
    doLogAll:(BOOL)doLogAll
    doNotLogAny:(BOOL)doNotLogAny
    urlStrategyBaseDomain:(nullable ADJNonEmptyString *)urlStrategyBaseDomain
    dataResidency:(nullable AdjustDataResidency)dataResidency
    externalDeviceId:(nullable ADJNonEmptyString *)externalDeviceId
    clientCustomEndpointData:(nullable ADJClientCustomEndpointData *)clientCustomEndpointData
    doNotOpenDeferredDeeplink:(BOOL)doNotOpenDeferredDeeplink
    doNotReadAsaAttribution:(BOOL)doNotReadAsaAttribution
    canSendInBackground:(BOOL)canSendInBackground
    eventIdDeduplicationMaxCapacity:(nullable ADJNonNegativeInt *)eventIdDeduplicationMaxCapacity
    adjustAttributionSubscriber:
        (nullable id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber
    adjustLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustLogSubscriber
{
    self = [super init];

    _appToken = appToken;
    _isSandboxEnvironmentOrElseProduction = isSandboxEnvironmentOrElseProduction;
    _defaultTracker = defaultTracker;
    _doLogAll = doLogAll;
    _doNotLogAny = doNotLogAny;
    _urlStrategyBaseDomain = urlStrategyBaseDomain;
    _dataResidency = dataResidency;
    _externalDeviceId = externalDeviceId;
    _clientCustomEndpointData = clientCustomEndpointData;
    _doNotOpenDeferredDeeplink = doNotOpenDeferredDeeplink;
    _doNotReadAsaAttribution = doNotReadAsaAttribution;
    _canSendInBackground = canSendInBackground;
    _eventIdDeduplicationMaxCapacity = eventIdDeduplicationMaxCapacity;
    _adjustAttributionSubscriber = adjustAttributionSubscriber;
    _adjustLogSubscriber = adjustLogSubscriber;

    return self;
}

#pragma mark Public API
- (nonnull ADJNonEmptyString *)environment {
    return self.isSandboxEnvironmentOrElseProduction ?
    [ADJClientConfigData sandboxEnvironment] : [ADJClientConfigData productionEnvironment];
}

#pragma mark Internal Methods
+ (nonnull ADJNonEmptyString *)sandboxEnvironment {
    static dispatch_once_t sandboxEnvironmentToken;
    static id sandboxEnvironment;
    dispatch_once(&sandboxEnvironmentToken, ^{
        sandboxEnvironment = [[ADJNonEmptyString alloc]
                              initWithConstStringValue:ADJEnvironmentSandbox];
    });
    return sandboxEnvironment;
}

+ (nonnull ADJNonEmptyString *)productionEnvironment {
    static dispatch_once_t productionEnvironmentToken;
    static id productionEnvironment;
    dispatch_once(&productionEnvironmentToken, ^{
        productionEnvironment = [[ADJNonEmptyString alloc]
                                 initWithConstStringValue:ADJEnvironmentProduction];
    });
    return productionEnvironment;
}

+ (nonnull ADJResultNN<NSRegularExpression *> *)domainValidationRegex {
    static dispatch_once_t onceExcludedRegexInstanceToken;
    static ADJResultNN<NSRegularExpression *> *result;

    dispatch_once(&onceExcludedRegexInstanceToken, ^{
        NSError *error = nil;

        NSRegularExpression *_Nullable regex =
            [NSRegularExpression regularExpressionWithPattern:kDomainValidationRegexString
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];

        if (regex != nil) {
            result = [ADJResultNN okWithValue:regex];
        } else {
            result = [ADJResultNN failWithMessage:
                      @"NSRegularExpression regularExpression with excluded deeplinks pattern"
                      " returned nil"];
                                            // TODO: add at later commit: error:error];
        }
    });

    if (result == nil) {
        return [ADJResultNN failWithMessage:
                @"NSRegularExpression regularExpression with excluded deeplinks pattern"
                " result was not set in dispatch_once"];
    }

    return result;
}

+ (nullable ADJNonEmptyString *)
    urlStrategyDomainWithClientData:(nullable NSString *)urlStrategyDomain
    logger:(nonnull ADJLogger *)logger
{
    ADJResultNL<ADJNonEmptyString *> *_Nonnull urlStrategyDomainResult =
        [ADJNonEmptyString instanceFromOptionalString:urlStrategyDomain];

    if (urlStrategyDomainResult.failMessage != nil) {
        [logger noticeClient:@"Cannot set invalid URL strategy domain"
                 failMessage:urlStrategyDomainResult.failMessage];
        return nil;
    }
    if (urlStrategyDomainResult.value == nil) {
        return nil;
    }

    ADJResultNN<NSRegularExpression *> *_Nonnull domainValidationRegexResult =
        [ADJClientConfigData domainValidationRegex];

    if (domainValidationRegexResult.failMessage != nil) {
        [logger noticeClient:@"Cannot validate URL strategy domain with invalid regex"
                 failMessage:domainValidationRegexResult.failMessage];
                 // TODO add fail object and issue at a later commit
        return nil;
    }

    if (! [ADJUtilF matchesWithString:urlStrategyDomainResult.value.stringValue
                                regex:domainValidationRegexResult.value])
    {
        [logger noticeClient:@"Cannot use URL strategy domain that does not match expected pattern"
                         key:@"URL strategy domain"
                       value:urlStrategyDomainResult.value.stringValue];
        return nil;
    }

    return urlStrategyDomainResult.value;
}

+ (nonnull ADJResultNL<ADJNonEmptyString *> *)
    dataResidencyWithClientData:(nullable NSString *)dataResidency
{
    ADJResultNL<ADJNonEmptyString *> *_Nonnull dataResidencyResult =
        [ADJNonEmptyString instanceFromOptionalString:dataResidency];
    if (dataResidencyResult.failMessage != nil || dataResidencyResult.value == nil) {
        return dataResidencyResult;
    }

    if ([AdjustDataResidencyEU isEqualToString:dataResidencyResult.value.stringValue]
        || [AdjustDataResidencyTR isEqualToString:dataResidencyResult.value.stringValue]
        || [AdjustDataResidencyUS isEqualToString:dataResidencyResult.value.stringValue])
    {
        return dataResidencyResult;
    }

    return [ADJResultNL failWithMessage:@"Cannot use data residency that is not expected"];
    // TODO: add key/value with received value
}

@end

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *url;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *publicKeyHash;
 */
@implementation ADJClientCustomEndpointData
#pragma mark Instantiation
- (nonnull instancetype)initWithUrl:(nonnull ADJNonEmptyString *)url
                      publicKeyHash:(nullable ADJNonEmptyString *)publicKeyHash {
    self = [super init];

    _url = url;
    _publicKeyHash = publicKeyHash;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
