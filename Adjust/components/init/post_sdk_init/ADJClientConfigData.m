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
 @property (nullable, readonly, strong, nonatomic) ADJClientCustomEndpointData *clientCustomEndpointData;
 @property (readonly, assign, nonatomic) BOOL doNotOpenDeferredDeeplink;
 @property (readonly, assign, nonatomic) BOOL doNotReadAsaAttribution;
 @property (readonly, assign, nonatomic) BOOL canSendInBackground;
 @property (nullable, readonly, strong, nonatomic) ADJNonNegativeInt *eventIdDeduplicationMaxCapacity;
 @property (nullable, readonly, strong, nonatomic) id<ADJAdjustAttributionSubscriber> adjustAttributionSubscriber;
 @property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> adjustLogSubscriber;
 */

@implementation ADJClientConfigData
#pragma mark Instantiation
+ (nullable instancetype)instanceFromClientWithAdjustConfig:(nullable ADJAdjustConfig *)adjustConfig
                                                     logger:(nonnull ADJLogger *)logger {
    if (adjustConfig == nil) {
        [logger errorClient:@"Cannot create config with null adjust config value"];
        return nil;
    }
    
    ADJNonEmptyString *_Nullable appToken =
    [ADJNonEmptyString instanceFromString:adjustConfig.appToken
                        sourceDescription:@"app token"
                                   logger:logger];
    
    if (appToken == nil) {
        [logger errorClient:@"Cannot create config with invalid app token value"];
        return nil;
    }
    
    ADJNonEmptyString *_Nullable environment =
    [ADJNonEmptyString instanceFromString:adjustConfig.environment
                        sourceDescription:@"environment"
                                   logger:logger];
    
    if (environment == nil) {
        [logger errorClient:@"Cannot create config with invalid environment value"];
        return nil;
    }
    
    ADJNonEmptyString *_Nullable defaultTracker =
    [ADJNonEmptyString instanceFromOptionalString:adjustConfig.defaultTracker
                                sourceDescription:@"default tracker"
                                           logger:logger];
    
    BOOL isSandboxEnvironment = [environment.stringValue isEqualToString:ADJEnvironmentSandbox];
    BOOL isProductionEnvironment =
        [environment.stringValue isEqualToString:ADJEnvironmentProduction];
    
    if (! isSandboxEnvironment && ! isProductionEnvironment) {
        [logger errorClient:@"Cannot create config with unexpected environment value"
              expectedValue:[NSString stringWithFormat:@"%@ or %@",
                             ADJEnvironmentSandbox, ADJEnvironmentProduction]
                actualValue:environment.stringValue];
        return nil;
    }

    BOOL doNotLogAny =
        adjustConfig.doNotLogAnyNumberBool != nil
        && adjustConfig.doNotLogAnyNumberBool.boolValue;
    
    BOOL doLogAll =
        adjustConfig.doLogAllNumberBool != nil
        && adjustConfig.doLogAllNumberBool.boolValue;
    
    ADJNonEmptyString *_Nullable urlStrategyDomain =
    [ADJNonEmptyString instanceFromOptionalString:adjustConfig.urlStrategyDomain
                                sourceDescription:@"url strategy domain"
                                           logger:logger];
    if (urlStrategyDomain != nil) {
        NSString *domainValidationRegexString = @"^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z]{2,6}";
        NSError *error = nil;
        NSRegularExpression *domainValidationRegex =
        [NSRegularExpression regularExpressionWithPattern:domainValidationRegexString
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:&error];
        if (domainValidationRegex == nil) {
            [logger debugDev:@"Cannot create domain validation regex"
                     nserror:error
                   issueType:ADJIssueLogicError];
            urlStrategyDomain = nil;
        } else {
            if (! [ADJUtilF matchesWithString:urlStrategyDomain.stringValue
                                        regex:domainValidationRegex])  {
                [logger errorClient:@"Cannot use URL strategy domain that does not match expected pattern"
                                key:@"url strategy domain"
                              value:adjustConfig.urlStrategyDomain];
                urlStrategyDomain = nil;
            }
        }
    }

    AdjustDataResidency _Nullable dataResidency = nil;
    if (adjustConfig.dataResidency != nil && adjustConfig.dataResidency.length > 0) {

        if ([AdjustDataResidencyEU isEqualToString:adjustConfig.dataResidency]
            || [AdjustDataResidencyTR isEqualToString:adjustConfig.dataResidency]
            || [AdjustDataResidencyUS isEqualToString:adjustConfig.dataResidency]) {
            dataResidency = adjustConfig.dataResidency;
        } else {
            [logger noticeClient:@"Cannot set unknown data residency"
                             key:@"value" value:adjustConfig.dataResidency];
        }
    }

    ADJNonEmptyString *_Nullable customEndpointUrl =
    [ADJNonEmptyString instanceFromOptionalString:adjustConfig.customEndpointUrl
                                sourceDescription:@"custom endpoint url"
                                           logger:logger];
    
    ADJNonEmptyString *_Nullable customEndpointPublicKeyHash =
    [ADJNonEmptyString instanceFromOptionalString:adjustConfig.customEndpointPublicKeyHash
                                sourceDescription:@"custom endpoint public key hash"
                                           logger:logger];
    
    ADJClientCustomEndpointData *_Nullable clientCustomEndpointData = nil;
    if (customEndpointPublicKeyHash != nil && customEndpointUrl == nil) {
        [logger noticeClient:@"Cannot configure certificate pinning"
         " without a custom endpoint"];
    } else if (customEndpointUrl != nil) {
        clientCustomEndpointData = [[ADJClientCustomEndpointData alloc] initWithUrl:customEndpointUrl
                                                                      publicKeyHash:customEndpointPublicKeyHash];
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
    [ADJNonNegativeInt instanceFromOptionalIntegerNumber:adjustConfig.eventIdDeduplicationMaxCapacityNumberInt
                                                  logger:logger];
    
    return [[self alloc] initWithAppToken:appToken
     isSandboxEnvironmentOrElseProduction:isSandboxEnvironment
                           defaultTracker:defaultTracker
                                 doLogAll:doLogAll
                              doNotLogAny:doNotLogAny
                    urlStrategyBaseDomain:urlStrategyDomain
                            dataResidency:dataResidency
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
- (nonnull instancetype)initWithAppToken:(nonnull ADJNonEmptyString *)appToken
    isSandboxEnvironmentOrElseProduction:(BOOL)isSandboxEnvironmentOrElseProduction
                          defaultTracker:(nullable ADJNonEmptyString *)defaultTracker
                                doLogAll:(BOOL)doLogAll
                             doNotLogAny:(BOOL)doNotLogAny
                   urlStrategyBaseDomain:(nullable ADJNonEmptyString *)urlStrategybaseDomain
                           dataResidency:(nullable AdjustDataResidency)dataResidency
                clientCustomEndpointData:(nullable ADJClientCustomEndpointData *)clientCustomEndpointData
               doNotOpenDeferredDeeplink:(BOOL)doNotOpenDeferredDeeplink
                 doNotReadAsaAttribution:(BOOL)doNotReadAsaAttribution
                     canSendInBackground:(BOOL)canSendInBackground
         eventIdDeduplicationMaxCapacity:(nullable ADJNonNegativeInt *)eventIdDeduplicationMaxCapacity
             adjustAttributionSubscriber:
(nullable id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber
                     adjustLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustLogSubscriber {
    self = [super init];
    
    _appToken = appToken;
    _isSandboxEnvironmentOrElseProduction = isSandboxEnvironmentOrElseProduction;
    _defaultTracker = defaultTracker;
    _doLogAll = doLogAll;
    _doNotLogAny = doNotLogAny;
    _urlStrategyBaseDomain = urlStrategybaseDomain;
    _dataResidency = dataResidency;
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
        sandboxEnvironment = [[ADJNonEmptyString alloc] initWithConstStringValue:ADJEnvironmentSandbox];
    });
    return sandboxEnvironment;
}

+ (nonnull ADJNonEmptyString *)productionEnvironment {
    static dispatch_once_t productionEnvironmentToken;
    static id productionEnvironment;
    dispatch_once(&productionEnvironmentToken, ^{
        productionEnvironment = [[ADJNonEmptyString alloc] initWithConstStringValue:ADJEnvironmentProduction];
    });
    return productionEnvironment;
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

