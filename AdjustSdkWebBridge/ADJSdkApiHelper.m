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
#import "ADJOptionalFailsNL.h"

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

- (nonnull ADJAdjustConfig *)adjustConfigWithParametersJsonDictionary:
    (nonnull NSDictionary<NSString *, id> *)jsParameters
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

    ADJResult<NSNumber *> *_Nonnull eventIdDeduplicationMaxCapacityResult =
        [ADJSdkApiHelper numberWithJsParameters:jsParameters
                                            key:ADJWBEventIdDeduplicationMaxCapacityConfigKey];
    if (eventIdDeduplicationMaxCapacityResult.failNonNilInput != nil) {
        [self.logger debugDev:@"Could not parse JS field for adjust config"
                          key:@"field name"
                  stringValue:ADJWBEventIdDeduplicationMaxCapacityConfigKey
                   resultFail:eventIdDeduplicationMaxCapacityResult.fail
                    issueType:ADJIssueNonNativeIntegration];
    }
    if (eventIdDeduplicationMaxCapacityResult.value != nil) {
        [adjustConfig setEventIdDeduplicationMaxCapacity:
         eventIdDeduplicationMaxCapacityResult.value.intValue];
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

    __block ADJAdjustEvent *_Nonnull adjustEvent =
        [[ADJAdjustEvent alloc] initWithEventToken:eventToken];

    NSString *_Nullable currency = [self stringLoggedWithJsParameters:jsParameters
                                                                  key:ADJWBCurrencyEventKey
                                                                 from:ADJWBAdjustEventName];

    ADJResult<NSNumber *> *_Nonnull revenueAmountDoubleResult =
        [ADJSdkApiHelper numberWithJsParameters:jsParameters
                                            key:ADJWBRevenueAmountDoubleEventKey];
    if (revenueAmountDoubleResult.failNonNilInput != nil) {
        [self.logger debugWithMessage:@"Could not parse number JS field"
                         builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
            [logBuilder withKey:@"field name"
                    stringValue:ADJWBRevenueAmountDoubleEventKey];
            [logBuilder withKey:ADJLogFromKey
                    stringValue:ADJWBAdjustEventName];
            [logBuilder withFail:revenueAmountDoubleResult.fail
                           issue:ADJIssueNonNativeIntegration];
        }];
    }
    NSNumber *_Nonnull revenueAmountDouble = revenueAmountDoubleResult.value;
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

    ADJOptionalFailsNL<ADJResultFail *> *_Nonnull callbackOptFails =
        [ADJSdkApiHelper
         iterateKVArrayWithKvArrayObject:
             [jsParameters objectForKey:ADJWBCallbackParametersEventKey]
         iterator:^(NSString *_Nonnull key, NSString *_Nonnull value) {
            [adjustEvent addCallbackParameterWithKey:key value:value];
        }];
    for (ADJResultFail *_Nonnull optFail in callbackOptFails.optionalFails) {
        [self.logger debugDev:@"Issue while parsing event callback key/value parameters"
                   resultFail:optFail
                    issueType:ADJIssueNonNativeIntegration];
    }
    if (callbackOptFails.value != nil) {
        [self.logger debugDev:@"Cannot add event callback parameters"
                   resultFail:callbackOptFails.value
                    issueType:ADJIssueNonNativeIntegration];
    }

    ADJOptionalFailsNL<ADJResultFail *> *_Nonnull partnerOptFails =
        [ADJSdkApiHelper
         iterateKVArrayWithKvArrayObject:
             [jsParameters objectForKey:ADJWBPartnerParametersEventKey]
         iterator:^(NSString *_Nonnull key, NSString *_Nonnull value) {
            [adjustEvent addPartnerParameterWithKey:key value:value];
        }];
    for (ADJResultFail *_Nonnull optFail in partnerOptFails.optionalFails) {
        [self.logger debugDev:@"Issue while parsing event partner key/value parameters"
                   resultFail:optFail
                    issueType:ADJIssueNonNativeIntegration];
    }
    if (partnerOptFails.value != nil) {
        [self.logger debugDev:@"Cannot add event partner parameters"
                   resultFail:partnerOptFails.value
                    issueType:ADJIssueNonNativeIntegration];
    }

    return adjustEvent;
}

- (nonnull ADJAdjustPushToken *)adjustPushTokenStringWithJsParameters:
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

+ (nonnull ADJResult<NSString *> *)
    stringWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
{
    id _Nullable typeObject =
        [jsParameters objectForKey:[NSString stringWithFormat:@"%@Type", key]];

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

+ (nonnull ADJResult<ADJBooleanWrapper *> *)
    trueWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
 {
     id _Nullable valueObject = [jsParameters objectForKey:key];

     if (valueObject == nil) {
         return [ADJResult failWithMessage:
                 @"Boolean field could not be found in parameters. Was expecetd to be initialised to 'null'"];
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

     if (! booleanResult.value.boolValue) {
         return [ADJResult failWithMessage:@"JS boolean field was not expected to be false"];
     }

     return [ADJResult okWithValue:booleanResult.value];
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
        return [ADJResult failWithMessage:@"Expected number JS type"
                                      key:ADJLogActualKey
                              stringValue:typeResult.value.stringValue];
    }

    id _Nullable numberObject = [jsParameters objectForKey:key];

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

+ (ADJOptionalFailsNL<ADJResultFail *> *)
    iterateKVArrayWithKvArrayObject:
        (nullable id)kvArrayObject
    iterator:(void (^)(NSString *_Nonnull key, NSString *_Nonnull value))iterator
{
    if (kvArrayObject == nil) {
        return [[ADJOptionalFailsNL alloc] initWithOptionalFails:nil value:nil];
    }

    if (! [kvArrayObject isKindOfClass:[NSArray class]]) {
        return [[ADJOptionalFailsNL alloc]
                initWithOptionalFails:nil
                value:[[ADJResultFail alloc]
                       initWithMessage:@"Cannot iterate non-array"
                       key:ADJLogActualKey
                       stringValue:NSStringFromClass([kvArrayObject class])]];
    }
    NSArray *_Nonnull kvArray = (NSArray *)kvArrayObject;

    if (kvArray.count == 0) {
        return [[ADJOptionalFailsNL alloc] initWithOptionalFails:nil value:nil];
    }

    NSMutableArray<ADJResultFail *> *_Nonnull optFailsMut =
        [[NSMutableArray alloc] initWithCapacity:kvArray.count];
    for (NSUInteger i = 0; i < kvArray.count; i = i + 1) {
        id _Nonnull kvElement = [kvArray objectAtIndex:i];

        if (! [kvElement isKindOfClass:[NSDictionary class]]) {
            ADJResultFailBuilder *_Nonnull failBuilder =
                [[ADJResultFailBuilder alloc] initWithMessage:
                 @"Cannot iterate on array element that does not map to a Json dictionary"];
            [failBuilder withKey:ADJLogActualKey stringValue:NSStringFromClass([kvElement class])];
            [failBuilder withKey:@"array index" stringValue:[ADJUtilF uIntegerFormat:i]];
            [optFailsMut addObject:[failBuilder build]];
            continue;
        }
        ADJResult<NSString *> *_Nonnull keyResult =
            [self stringWithJsParameters:kvElement key:ADJWBKvKeyKey];
        if (keyResult.wasInputNil) {
            [optFailsMut addObject:
             [[ADJResultFail alloc]
              initWithMessage:@"Cannot use unexpectedly non-existing key of array element"
              key:@"array index" stringValue:[ADJUtilF uIntegerFormat:i]]];
            continue;
        }
        if (keyResult.fail != nil) {
            ADJResultFailBuilder *_Nonnull failBuilder =
                [[ADJResultFailBuilder alloc] initWithMessage:@"Cannot get key of array element"];
            [failBuilder withKey:@"string extraction fail" otherFail:keyResult.fail];
            [failBuilder withKey:@"array index" stringValue:[ADJUtilF uIntegerFormat:i]];
            [optFailsMut addObject:[failBuilder build]];
            continue;
        }

        ADJResult<NSString *> *_Nonnull valueResult =
            [self stringWithJsParameters:kvElement key:ADJWBKvValueKey];
        if (valueResult.wasInputNil) {
            [optFailsMut addObject:
             [[ADJResultFail alloc]
              initWithMessage:@"Cannot use unexpectedly non-existing value of array element"
              key:@"array index" stringValue:[ADJUtilF uIntegerFormat:i]]];
            continue;
        }
        if (valueResult.fail != nil) {
            ADJResultFailBuilder *_Nonnull failBuilder =
                [[ADJResultFailBuilder alloc] initWithMessage:@"Cannot get value of array element"];
            [failBuilder withKey:@"string extraction fail" otherFail:valueResult.fail];
            [failBuilder withKey:@"array index" stringValue:[ADJUtilF uIntegerFormat:i]];
            [optFailsMut addObject:[failBuilder build]];
            continue;
        }

        iterator(keyResult.value, valueResult.value);
    }

    if (optFailsMut.count == kvArray.count) {
        return [[ADJOptionalFailsNL alloc]
                initWithOptionalFails:optFailsMut
                value:[[ADJResultFail alloc]
                       initWithMessage:@"Could not use any of the key-values"]];
    }

    return [[ADJOptionalFailsNL alloc] initWithOptionalFails:optFailsMut value:nil];
}

#pragma mark Internal Methods
- (nullable NSString *)
    stringLoggedWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
    from:(nonnull NSString *)from
{
    ADJResult<NSString *> *_Nonnull stringResult =
        [ADJSdkApiHelper stringWithJsParameters:jsParameters key:key];
    if (stringResult.failNonNilInput != nil) {
        [self.logger debugWithMessage:@"Could not parse string JS field"
                         builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
            [logBuilder withKey:@"field name"
                    stringValue:key];
            [logBuilder withKey:ADJLogFromKey
                    stringValue:from];
            [logBuilder withFail:stringResult.fail
                           issue:ADJIssueNonNativeIntegration];
        }];
    }

    return stringResult.value;
}

- (BOOL)trueLoggedWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
                               key:(nonnull NSString *)key
                              from:(nonnull NSString *)from
{
    ADJResult<ADJBooleanWrapper *> *_Nonnull trueResult =
        [ADJSdkApiHelper trueWithJsParameters:jsParameters key:key];
    if (trueResult.failNonNilInput != nil) {
        [self.logger debugWithMessage:@"Could not parse boolean JS field"
                         builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
            [logBuilder withKey:@"boolean field name"
                    stringValue:key];
            [logBuilder withKey:ADJLogFromKey
                    stringValue:from];
            [logBuilder withFail:trueResult.fail
                           issue:ADJIssueNonNativeIntegration];
        }];
    }

    return trueResult.value != nil;
}

@end
