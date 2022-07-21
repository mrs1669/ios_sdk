//
//  ADJClientConfigData.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientConfigData.h"

#import "ADJAdjustLogMessageData.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *appToken;
 @property (readonly, assign, nonatomic) BOOL isSandboxEnvironmentOrElseProduction;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *defaultTracker;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *logLevel;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *urlStrategy;
 @property (nullable, readonly, strong, nonatomic)
     ADJClientCustomEndpointData *clientCustomEndpointData;
 @property (readonly, assign, nonatomic) BOOL doNotOpenDeferredDeeplink;
 @property (readonly, assign, nonatomic) BOOL doNotReadAsaAttribution;
 @property (readonly, assign, nonatomic) BOOL canSendInBackground;
 @property (nullable, readonly, strong, nonatomic)
     ADJNonNegativeInt *eventIdDeduplicationMaxCapacity;
 @property (nullable, readonly, strong, nonatomic)
     id<ADJAdjustAttributionSubscriber> adjustAttributionSubscriber;
 @property (nullable, readonly, strong, nonatomic)
     id<ADJAdjustLogSubscriber> adjustLogSubscriber;
 */

@implementation ADJClientConfigData
#pragma mark Instantiation
+ (nullable instancetype)
    instanceFromClientWithAdjustConfig:(nullable ADJAdjustConfig *)adjustConfig
    logger:(nonnull ADJLogger *)logger
{
    if (adjustConfig == nil) {
        [logger error:@"Cannot create config with null adjust config value"];
        return nil;
    }

    ADJNonEmptyString *_Nullable appToken =
        [ADJNonEmptyString instanceFromString:adjustConfig.appToken
                             sourceDescription:@"app token"
                                        logger:logger];

    if (appToken == nil) {
        [logger error:@"Cannot create config with invalid app token value"];
        return nil;
    }

    ADJNonEmptyString *_Nullable environment =
        [ADJNonEmptyString instanceFromString:adjustConfig.environment
                             sourceDescription:@"environment"
                                        logger:logger];

    if (environment == nil) {
        [logger error:@"Cannot create config with invalid environment value"];
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
        [logger error:@"Cannot create config with environment value %@,"
            " different than expected %@ or %@",
            environment, ADJEnvironmentSandbox, ADJEnvironmentProduction];
        return nil;
    }

    ADJNonEmptyString *_Nullable loglevel = nil;
    if (adjustConfig.logLevel != nil) {
        if ([ADJAdjustLogLevelDebug isEqualToString:adjustConfig.logLevel]
            || [ADJAdjustLogLevelInfo isEqualToString:adjustConfig.logLevel]
            || [ADJAdjustLogLevelError isEqualToString:adjustConfig.logLevel])
        {
            loglevel = [[ADJNonEmptyString alloc]
                            initWithConstStringValue:adjustConfig.logLevel];
        } else {
            [logger error:@"Cannot set log level with unknown value: %@", adjustConfig.logLevel];
        }
    }

    ADJNonEmptyString *_Nullable urlStrategy = nil;
    if (adjustConfig.urlStrategy != nil) {
        if ([ADJUrlStategyChina isEqualToString:adjustConfig.urlStrategy]
            || [ADJUrlStategyIndia isEqualToString:adjustConfig.urlStrategy])
        {
            urlStrategy = [[ADJNonEmptyString alloc]
                                initWithConstStringValue:adjustConfig.urlStrategy];
        } else {
            [logger error:@"Cannot set url strategy with unknown value: %@",
                adjustConfig.urlStrategy];
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
    if (customEndpointPublicKeyHash != nil
        && customEndpointUrl == nil)
    {
        [logger error:@"Cannot configure certificate pinning"
            " without a custom endpoint"];
    } else if (customEndpointUrl != nil) {
        clientCustomEndpointData = [[ADJClientCustomEndpointData alloc]
                                        initWithUrl:customEndpointUrl
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
        [ADJNonNegativeInt
            instanceFromOptionalIntegerNumber:adjustConfig.eventIdDeduplicationMaxCapacityNumberInt
            logger:logger];

    return [[self alloc] initWithAppToken:appToken
     isSandboxEnvironmentOrElseProduction:isSandboxEnvironment
                           defaultTracker:defaultTracker
                                 logLevel:loglevel
                              urlStrategy:urlStrategy
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
    logLevel:(nullable ADJNonEmptyString *)logLevel
    urlStrategy:(nullable ADJNonEmptyString *)urlStrategy
    clientCustomEndpointData:(nullable ADJClientCustomEndpointData *)clientCustomEndpointData
    doNotOpenDeferredDeeplink:(BOOL)doNotOpenDeferredDeeplink
    doNotReadAsaAttribution:(BOOL)doNotReadAsaAttribution
    canSendInBackground:(BOOL)canSendInBackground
    eventIdDeduplicationMaxCapacity:
        (nullable ADJNonNegativeInt *)eventIdDeduplicationMaxCapacity
    adjustAttributionSubscriber:
        (nullable id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber
    adjustLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustLogSubscriber
{
    self = [super init];

    _appToken = appToken;
    _isSandboxEnvironmentOrElseProduction = isSandboxEnvironmentOrElseProduction;
    _defaultTracker = defaultTracker;
    _logLevel = logLevel;
    _urlStrategy = urlStrategy;
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
                      publicKeyHash:(nullable ADJNonEmptyString *)publicKeyHash
{
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
