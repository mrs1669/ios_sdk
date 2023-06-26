//
//  ADJSdkPackageUrlBuilder.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkPackageUrlBuilder.h"

#import "ADJAdjustConfig.h"
#import "ADJConstantsParam.h"
#import "ADJGdprForgetPackageData.h"
#import "ADJBillingSubscriptionPackageData.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kBaseUrl = @"https://app.adjust.com";
static NSString *const kGdprUrl = @"https://gdpr.adjust.com";
static NSString *const kSubscriptionUrl = @"https://subscription.adjust.com";

static NSString *const kBaseUrlIndia = @"https://app.adjust.net.in";
static NSString *const kGdprUrlIndia = @"https://gdpr.adjust.net.in";
static NSString *const kSubscriptionUrlIndia = @"https://subscription.adjust.net.in";

static NSString *const kBaseUrlWorld = @"https://app.adjust.world";
static NSString *const kGdprUrlWorld = @"https://gdpr.adjust.world";
static NSString *const kSubscriptionUrlWorld = @"https://subscription.adjust.world";

static NSString *const kBaseUrlStrategy = @"https://app.%@";
static NSString *const kGdprUrlStrategy = @"https://gdpr.%@";
static NSString *const kSubscriptionUrlStrategy = @"https://subscription.%@";

static NSString *const kBaseUrlEU = @"https://app.eu.adjust.com";
static NSString *const kGdprUrlEU = @"https://gdpr.eu.adjust.com";
static NSString *const kSubscriptionUrlEU = @"https://subscription.eu.adjust.com";

static NSString *const kBaseUrlTR = @"https://app.tr.adjust.com";
static NSString *const kGdprUrlTR = @"https://gdpr.tr.adjust.com";
static NSString *const kSubscriptionUrlTR = @"https://subscription.tr.adjust.com";

static NSString *const kBaseUrlUS = @"https://app.us.adjust.com";
static NSString *const kGdprUrlUS = @"https://gdpr.us.adjust.com";
static NSString *const kSubscriptionUrlUS = @"https://subscription.us.adjust.com";

@interface ADJSdkPackageUrlBuilder ()
#pragma mark - Injected dependencies
@property (nullable, readonly, strong, nonatomic) NSString *urlOverwrite;
@property (nullable, readonly, strong, nonatomic) NSString *extraPath;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *clientCustomEndpointUrl;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) NSArray<NSString *> *baseUrlChoicesArray;
@property (nonnull, readonly, strong, nonatomic) NSArray<NSString *> *gdprUrlChoicesArray;
@property (nonnull, readonly, strong, nonatomic) NSArray<NSString *> *subscriptionUrlChoicesArray;
//@property (readwrite, assign, nonatomic) BOOL wasLastAttemptSuccess;
@property (readwrite, assign, nonatomic) NSUInteger choiceIndex;
@property (readwrite, assign, nonatomic) NSUInteger startingChoiceIndex;

@end

@implementation ADJSdkPackageUrlBuilder
#pragma mark Instantiation
- (nonnull instancetype)initWithUrlOverwrite:(nullable NSString *)urlOverwrite
                                   extraPath:(nullable NSString *)extraPath
                       urlStrategyBaseDomain:(nullable ADJNonEmptyString *)urlStrategyBaseDomain
                               dataResidency:(nullable AdjustDataResidency)dataResidency
                     clientCustomEndpointUrl:(nullable ADJNonEmptyString *)clientCustomEndpointUrl
{
    self = [super init];

    _urlOverwrite = urlOverwrite;
    _extraPath = extraPath;
    _clientCustomEndpointUrl = clientCustomEndpointUrl;
    
    NSString *_Nullable urlStrategyDomain =
    urlStrategyBaseDomain != nil ? urlStrategyBaseDomain.stringValue : nil;

    _baseUrlChoicesArray = [[self class] baseUrlChoicesWithUrlStrategy:urlStrategyDomain
                                                         dataResidency:dataResidency];
    
    _gdprUrlChoicesArray = [[self class] gdprUrlChoicesWithUrlStrategy:urlStrategyDomain
                                                         dataResidency:dataResidency];
    
    _subscriptionUrlChoicesArray = [[self class] subscriptionUrlChoicesWithUrlStrategy:urlStrategyDomain
                                                                         dataResidency:dataResidency];

    _clientCustomEndpointUrl = clientCustomEndpointUrl;
    
    //_wasLastAttemptSuccess = NO;
    
    _choiceIndex = 0;
    
    _startingChoiceIndex = 0;
    
    return self;
}

#pragma mark - Private constructors
+ (nonnull NSArray<NSString *> *)baseUrlChoicesWithUrlStrategy:(nullable NSString *)urlStrategyDomain
                                                 dataResidency:(nullable AdjustDataResidency)dataResidency {

    if ([AdjustDataResidencyEU isEqual:dataResidency]) {
        return @[kBaseUrlEU];
    }

    if ([AdjustDataResidencyTR isEqual:dataResidency]) {
        return @[kBaseUrlTR];
    }

    if ([AdjustDataResidencyUS isEqual:dataResidency]) {
        return @[kBaseUrlUS];
    }

    if (urlStrategyDomain != nil) {
        NSString *baseUrlStrategy = [NSString stringWithFormat:kBaseUrlStrategy, urlStrategyDomain];
        return @[baseUrlStrategy, kBaseUrl];
    }

    return @[kBaseUrl, kBaseUrlWorld, kBaseUrlIndia];
}

+ (nonnull NSArray<NSString *> *)gdprUrlChoicesWithUrlStrategy:(nullable NSString *)urlStrategyDomain
                                                 dataResidency:(nullable AdjustDataResidency)dataResidency {

    if ([AdjustDataResidencyEU isEqual:dataResidency]) {
        return @[kGdprUrlEU];
    }

    if ([AdjustDataResidencyTR isEqual:dataResidency]) {
        return @[kGdprUrlTR];
    }

    if ([AdjustDataResidencyUS isEqual:dataResidency]) {
        return @[kGdprUrlUS];
    }

    if (urlStrategyDomain != nil) {
        NSString *gdprUrlStrategy = [NSString stringWithFormat:kGdprUrlStrategy, urlStrategyDomain];
        return @[gdprUrlStrategy, kGdprUrl];
    }

    return @[kGdprUrl, kGdprUrlWorld, kGdprUrlIndia];
}

+ (nonnull NSArray<NSString *> *)subscriptionUrlChoicesWithUrlStrategy:(nullable NSString *)urlStrategyDomain
                                                         dataResidency:(nullable AdjustDataResidency)dataResidency {

    if ([AdjustDataResidencyEU isEqual:dataResidency]) {
        return @[kSubscriptionUrlEU];
    }

    if ([AdjustDataResidencyTR isEqual:dataResidency]) {
        return @[kSubscriptionUrlTR];
    }

    if ([AdjustDataResidencyUS isEqual:dataResidency]) {
        return @[kSubscriptionUrlUS];
    }

    if (urlStrategyDomain != nil) {
        NSString *subUrlStrategy = [NSString stringWithFormat:kSubscriptionUrlStrategy, urlStrategyDomain];
        return @[subUrlStrategy, kSubscriptionUrl];
    }

    return @[kSubscriptionUrl, kSubscriptionUrlWorld, kSubscriptionUrlIndia];
}

#pragma mark Public API
- (nonnull NSString *)targetUrlWithPath:(nonnull NSString *)path
                      sendingParameters:(nonnull ADJStringMapBuilder *)sendingParameters {
    NSString *_Nonnull urlByPath = [self chooseUrlWithPath:path];
    
    NSString *_Nonnull url = [self chooseUrlByPriorityWithUrlPath:urlByPath
                                                sendingParameters:sendingParameters];
    
    // extra path, if present, has the format '/X/Y'
    if (self.extraPath != nil) {
        return [NSString stringWithFormat:@"%@%@", url, self.extraPath];
    }
    
    return url;
}

- (BOOL)shouldRetryAfterNetworkFailure {
    NSUInteger nextChoiceIndex = (self.choiceIndex + 1) % self.baseUrlChoicesArray.count;
    self.choiceIndex = nextChoiceIndex;
    
    //self.wasLastAttemptSuccess = NO;
    
    BOOL nextChoiceHasNotReturnedToStartingChoice = nextChoiceIndex != self.startingChoiceIndex;
    
    return nextChoiceHasNotReturnedToStartingChoice;
}

- (void)resetAfterNetworkNotFailing {
    self.startingChoiceIndex = self.choiceIndex;
    
    //self.wasLastAttemptSuccess = YES;
}

- (nonnull NSString *)defaultTargetUrl {
    if (self.urlOverwrite != nil) {
        return self.urlOverwrite;
    }
    
    if (self.clientCustomEndpointUrl != nil) {
        return self.clientCustomEndpointUrl.stringValue;
    }
    
    return [self.baseUrlChoicesArray objectAtIndex:0];
}

- (NSUInteger)urlCountWithPath:(nonnull NSString *)path {
    if ([path isEqualToString:ADJGdprForgetPackageDataPath]) {
        return self.gdprUrlChoicesArray.count;
    }

    if ([path isEqualToString:ADJBillingSubscriptionPackageDataPath]) {
        return self.subscriptionUrlChoicesArray.count;
    }

    return self.baseUrlChoicesArray.count;
}

#pragma mark Internal Methods
- (nonnull NSString *)chooseUrlWithPath:(nonnull NSString *)path {
    if ([path isEqualToString:ADJGdprForgetPackageDataPath]) {
        return [self.gdprUrlChoicesArray objectAtIndex:self.choiceIndex];
    }
    
    if ([path isEqualToString:ADJBillingSubscriptionPackageDataPath]) {
        return [self.subscriptionUrlChoicesArray objectAtIndex:self.choiceIndex];
    }
    return [self.baseUrlChoicesArray objectAtIndex:self.choiceIndex];
}

- (nonnull NSString *)chooseUrlByPriorityWithUrlPath:(nonnull NSString *)urlByPath
                                   sendingParameters:(nonnull ADJStringMapBuilder *)sendingParameters {
    if (self.urlOverwrite != nil) {
        [sendingParameters
         addPairWithConstValue:urlByPath
         key:ADJParamTestServerAdjustEndPointKey];
        
        if (self.clientCustomEndpointUrl != nil) {
            [sendingParameters
             addPairWithValue:self.clientCustomEndpointUrl
             key:ADJParamTestServerCustomEndPointKey];
        }
        
        return self.urlOverwrite;
    }
    
    if (self.clientCustomEndpointUrl != nil) {
        return self.clientCustomEndpointUrl.stringValue;
    }
    
    return urlByPath;
}

@end
