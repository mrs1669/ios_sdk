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
 @property (nullable, readonly, strong, nonatomic)
     ADJClientCustomEndpointData *clientCustomEndpointData;
 @property (readonly, assign, nonatomic) BOOL doNotOpenDeferredDeeplink;
 @property (readonly, assign, nonatomic) BOOL doNotReadAsaAttribution;
 @property (readonly, assign, nonatomic) BOOL canSendInBackground;
 @property (nullable, readonly, strong, nonatomic)
     ADJNonNegativeInt *eventIdDeduplicationMaxCapacity;
 @property (nullable, readonly, strong, nonatomic)
     id<ADJAdjustIdentifierSubscriber> adjustIdentifierSubscriber;
 @property (nullable, readonly, strong, nonatomic)
     id<ADJAdjustAttributionSubscriber> adjustAttributionSubscriber;
 @property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> adjustLogSubscriber;
 @property (nullable, readonly, strong, nonatomic)
     NSDictionary<NSString *, id<ADJInternalCallback>> *internalConfigSubscriptions;
 */

#pragma mark - Private constants
static NSString *const kDomainValidationRegexString =
    @"^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z]{2,6}";

@implementation ADJClientConfigData
#pragma mark Instantiation
+ (nullable instancetype)
    instanceFromClientWithAdjustConfig:(nullable ADJAdjustConfig *)adjustConfig
    internalConfigSubscriptions:
        (nullable NSDictionary<NSString *, id<ADJInternalCallback>> *)internalConfigSubscriptions
    logger:(nonnull ADJLogger *)logger
{
    if (adjustConfig == nil) {
        [logger errorClient:@"Cannot create config with null adjust config value"];
        return nil;
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull appTokenResult =
        [ADJNonEmptyString instanceFromString:adjustConfig.appToken];
    if (appTokenResult.fail != nil) {
        [logger errorClient:@"Cannot create config with invalid app token"
                 resultFail:appTokenResult.fail];
        return nil;
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull environmentResult =
        [ADJNonEmptyString instanceFromString:adjustConfig.environment];
    if (environmentResult.fail != nil) {
        [logger errorClient:@"Cannot create config with invalid environment"
                 resultFail:environmentResult.fail];
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
          actualStringValue:environmentResult.value.stringValue];
        return nil;
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull defaultTrackerResult =
        [ADJNonEmptyString instanceFromString:adjustConfig.defaultTracker];
    if (defaultTrackerResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot set invalid default tracker"
                  resultFail:defaultTrackerResult.fail];
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

    ADJResult<ADJNonEmptyString *> *_Nonnull dataResidencyResult =
        [ADJClientConfigData dataResidencyWithClientData:adjustConfig.dataResidency];
    if (dataResidencyResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot set invalid data residency"
                  resultFail:dataResidencyResult.fail];
    }
    AdjustDataResidency _Nullable dataResidency =
        dataResidencyResult.value != nil ? dataResidencyResult.value.stringValue : nil;

    ADJResult<ADJNonEmptyString *> *_Nonnull externalDeviceIdResult =
        [ADJNonEmptyString instanceFromString:adjustConfig.externalDeviceId];
    if (externalDeviceIdResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot set invalid external device id"
                  resultFail:externalDeviceIdResult.fail];
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull customEndpointUrlResult =
        [ADJNonEmptyString instanceFromString:adjustConfig.customEndpointUrl];
    if (customEndpointUrlResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot set invalid custom endpoint url"
                  resultFail:customEndpointUrlResult.fail];
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull customEndpointPublicKeyHashResult =
        [ADJNonEmptyString instanceFromString:adjustConfig.customEndpointPublicKeyHash];
    if (customEndpointPublicKeyHashResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot set invalid custom endpoint public key hash"
                  resultFail:customEndpointPublicKeyHashResult.fail];
    }

    ADJClientCustomEndpointData *_Nullable clientCustomEndpointData = nil;
    if (customEndpointPublicKeyHashResult.value != nil && customEndpointUrlResult.value == nil) {
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

    ADJResult<ADJNonNegativeInt *> *_Nonnull eventIdDeduplicationMaxCapacityResult =
        [ADJNonNegativeInt
         instanceFromIntegerNumber:adjustConfig.eventIdDeduplicationMaxCapacityNumberInt];
    if (eventIdDeduplicationMaxCapacityResult.failNonNilInput != nil) {
        [logger noticeClient:@"Cannot configure invalid max deduplication event capacity"
                  resultFail:eventIdDeduplicationMaxCapacityResult.fail];
    }
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
            eventIdDeduplicationMaxCapacity:eventIdDeduplicationMaxCapacityResult.value
            adjustIdentifierSubscriber:adjustConfig.adjustIdentifierSubscriber
            adjustAttributionSubscriber:adjustConfig.adjustAttributionSubscriber
            adjustLogSubscriber:adjustConfig.adjustLogSubscriber
            internalConfigSubscriptions:internalConfigSubscriptions];
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
    adjustIdentifierSubscriber:
        (nonnull id<ADJAdjustIdentifierSubscriber>)adjustIdentifierSubscriber
    adjustAttributionSubscriber:
        (nullable id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber
    adjustLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustLogSubscriber
    internalConfigSubscriptions:
        (nullable NSDictionary<NSString *, id<ADJInternalCallback>> *)internalConfigSubscriptions
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
    _adjustIdentifierSubscriber = adjustIdentifierSubscriber;
    _adjustAttributionSubscriber = adjustAttributionSubscriber;
    _adjustLogSubscriber = adjustLogSubscriber;
    _internalConfigSubscriptions = internalConfigSubscriptions;
    
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

+ (nonnull ADJResult<NSRegularExpression *> *)domainValidationRegex {
    static dispatch_once_t onceExcludedRegexInstanceToken;
    static ADJResult<NSRegularExpression *> *result;

    dispatch_once(&onceExcludedRegexInstanceToken, ^{
        NSError *error = nil;

        NSRegularExpression *_Nullable regex =
            [NSRegularExpression regularExpressionWithPattern:kDomainValidationRegexString
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];

        if (regex != nil) {
            result = [ADJResult okWithValue:regex];
        } else {
            result = [ADJResult failWithMessage:
                      @"NSRegularExpression regularExpression with excluded deeplinks pattern"
                      " returned nil"
                      error:error];
        }
    });

    if (result == nil) {
        return [ADJResult failWithMessage:
                @"NSRegularExpression regularExpression with excluded deeplinks pattern"
                " result was not set in dispatch_once"];
    }

    return result;
}

+ (nullable ADJNonEmptyString *)
    urlStrategyDomainWithClientData:(nullable NSString *)urlStrategyDomain
    logger:(nonnull ADJLogger *)logger
{
    ADJResult<ADJNonEmptyString *> *_Nonnull urlStrategyDomainResult =
        [ADJNonEmptyString instanceFromString:urlStrategyDomain];

    if (urlStrategyDomainResult.value == nil) {
        if (urlStrategyDomainResult.failNonNilInput != nil) {
            [logger noticeClient:@"Cannot set invalid URL strategy domain"
                      resultFail:urlStrategyDomainResult.fail];
        }
        return nil;
    }

    ADJResult<NSRegularExpression *> *_Nonnull domainValidationRegexResult =
        [ADJClientConfigData domainValidationRegex];

    if (domainValidationRegexResult.fail != nil) {
        [logger noticeClient:@"Cannot validate URL strategy domain with invalid regex"
                 resultFail:domainValidationRegexResult.fail];
        [logger debugDev:@"Could not create domain validation regex"
              resultFail:domainValidationRegexResult.fail
               issueType:ADJIssueLogicError];
        return nil;
    }

    if (! [ADJUtilF matchesWithString:urlStrategyDomainResult.value.stringValue
                                regex:domainValidationRegexResult.value])
    {
        [logger noticeClient:@"Cannot use URL strategy domain that does not match expected pattern"
                         key:@"URL strategy domain"
                 stringValue:urlStrategyDomainResult.value.stringValue];
        return nil;
    }

    return urlStrategyDomainResult.value;
}

+ (nonnull ADJResult<ADJNonEmptyString *> *)
    dataResidencyWithClientData:(nullable NSString *)dataResidency
{
    ADJResult<ADJNonEmptyString *> *_Nonnull dataResidencyResult =
        [ADJNonEmptyString instanceFromString:dataResidency];
    if (dataResidencyResult.fail != nil) {
        return dataResidencyResult;
    }

    if ([AdjustDataResidencyEU isEqualToString:dataResidencyResult.value.stringValue]
        || [AdjustDataResidencyTR isEqualToString:dataResidencyResult.value.stringValue]
        || [AdjustDataResidencyUS isEqualToString:dataResidencyResult.value.stringValue])
    {
        return dataResidencyResult;
    }

    return [ADJResult failWithMessage:@"Cannot use data residency that is not expected"
                                  key:@"data residency"
                          stringValue:dataResidencyResult.value.stringValue];
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
