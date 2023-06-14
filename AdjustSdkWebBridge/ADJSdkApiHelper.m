//
//  ADJSdkApiHelper.m
//  Adjust
//
//  Created by Pedro Silva on 03.05.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJSdkApiHelper.h"

#import "ADJWebBridgeConstants.h"

#import "ADJNonEmptyString.h"
#import "ADJConstants.h"
#import "ADJUtilF.h"
#import "ADJUtilObj.h"
#import "ADJOptionalFails.h"

@interface ADJSdkApiHelper ()

@property (nonnull, readonly, strong, nonatomic) ADJWebViewCallback *webViewCallback;
@property (nonnull, readonly, strong, nonatomic) ADJLogger *logger;

@end

@implementation ADJSdkApiHelper

- (nonnull instancetype)initWithLogger:(nonnull ADJLogger *)logger
                       webViewCallback:(nonnull ADJWebViewCallback *)webViewCallback
{
    self = [super init];
    _logger = logger;
    _webViewCallback = webViewCallback;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (nonnull ADJAdjustConfig *)
    adjustConfigWithParametersJsonDictionary:
        (nonnull NSDictionary<NSString *, id> *)jsParameters
    instanceIdString:(nonnull NSString *)instanceIdString
{
    NSString *_Nullable appToken =
        [self stringLoggedWithJsParameters:jsParameters
                                       key:ADJWBAppTokenConfigKey
                                      from:ADJWBAdjustConfigName];

    NSString *_Nullable environment =
        [self stringLoggedWithJsParameters:jsParameters
                                       key:ADJWBEnvironmentConfigKey
                                      from:ADJWBAdjustConfigName];

    ADJAdjustConfig *_Nonnull adjustConfig = [[ADJAdjustConfig alloc]
                                              initWithAppToken:appToken
                                              environment:environment];

    NSString *_Nullable defaultTracker =
        [self stringLoggedWithJsParameters:jsParameters
                                       key:ADJWBDefaultTrackerConfigKey
                                      from:ADJWBAdjustConfigName];
    if (defaultTracker != nil) {
        [adjustConfig setDefaultTracker:defaultTracker];
    }

    if ([self trueLoggedWithJsParameters:jsParameters
                                     key:ADJWBDoLogAllConfigKey
                                    from:ADJWBAdjustConfigName])
    {
        [adjustConfig doLogAll];
    }

    if ([self trueLoggedWithJsParameters:jsParameters
                                     key:ADJWBDoNotLogAnyConfigKey
                                    from:ADJWBAdjustConfigName])
    {
        [adjustConfig doNotLogAny];
    }

    NSString *_Nullable urlStrategy =
        [self stringLoggedWithJsParameters:jsParameters
                                       key:ADJWBUrlStrategyConfigKey
                                      from:ADJWBAdjustConfigName];
    if (urlStrategy != nil) {
        [adjustConfig setDefaultTracker:urlStrategy];
    }

    NSString *_Nullable customEndpoint =
        [self stringLoggedWithJsParameters:jsParameters
                                       key:ADJWBCustomEndpointUrlConfigKey
                                      from:ADJWBAdjustConfigName];
    NSString *_Nullable customEndpointPublicKeyHash =
        [self stringLoggedWithJsParameters:jsParameters
                                       key:ADJWBCustomEndpointPublicKeyHashConfigKey
                                      from:ADJWBAdjustConfigName];
    if (customEndpoint != nil || customEndpointPublicKeyHash != nil) {
        [adjustConfig setCustomEndpointWithUrl:customEndpoint
                      optionalPublicKeyKeyHash:customEndpointPublicKeyHash];
    }

    if ([self trueLoggedWithJsParameters:jsParameters
                                     key:ADJWBDoNotOpenDeferredDeeplinkConfigKey
                                    from:ADJWBAdjustConfigName])
    {
        [adjustConfig preventOpenDeferredDeeplink];
    }

    if ([self trueLoggedWithJsParameters:jsParameters
                                     key:ADJWBDoNotReadAppleSearchAdsAttributionConfigKey
                                    from:ADJWBAdjustConfigName])
    {
        [adjustConfig doNotReadAppleSearchAdsAttribution];
    }

    if ([self trueLoggedWithJsParameters:jsParameters
                                     key:ADJWBCanSendInBackgroundConfigKey
                                    from:ADJWBAdjustConfigName])
    {
        [adjustConfig allowSendingFromBackground];
    }

    NSNumber *_Nullable eventIdDeduplicationMaxCapacity =
        [self numberLoggedWithJsParameters:jsParameters
                                       key:ADJWBEventIdDeduplicationMaxCapacityConfigKey
                                      from:ADJWBAdjustConfigName];
    if (eventIdDeduplicationMaxCapacity != nil) {
        [adjustConfig setEventIdDeduplicationMaxCapacity:eventIdDeduplicationMaxCapacity.intValue];
    }

    ADJResult<NSString *> *_Nonnull adjustIdentifierSubscriberIdResult =
        [ADJSdkApiHelper
         functionIdWithJsParameters:jsParameters
         key:ADJWBAdjustIdentifierSubscriberCallbackConfigKey];
    if (adjustIdentifierSubscriberIdResult.failNonNilInput != nil) {
        [self.logger
         debugDev:
             @"Could not parse JS field for adjust config adjust identifier subscription callback id"
         resultFail:adjustIdentifierSubscriberIdResult.fail
         issueType:ADJIssueNonNativeIntegration];
    }
    if (adjustIdentifierSubscriberIdResult.value != nil) {
        [adjustConfig setAdjustIdentifierSubscriber:
            [self.webViewCallback
             adjustIdentifierSubscriberCallbackWithId:adjustIdentifierSubscriberIdResult.value
             instanceIdString:instanceIdString]];
    }

    return adjustConfig;
}

- (nullable NSDictionary<NSString *, id<ADJInternalCallback>> *)
    extractInternalConfigSubscriptionsWithJsParameters:
        (nonnull NSDictionary<NSString *, id> *)jsParameters
    instanceIdString:(nonnull NSString *)instanceIdString
{
    NSMutableDictionary<NSString *, id<ADJInternalCallback>> *_Nonnull subscriptionsMap =
        [[NSMutableDictionary alloc] init];

    ADJResult<NSString *> *_Nonnull attributionSubscriberIdResult =
        [ADJSdkApiHelper
         functionIdWithJsParameters:jsParameters
         key:ADJWBAdjustAttributionSubscriberCallbackConfigKey];
    if (attributionSubscriberIdResult.failNonNilInput != nil) {
         [self.logger
          debugDev:
              @"Could not parse JS field for adjust config attribution subscription callback id"
          resultFail:attributionSubscriberIdResult.fail
          issueType:ADJIssueNonNativeIntegration];
    }
    [self.logger debugDev:@"TORMV extractInternalConfigSubscriptionsWithJsParameters"
                     key:@"attributionSubscriberIdResult.value != nil"
             stringValue:[ADJUtilF boolFormat:attributionSubscriberIdResult.value != nil]];

    if (attributionSubscriberIdResult.value != nil) {
        [subscriptionsMap
         setObject:[self.webViewCallback
                    attributionSubscriberInternalCallbackWithId:
                        attributionSubscriberIdResult.value
                    instanceIdString:instanceIdString]
         forKey:ADJInternalAttributionSubscriberV5000Key];
    }

    if (subscriptionsMap.count == 0) {
        return nil;
    }

    return subscriptionsMap;
}

- (nonnull id<ADJAdjustIdentifierCallback>)
    adjustIdentifierGetterCallbackWithJsParameters:
        (nonnull NSDictionary<NSString *, id> *)jsParameters
    instanceIdString:(nonnull NSString *)instanceIdString
{
    ADJResult<NSString *> *_Nonnull adjustIdentifierGetterIdResult =
        [ADJSdkApiHelper functionIdWithJsParameters:jsParameters
                                                key:ADJWBAdjustIdentifierAsyncGetterCallbackKey];
    if (adjustIdentifierGetterIdResult.wasInputNil) {
        [self.logger
         debugDev:@"Could not find JS field for adjust identifier getter callback id"
         issueType:ADJIssueNonNativeIntegration];
       return nil;
    }
    if (adjustIdentifierGetterIdResult.fail != nil) {
         [self.logger
          debugDev:@"Could not parse JS field for adjust identifier getter callback id"
          resultFail:adjustIdentifierGetterIdResult.fail
          issueType:ADJIssueNonNativeIntegration];
        return nil;
    }

    return [self.webViewCallback
            adjustIdentifierGetterCallbackWithId:adjustIdentifierGetterIdResult.value
            instanceIdString:instanceIdString];
}

- (nullable id<ADJInternalCallback>)
    attributionGetterInternalCallbackWithJsParameters:
        (nonnull NSDictionary<NSString *, id> *)jsParameters
    instanceIdString:(nonnull NSString *)instanceIdString
{
    ADJResult<NSString *> *_Nonnull attributionGetterIdResult =
        [ADJSdkApiHelper functionIdWithJsParameters:jsParameters
                                                key:ADJWBAdjustAttributionAsyncGetterCallbackKey];
    if (attributionGetterIdResult.wasInputNil) {
        [self.logger
         debugDev:@"Could not find JS field for attribution getter callback id"
         issueType:ADJIssueNonNativeIntegration];
       return nil;
    }
    if (attributionGetterIdResult.fail != nil) {
         [self.logger
          debugDev:@"Could not parse JS field for attribution getter callback id"
          resultFail:attributionGetterIdResult.fail
          issueType:ADJIssueNonNativeIntegration];
        return nil;
    }

    return [self.webViewCallback
            attributionGetterInternalCallbackWithId:attributionGetterIdResult.value
            instanceIdString:instanceIdString];
}

- (nullable id<ADJInternalCallback>)
    deviceIdsGetterInternalCallbackWithJsParameters:
        (nonnull NSDictionary<NSString *, id> *)jsParameters
    instanceIdString:(nonnull NSString *)instanceIdString
{
    ADJResult<NSString *> *_Nonnull deviceIdsGetterIdResult =
        [ADJSdkApiHelper functionIdWithJsParameters:jsParameters
                                                key:ADJWBAdjustDeviceIdsAsyncGetterCallbackKey];
    if (deviceIdsGetterIdResult.wasInputNil) {
        [self.logger
         debugDev:@"Could not find JS field for device ids getter callback id"
         issueType:ADJIssueNonNativeIntegration];
        return nil;
    }
    if (deviceIdsGetterIdResult.fail != nil) {
        [self.logger
         debugDev:@"Could not parse JS field for device ids getter callback id"
         resultFail:deviceIdsGetterIdResult.fail
         issueType:ADJIssueNonNativeIntegration];
        return nil;
    }

    return [self.webViewCallback
            deviceIdsGetterInternalCallbackWithId:deviceIdsGetterIdResult.value
            instanceIdString:instanceIdString];
}

- (nonnull ADJAdjustEvent *)adjustEventWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    NSString *_Nullable eventToken = [self stringLoggedWithJsParameters:jsParameters
                                                                    key:ADJWBEventTokenEventKey
                                                                   from:ADJWBAdjustEventName];

    ADJAdjustEvent *_Nonnull adjustEvent =
        [[ADJAdjustEvent alloc] initWithEventToken:eventToken];

    NSString *_Nullable currency = [self stringLoggedWithJsParameters:jsParameters
                                                                  key:ADJWBCurrencyEventKey
                                                                 from:ADJWBAdjustEventName];
    NSNumber *_Nullable revenueAmountDouble =
        [self numberLoggedWithJsParameters:jsParameters
                                       key:ADJWBRevenueAmountDoubleEventKey
                                      from:ADJWBAdjustEventName];
    if (currency != nil || revenueAmountDouble != nil) {
        [adjustEvent setRevenueWithDoubleNumber:revenueAmountDouble
                                       currency:currency];
    }

    NSString *_Nullable deduplicationId =
        [self stringLoggedWithJsParameters:jsParameters
                                       key:ADJWBDeduplicationIdEventKey
                                      from:ADJWBAdjustEventName];
    if (deduplicationId != nil) {
        [adjustEvent setDeduplicationId:deduplicationId];
    }

    return adjustEvent;
}

- (nullable NSArray *)eventCallbackParameterKeyValueArrayWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return [self
            arrayWithObject:[jsParameters objectForKey:ADJWBCallbackParameterKeyValueArrayEventKey]
            failMessage:@"Could not use event callback parameters"
            optFailMessage:@"Issue while parsing event callback parameters"];
}

- (nullable NSArray *)eventPartnerParameterKeyValueArrayWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return [self
            arrayWithObject:[jsParameters objectForKey:ADJWBPartnerParameterKeyValueArrayEventKey]
            failMessage:@"Could not use event partner parameters"
            optFailMessage:@"Issue while parsing event partner parameters"];
}

- (nonnull ADJAdjustLaunchedDeeplink *)adjustLaunchedDeeplinkWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    ADJResult<NSString *> *_Nonnull urlStringResult =
        [ADJSdkApiHelper stringWithJsParameters:jsParameters key:ADJWBUrlStringKey];
    if (urlStringResult.failNonNilInput != nil) {
        [self.logger debugDev:@"Could not parse lauched deeplink url string field"
                   resultFail:urlStringResult.fail
                    issueType:ADJIssueNonNativeIntegration];
    }

    return [[ADJAdjustLaunchedDeeplink alloc] initWithString:urlStringResult.value];
}

- (nonnull ADJAdjustPushToken *)adjustPushTokenWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    ADJResult<NSString *> *_Nonnull pushTokenStringResult =
        [ADJSdkApiHelper stringWithJsParameters:jsParameters key:ADJWBPushTokenStringKey];
    if (pushTokenStringResult.failNonNilInput != nil) {
        [self.logger debugDev:@"Could not parse push token string field"
                   resultFail:pushTokenStringResult.fail
                    issueType:ADJIssueNonNativeIntegration];
    }

    return [[ADJAdjustPushToken alloc] initWithStringPushToken:pushTokenStringResult.value];
}

- (nonnull ADJAdjustThirdPartySharing *)adjustThirdPartySharingWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    ADJAdjustThirdPartySharing *_Nonnull adjustTPS = [[ADJAdjustThirdPartySharing alloc] init];

    NSNumber *_Nullable enabledOrElseDisabledSharingNumberBool =
        [self booleanLoggedWithJsParameters:jsParameters
                                        key:ADJWBEnabledOrElseDisabledSharingTPSKey
                                       from:ADJWBAdjustThirdPartySharingName];

    if (enabledOrElseDisabledSharingNumberBool != nil) {
        if (enabledOrElseDisabledSharingNumberBool.boolValue) {
            [adjustTPS enableThirdPartySharing];
        } else {
            [adjustTPS disableThirdPartySharing];
        }
    }

    return adjustTPS;
}

- (nullable NSArray *)tpsGranulaOptionsByNameArrayWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return [self
            arrayWithObject:[jsParameters objectForKey:ADJWBGranularOptionsByNameArrayTPSKey]
            failMessage:@"Could not use third party sharing granular options"
            optFailMessage:@"Issue while parsing third party sharing granular options parameters"];
}

- (nullable NSArray *)tpsPartnerSharingSettingsByNameArrayWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return [self
            arrayWithObject:[jsParameters objectForKey:ADJWBPartnerSharingSettingsByNameArrayTPSKey]
            failMessage:@"Could not use third party sharing partner sharing settings"
            optFailMessage:
                @"Issue while parsing third party sharing partner sharing settings parameters"];
}

- (nonnull ADJAdjustAdRevenue *)adjustAdRevenueWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    NSString *_Nullable source = [self stringLoggedWithJsParameters:jsParameters
                                                                key:ADJWBSourceAdRevenueKey
                                                               from:ADJWBAdjustAdRevenueName];

    ADJAdjustAdRevenue *_Nonnull adjustAdRevenue =
        [[ADJAdjustAdRevenue alloc] initWithSource:source];

    NSString *_Nullable currency = [self stringLoggedWithJsParameters:jsParameters
                                                                  key:ADJWBCurrencyAdRevenueKey
                                                                 from:ADJWBAdjustAdRevenueName];
    NSNumber *_Nullable revenueAmountDouble =
        [self numberLoggedWithJsParameters:jsParameters
                                       key:ADJWBRevenueAmountDoubleAdRevenueKey
                                      from:ADJWBAdjustAdRevenueName];
    if (currency != nil || revenueAmountDouble != nil) {
        [adjustAdRevenue setRevenueWithDoubleNumber:revenueAmountDouble
                                           currency:currency];
    }

    NSNumber *_Nullable adImpressionsCount =
        [self numberLoggedWithJsParameters:jsParameters
                                       key:ADJWBAdImpressionsCountAdRevenueKey
                                      from:ADJWBAdjustAdRevenueName];
    if (adImpressionsCount != nil) {
        [adjustAdRevenue setAdImpressionsCountWithIntegerNumber:adImpressionsCount];
    }

    NSString *_Nullable network =
        [self stringLoggedWithJsParameters:jsParameters
                                       key:ADJWBNetworkAdRevenueKey
                                      from:ADJWBAdjustAdRevenueName];
    if (network != nil) {
        [adjustAdRevenue setNetwork:network];
    }

    NSString *_Nullable unit =
        [self stringLoggedWithJsParameters:jsParameters
                                       key:ADJWBUnitAdRevenueKey
                                      from:ADJWBAdjustAdRevenueName];
    if (unit != nil) {
        [adjustAdRevenue setUnit:unit];
    }

    NSString *_Nullable placement =
        [self stringLoggedWithJsParameters:jsParameters
                                       key:ADJWBPlacementAdRevenueKey
                                      from:ADJWBAdjustAdRevenueName];
    if (placement != nil) {
        [adjustAdRevenue setPlacement:placement];
    }

    return adjustAdRevenue;
}

- (nullable NSArray *)adRevenueCallbackParameterKeyValueArrayWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return [self
            arrayWithObject:
                [jsParameters objectForKey:ADJWBCallbackParameterKeyValueArrayAdRevenueKey]
            failMessage:@"Could not use ad revenue callback parameters"
            optFailMessage:@"Issue while parsing ad revenue callback parameters"];
}

- (nullable NSArray *)adRevenuePartnerParameterKeyValueArrayWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
{
    return [self
            arrayWithObject:
                [jsParameters objectForKey:ADJWBPartnerParameterKeyValueArrayAdRevenueKey]
            failMessage:@"Could not use ad revenue partner parameters"
            optFailMessage:@"Issue while parsing ad revenue partner parameters"];
}

- (nullable NSString *)
    stringLoggedWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
    from:(nonnull NSString *)from
{
    ADJResult<NSString *> *_Nonnull stringResult =
        [ADJSdkApiHelper stringWithJsParameters:jsParameters key:key];
    if (stringResult.failNonNilInput != nil) {
        [self logMissingFieldWithMessage:@"Could not parse string JS field"
                                    fail:stringResult.fail key:key from:from];
    }

    return stringResult.value;
}

+ (nullable ADJResultFail *)
    objectMatchesWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    expectedName:(nonnull NSString *)expectedName
{
    id _Nullable objectNameObject = [jsParameters objectForKey:ADJWBObjectNameKey];
    ADJResult<ADJNonEmptyString *> *_Nonnull objectNameResult =
        [ADJNonEmptyString instanceFromObject:objectNameObject];
    if (objectNameResult.fail != nil) {
        return objectNameResult.fail;
    }

    if (! [expectedName isEqualToString:objectNameResult.value.stringValue]) {
        ADJResultFailBuilder *_Nonnull failBuilder =
            [[ADJResultFailBuilder alloc] initWithMessage:@"Object name does not match expected"];
        [failBuilder withKey:ADJLogActualKey stringValue:objectNameResult.value.stringValue];
        [failBuilder withKey:ADJLogExpectedKey stringValue:expectedName];
        return [failBuilder build];
    }

    return nil;
}

+ (nullable ADJResultFail *)
    elementTypeValidationWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
{
    id _Nullable elementTypeObject =
        [jsParameters objectForKey:[NSString stringWithFormat:@"%@Type", ADJWBElementKey]];

    ADJResult<ADJNonEmptyString *> *_Nonnull elementTypeResult =
        [ADJNonEmptyString instanceFromObject:elementTypeObject];
    if (elementTypeResult.fail != nil) {
        return [[ADJResultFail alloc] initWithMessage:@"Invalid JS type for element field"
                                                  key:@"js type fail"
                                            otherFail:elementTypeResult.fail];
    }

    if ([elementTypeResult.value.stringValue isEqualToString:ADJWBJsStringType]
        || [elementTypeResult.value.stringValue isEqualToString:ADJWBJsBooleanType])
    {
        return nil;
    }

    return [[ADJResultFail alloc] initWithMessage:@"Unexpected JS type for element"
                                              key:ADJLogActualKey
                                      stringValue:elementTypeResult.value.stringValue];
}

+ (nonnull ADJResult<NSString *> *)
    stringWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
{
    id _Nullable typeObject =
        [jsParameters objectForKey:[NSString stringWithFormat:@"%@Type", key]];

    // possible TODO: replace ADJNonEmptyString with less strict check to let native log it
    ADJResult<ADJNonEmptyString *> *_Nonnull typeResult =
        [ADJNonEmptyString instanceFromObject:typeObject];
    if (typeResult.wasInputNil) {
        return [ADJResult nilInputWithMessage:
                @"Type field of expected string value not found in parameters"];
    }
    if (typeResult.fail != nil) {
        return [ADJResult failWithMessage:@"Invalid JS type"
                                      key:@"js type fail"
                                otherFail:typeResult.fail];
    }

    if (! [typeResult.value.stringValue isEqualToString:ADJWBJsStringType]) {
        return [ADJResult failWithMessage:@"Expected string JS type"
                                      key:ADJLogActualKey
                              stringValue:typeResult.value.stringValue];
    }

    id _Nullable stringObject = [jsParameters objectForKey:key];

    ADJResult<ADJNonEmptyString *> *_Nonnull stringResult =
        [ADJNonEmptyString instanceFromObject:stringObject];
    if (stringResult.fail != nil) {
        return [ADJResult failWithMessage:@"Invalid JS string value"
                                      key:@"js string fail"
                                otherFail:stringResult.fail];
    }

    return [ADJResult okWithValue:stringResult.value.stringValue];
}

+ (nonnull ADJResult<ADJBooleanWrapper *> *)booleanWithJsValue:(nullable id)valueObject {
    if (valueObject == nil) {
        return [ADJResult failWithMessage:@"Boolean field unexpectedly not present"];
    }

    if ([valueObject isKindOfClass:[NSNull class]]) {
        return [ADJResult nilInputWithMessage:@"Boolean field found to be NSNull"];
    }

    ADJResult<ADJBooleanWrapper *> *_Nonnull booleanResult =
       [ADJBooleanWrapper instanceFromObject:valueObject];

    if (booleanResult.fail != nil) {
        return [ADJResult failWithMessage:@"Invalid JS boolean value"
                                      key:@"js boolean fail"
                                otherFail:booleanResult.fail];
    }

    return [ADJResult okWithValue:booleanResult.value];
}

+ (nonnull ADJResult<ADJBooleanWrapper *> *)trueWithJsValue:(nullable id)jsValue {
    ADJResult<ADJBooleanWrapper *> *_Nonnull booleanResult =
        [ADJSdkApiHelper booleanWithJsValue:jsValue];
    if (booleanResult.fail != nil) {
        return booleanResult;
    }

    if (! booleanResult.value.boolValue) {
        return [ADJResult failWithMessage:@"JS boolean field was not expected to be false"];
    }

    return booleanResult;
}

+ (nonnull ADJResult<NSNumber *> *)
    numberWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
{
    id _Nullable typeObject =
        [jsParameters objectForKey:[NSString stringWithFormat:@"%@Type", key]];

    ADJResult<ADJNonEmptyString *> *_Nonnull typeResult =
        [ADJNonEmptyString instanceFromObject:typeObject];
    if (typeResult.wasInputNil) {
        return [ADJResult nilInputWithMessage:
                @"Type field of expected int value not found in parameters"];
    }
    if (typeResult.fail != nil) {
        return [ADJResult failWithMessage:@"Invalid JS type"
                                      key:@"js type fail"
                                otherFail:typeResult.fail];
    }

    if (! [typeResult.value.stringValue isEqualToString:ADJWBJsNumberType]) {
        return [ADJResult failWithMessage:@"Expected number JS type for number field"
                                      key:ADJLogActualKey
                              stringValue:typeResult.value.stringValue];
    }

    id _Nullable numberObject = [jsParameters objectForKey:key];
    if (numberObject == nil) {
        return [ADJResult failWithMessage:@"Number field unexpectedly not present"];
    }

    if (! [numberObject isKindOfClass:[NSNumber class]]) {
        return [ADJResult
                failWithMessage:@"Unexpected non-number JS type"
                key:ADJLogActualKey
                stringValue:NSStringFromClass([numberObject class])];
    }

    return [ADJResult okWithValue:(NSNumber *)numberObject];
}

+ (nonnull ADJResult<NSString *> *)
    functionIdWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
{
    id _Nullable typeObject =
        [jsParameters objectForKey:[NSString stringWithFormat:@"%@Type", key]];

    ADJResult<ADJNonEmptyString *> *_Nonnull typeResult =
        [ADJNonEmptyString instanceFromObject:typeObject];
    if (typeResult.wasInputNil) {
        return [ADJResult nilInputWithMessage:
                @"Type field of expected function value not found in parameters"];
    }
    if (typeResult.fail != nil) {
        return [ADJResult failWithMessage:@"Invalid JS type"
                                      key:@"js type fail"
                                otherFail:typeResult.fail];
    }

    if (! [typeResult.value.stringValue isEqualToString:ADJWBJsFunctionType]) {
        return [ADJResult failWithMessage:@"Expected function JS type"
                                      key:ADJLogActualKey
                              stringValue:typeResult.value.stringValue];
    }

    id _Nullable functionIdObject =
        [jsParameters objectForKey:[NSString stringWithFormat:@"%@Id", key]];

    ADJResult<ADJNonEmptyString *> *_Nonnull functionIdResult =
        [ADJNonEmptyString instanceFromObject:functionIdObject];
    if (functionIdResult.fail != nil) {
        return [ADJResult failWithMessage:@"Invalid JS string value for function id"
                                      key:@"js string fail"
                                otherFail:functionIdResult.fail];
    }

    return [ADJResult okWithValue:functionIdResult.value.stringValue];
}

+ (nonnull ADJResult<ADJOptionalFails<NSArray *> *> *)
    arrayWithObject:(nullable id)arrayObject
{
    if (arrayObject == nil) {
        return [ADJResult failWithMessage:@"Array unexpectedly not initialised"];
    }

    if (! [arrayObject isKindOfClass:[NSArray class]]) {
        return [ADJResult failWithMessage:@"Cannot process non-array"
                                      key:ADJLogActualKey
                              stringValue:NSStringFromClass([arrayObject class])];
    }

    NSArray *_Nonnull arraySource = (NSArray *)arrayObject;

    if (arraySource.count == 0) {
        return [ADJResult nilInputWithMessage:@"Array does not contain elements"];
    }

    NSMutableArray<ADJResultFail *> *_Nonnull optFailsMut =
        [[NSMutableArray alloc] initWithCapacity:arraySource.count];
    NSMutableArray *_Nonnull arrayTargetMut =
        [[NSMutableArray alloc] initWithCapacity:arraySource.count];

    for (NSUInteger i = 0; i < arraySource.count; i = i + 1) {
        id _Nonnull elementJsParameters = [arraySource objectAtIndex:i];

        ADJResultFail *_Nullable elementTypeFail =
            [self elementTypeValidationWithJsParameters:elementJsParameters];
        if (elementTypeFail != nil) {
            ADJResultFailBuilder *_Nonnull failBuilder =
                [[ADJResultFailBuilder alloc]
                 initWithMessage:@"Invalid JS type for element"];
            [failBuilder withKey:@"array index" stringValue:[ADJUtilF uIntegerFormat:i]];
            [failBuilder withKey:@"element type fail" otherFail:elementTypeFail];
            [optFailsMut addObject:[failBuilder build]];
        }

        id _Nullable elementObject = [elementJsParameters objectForKey:ADJWBElementKey];
        if (elementObject == nil) {
            [optFailsMut addObject:[[ADJResultFail alloc]
                                    initWithMessage:@"Element field not found"
                                    key:@"array index"
                                    stringValue:[ADJUtilF uIntegerFormat:i]]];
        }

        [arrayTargetMut addObject:[ADJUtilObj idOrNsNull:elementObject]];
    }

    return [ADJResult okWithValue:[[ADJOptionalFails alloc]
                                   initWithOptionalFails:optFailsMut
                                   value:arrayTargetMut]];
}

#pragma mark Internal Methods
- (nullable NSNumber *)
    numberLoggedWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
    from:(nonnull NSString *)from
{
    ADJResult<NSNumber *> *_Nonnull numberResult =
        [ADJSdkApiHelper numberWithJsParameters:jsParameters key:key];
    if (numberResult.failNonNilInput != nil) {
        [self logMissingFieldWithMessage:@"Could not parse number JS field"
                                    fail:numberResult.fail key:key from:from];
    }

    return numberResult.value;
}

- (BOOL)trueLoggedWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
                               key:(nonnull NSString *)key
                              from:(nonnull NSString *)from
{
    ADJResult<ADJBooleanWrapper *> *_Nonnull trueResult =
        [ADJSdkApiHelper trueWithJsValue:[jsParameters objectForKey:key]];
    if (trueResult.failNonNilInput != nil) {
        [self logMissingFieldWithMessage:@"Could not parse true boolean JS field"
                                    fail:trueResult.fail key:key from:from];
    }

    return trueResult.value != nil;
}

- (nullable NSNumber *)
    booleanLoggedWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
    from:(nonnull NSString *)from
{
    ADJResult<ADJBooleanWrapper *> *_Nonnull booleanResult =
        [ADJSdkApiHelper booleanWithJsValue:[jsParameters objectForKey:key]];
    if (booleanResult.failNonNilInput != nil) {
        [self logMissingFieldWithMessage:@"Could not parse boolean JS field"
                                    fail:booleanResult.fail key:key from:from];
    }

    return booleanResult.value != nil ? @(booleanResult.value.boolValue) : nil;
}

- (void)logMissingFieldWithMessage:(nonnull NSString *)message
                              fail:(nonnull ADJResultFail *)fail
                               key:(nonnull NSString *)key
                              from:(nonnull NSString *)from
{
    [self.logger debugWithMessage:message
                     builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
        [logBuilder withKey:@"field name"
                stringValue:key];
        [logBuilder withKey:ADJLogFromKey
                stringValue:from];
        [logBuilder withFail:fail
                       issue:ADJIssueNonNativeIntegration];
    }];
}

- (nullable NSArray *)
    arrayWithObject:(nullable NSArray *)arrayObject
    failMessage:(nonnull NSString *)failMessage
    optFailMessage:(nonnull NSString *)optFailMessage
{
    ADJResult<ADJOptionalFails<NSArray *> *> *_Nonnull arrayResult =
        [ADJSdkApiHelper arrayWithObject:arrayObject];

    if (arrayResult.value == nil) {
        if (arrayResult.failNonNilInput != nil) {
            [self.logger debugDev:failMessage
                       resultFail:arrayResult.fail
                        issueType:ADJIssueNonNativeIntegration];
        }
        return nil;
    }

    for (ADJResultFail *_Nonnull optFail in arrayResult.value.optionalFails) {
        [self.logger debugDev:optFailMessage
                   resultFail:optFail
                    issueType:ADJIssueNonNativeIntegration];
    }

    return arrayResult.value.value;
}

@end
