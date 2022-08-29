//
//  ATAAdjustCommandExecutor.m
//  AdjustTestApp
//
//  Created by Pedro Silva on 28.07.22.
//

#import "ATAAdjustCommandExecutor.h"

#import "ATAAdjustCommandExecutor.h"
#import "ATOAdjustTestOptions.h"
#import "ATAAdjustAttributionDeferredDeeplinkSubscriber.h"
#import "ATAAdjustAttributionSendAllSubscriber.h"
#import "ADJAdjustConfig.h"
#import "ADJAdjust.h"

@interface ATAAdjustCommandExecutor ()

@property (nonnull, readonly, nonatomic, strong) NSString *url;
@property (nonnull, readonly, nonatomic, strong) ATLTestLibrary *testLibrary;
//@property (nonnull, readonly, nonatomic, strong) ATAAdjustCommandExecutor *adjustV4CommandExecutor;

@property (nullable, readwrite, nonatomic, strong) NSDictionary<NSString *, NSArray<NSString *> *> *commandParameters;
@property (nullable, readwrite, nonatomic, strong) NSString *extraPathTestOptions;

@end

@implementation ATAAdjustCommandExecutor

- (nonnull instancetype)initWithUrl:(nonnull NSString *)url
                        testLibrary:(nonnull ATLTestLibrary *)testLibrary {
    self = [super init];

    _url = url;
    _testLibrary = testLibrary;
    //_adjustV4CommandExecutor = [[ATAAdjustCommandExecutor alloc] initWithUrl:url];
    //[self.adjustV4CommandExecutor setTestLibrary:testLibrary];

    return self;
}

- (void)executeCommandWithDictionaryParameters:(nonnull NSDictionary<NSString *, NSArray<NSString *> *> *)dictionaryParameters
                                     className:(nonnull NSString *)className
                                    methodName:(nonnull NSString *)methodName {
    if ([className isEqualToString:@"Adjust"]) {
        [self executeAdjustCommandWithMethodName:methodName
                            dictionaryParameters:dictionaryParameters];
    } else if ([className isEqualToString:@"AdjustV4"]) {
        /*
         [self.adjustV4CommandExecutor executeCommand:className
         methodName:methodName
         parameters:dictionaryParameters];
         */
    } else if ([className isEqualToString:@"TestOptions"]) {
        if (! [methodName isEqualToString:@"teardown"]) {
            [self logError:@"TestOption only method should be 'teardown'. %@ is not supported",
             methodName];
            return;
        }

        self.extraPathTestOptions =
        [ATOAdjustTestOptions
         teardownAndExecuteTestOptionsCommandWithUrlOverwrite:self.url
         commandParameters:dictionaryParameters];
    } else {
        [self logError:@"Could not find %@ to execute", className];
    }
}

#define adjustCommand(adjustMethod)                         \
if ([methodName isEqualToString:@#adjustMethod]) {      \
[self adjustMethod];                                \
} else                                                  \

- (void)executeAdjustCommandWithMethodName:(NSString *)methodName
                      dictionaryParameters:(nonnull NSDictionary<NSString *, NSArray<NSString *> *> *)dictionaryParameters {
    self.commandParameters = dictionaryParameters;

    adjustCommand(start)
    adjustCommand(resume)
    adjustCommand(pause)
    adjustCommand(trackEvent)
    adjustCommand(stop)
    adjustCommand(restart)
    adjustCommand(setOfflineMode)
    adjustCommand(addGlobalCallbackParameter)
    adjustCommand(addGlobalPartnerParameter)
    adjustCommand(removeGlobalCallbackParameter)
    adjustCommand(removeGlobalPartnerParameter)
    adjustCommand(clearGlobalCallbackParameters)
    adjustCommand(clearGlobalPartnerParameters)
    adjustCommand(setPushToken)
    adjustCommand(openDeeplink)
    adjustCommand(gdprForgetMe)
    adjustCommand(trackAdRevenue)
    adjustCommand(thirdPartySharing)
    [self logError:@"method name %@ not found", methodName];
}

- (void)start {
    NSString *_Nullable environment = [self firstParameterValueWithKey:@"environment"];
    NSString *_Nullable appToken = [self firstParameterValueWithKey:@"appToken"];

    ADJAdjustConfig *_Nonnull adjustConfig =
    [[ADJAdjustConfig alloc] initWithAppToken:appToken
                                  environment:environment];

    if ([self containsKey:@"defaultTracker"]) {
        [adjustConfig setDefaultTracker:[self firstParameterValueWithKey:@"defaultTracker"]];
    }

    if ([self isValueTrueWithKey:@"sendInBackground"]) {
        [adjustConfig allowSendingFromBackground];
    }

    if ([self containsKey:@"deferredDeeplinkCallback"]) {
        if (! [self isValueTrueWithKey:@"deferredDeeplinkCallback"]) {
            [adjustConfig preventOpenDeferredDeeplink];
        }

        [adjustConfig setAdjustAttributionSubscriber:
         [[ATAAdjustAttributionDeferredDeeplinkSubscriber alloc]
          initWithTestLibrary:self.testLibrary
          extraPath:self.extraPathTestOptions]];
    }

    if ([self containsKey:@"attributionCallbackSendAll"]) {
        [adjustConfig setAdjustAttributionSubscriber:
         [[ATAAdjustAttributionSendAllSubscriber alloc]
          initWithTestLibrary:self.testLibrary
          extraPath:self.extraPathTestOptions]];
    }

    if ([self containsKey:@"configureEventDeduplication"]) {
        NSString *_Nullable eventDeduplicationString =
        [self firstParameterValueWithKey:@"configureEventDeduplication"];
        NSNumber *_Nullable eventDeduplicationIntNumber =
        [self strictParseNumberIntWithString:eventDeduplicationString];

        if (eventDeduplicationIntNumber != nil) {
            [adjustConfig setEventIdDeduplicationMaxCapacity:
             eventDeduplicationIntNumber.intValue];
        } else {
            [self logError:@"Could not parse configureEventDeduplication value: %@",
             eventDeduplicationString];
        }
    }

    if ([self containsKey:@"customEndpointUrl"]
        || [self containsKey:@"customEndpointPublicKeyHash"]
        || [self containsKey:@"testServerBaseUrlEndpointUrl"])
    {
        NSString *_Nullable customEndpointUrl;
        if ([self containsKey:@"testServerBaseUrlEndpointUrl"]) {
            customEndpointUrl = self.url;
        } else {
            customEndpointUrl = [self firstParameterValueWithKey:@"customEndpointUrl"];
        }

        NSString *_Nullable customEndpointPublicKeyHash =
        [self firstParameterValueWithKey:@"customEndpointPublicKeyHash"];

        [adjustConfig setCustomEndpointWithUrl:customEndpointUrl
                      optionalPublicKeyKeyHash:customEndpointPublicKeyHash];
    }

    if ([self isValueTrueWithKey:@"doNotReadAppleSearchAdsAttribution"]) {
        [adjustConfig doNotReadAppleSearchAdsAttribution];
    }

    [ADJAdjust sdkInitWithAdjustConfig:adjustConfig];
}
/*
 if (parameters.containsKey("defaultTracker")) {
 val defaultTracker = getFirstParameterValue("defaultTracker")
 adjustConfig.setDefaultTracker(defaultTracker.orEmpty())
 }
 */
- (void)resume {
    [ADJAdjust appWentToTheForegroundManualCall];
}

- (void)pause {
    [ADJAdjust appWentToTheBackgroundManualCall];
}

- (void)trackEvent {
    NSString *_Nullable eventToken = [self firstParameterValueWithKey:@"eventToken"];

    ADJAdjustEvent *_Nonnull adjustEvent =
    [[ADJAdjustEvent alloc] initWithEventId:eventToken];

    if ([self containsKey:@"currencyAndRevenue"]) {
        NSString *_Nullable currency = [self parameterValueWithKey:@"currencyAndRevenue"
                                                             index:0];
        NSString *_Nullable revenueString = [self parameterValueWithKey:@"currencyAndRevenue"
                                                                  index:1];
        // TODO: not sure if clients will be using NSNumber over double approach
        // NSNumber *_Nullable revenueNumber = [self strictParseNumberDoubleWithString:revenueString];
        // [adjustEvent setRevenueWithDoubleNumber:revenueNumber
        //                                currency:currency];
        [adjustEvent setRevenueWithDouble:[revenueString doubleValue] currency:currency];
    }

    if ([self containsKey:@"callbackParams"]) {
        [self iterateWithKey:@"callbackParams"
                      source:@"event callback"
               keyValueBlock:^(NSString * _Nonnull key, NSString * _Nonnull value)
         {
            [adjustEvent addCallbackParameterWithKey:key value:value];
        }];
    }

    if ([self containsKey:@"partnerParams"]) {
        [self iterateWithKey:@"partnerParams"
                      source:@"event partner"
               keyValueBlock:^(NSString * _Nonnull key, NSString * _Nonnull value)
         {
            [adjustEvent addPartnerParameterWithKey:key value:value];
        }];
    }

    if ([self containsKey:@"deduplicationId"]) {
        NSString *_Nullable deduplicationId =
        [self firstParameterValueWithKey:@"deduplicationId"];

        [adjustEvent setDeduplicationId:deduplicationId];
    }

    [ADJAdjust trackEvent:adjustEvent];
}

- (void)stop {
    [ADJAdjust inactivateSdk];
}

- (void)restart {
    [ADJAdjust reactivateSdk];
}

- (void)setOfflineMode {
    if (! [self containsKey:@"enabled"]) {
        [self logError:@"setOfflineMode without expected enabled key"];
        return;
    }

    NSNumber *_Nullable strictEnabledValue = [self strictParseNumberBoolWithKey:@"enabled"];

    if (strictEnabledValue == nil) {
        [self logError:@"setOfflineMode without non valid enabled value: %@",
         [self firstParameterValueWithKey:@"enabled"]];
        return;
    }

    if (strictEnabledValue.boolValue) {
        [ADJAdjust switchToOfflineMode];
    } else {
        [ADJAdjust switchBackToOnlineMode];
    }
}

- (void)addGlobalCallbackParameter {
    [self iterateWithKey:@"keyValuePairs"
                  source:@"add global callback"
           keyValueBlock:^(NSString * _Nonnull key, NSString * _Nonnull value)
     {
        [ADJAdjust addGlobalCallbackParameterWithKey:key value:value];
    }];
}

- (void)addGlobalPartnerParameter {
    [self iterateWithKey:@"keyValuePairs"
                  source:@"add global partner"
           keyValueBlock:^(NSString * _Nonnull key, NSString * _Nonnull value)
     {
        [ADJAdjust addGlobalPartnerParameterWithKey:key value:value];
    }];

}

- (void)removeGlobalCallbackParameter {
    [self iterateWithKey:@"key"
                  source:@"remove global callback"
                keyBlock:^(NSString * _Nonnull key)
     {
        [ADJAdjust removeGlobalCallbackParameterByKey:key];
    }];
}

- (void)removeGlobalPartnerParameter {
    [self iterateWithKey:@"key"
                  source:@"remove global partner"
                keyBlock:^(NSString * _Nonnull key)
     {
        [ADJAdjust removeGlobalPartnerParameterByKey:key];
    }];
}

- (void)clearGlobalCallbackParameters {
    [ADJAdjust clearAllGlobalCallbackParameters];
}

- (void)clearGlobalPartnerParameters {
    [ADJAdjust clearAllGlobalPartnerParameters];
}

- (void)setPushToken {
    /*
     NSString *_Nullable pushToken = [self firstParameterValueWithKey:@"pushToken"];

     ADJAdjustPushToken *_Nonnull adjustPushToken =
     [[ADJAdjustPushToken alloc] initWithStringPushToken:pushToken];

     [ADJAdjust trackPushToken:adjustPushToken];
     */
}

- (void)openDeeplink {
    /*
     NSString *_Nullable openDeeplink = [self firstParameterValueWithKey:@"deeplink"];

     ADJAdjustLaunchedDeeplink *_Nonnull adjustLaunchedDeeplink =
     [[ADJAdjustLaunchedDeeplink alloc] initWithString:openDeeplink];

     [ADJAdjust trackLaunchedDeeplink:adjustLaunchedDeeplink];
     */
}

- (void)gdprForgetMe {
    //[ADJAdjust gdprForgetDevice];
}

- (void)trackAdRevenue {

    NSString *_Nullable adRevenueSource = [self firstParameterValueWithKey:@"adRevenueSource"];

    ADJAdjustAdRevenue *_Nonnull adjustAdRevenue = [[ADJAdjustAdRevenue alloc] initWithSource:adRevenueSource];

    if ([self containsKey:@"currencyAndRevenue"]) {
        NSString *_Nullable currency = [self parameterValueWithKey:@"currencyAndRevenue"
                                                             index:0];
        NSString *_Nullable revenueString = [self parameterValueWithKey:@"currencyAndRevenue"
                                                                  index:1];
        [adjustAdRevenue setRevenueWithDouble:[revenueString doubleValue]
                                           currency:currency];
    }

    if ([self containsKey:@"adImpressionsCount"]) {
        NSString *_Nullable adImpressionsCountString = [self firstParameterValueWithKey:@"adImpressionsCount"];
        NSInteger adImpressionsCountInteger = [adImpressionsCountString integerValue];
        [adjustAdRevenue setAdImpressionsCountWithInteger:adImpressionsCountInteger];
    }

    if ([self containsKey:@"adRevenueNetwork"]) {
        [adjustAdRevenue setAdRevenueNetwork:[self firstParameterValueWithKey:@"adRevenueNetwork"]];
    }

    if ([self containsKey:@"adRevenueUnit"]) {
        [adjustAdRevenue setAdRevenueUnit:[self firstParameterValueWithKey:@"adRevenueUnit"]];
    }

    if ([self containsKey:@"adRevenuePlacement"]) {
        [adjustAdRevenue setAdRevenuePlacement:[self firstParameterValueWithKey:@"adRevenuePlacement"]];
    }

    [self iterateWithKey:@"callbackParams"
                  source:@"ad revenue callback params"
           keyValueBlock:^(NSString * _Nonnull key, NSString * _Nonnull value) {
        [adjustAdRevenue addCallbackParameterWithKey:key
                                               value:value];
    }];

    [self iterateWithKey:@"partnerParams"
                  source:@"ad revenue partner params"
           keyValueBlock:^(NSString * _Nonnull key, NSString * _Nonnull value) {
        [adjustAdRevenue addPartnerParameterWithKey:key
                                              value:value];
    }];

    [ADJAdjust trackAdRevenue:adjustAdRevenue];
}

- (void)thirdPartySharing {
    /*
     ADJAdjustThirdPartySharing *_Nonnull adjustThirdPartySharing =
     [[ADJAdjustThirdPartySharing alloc] init];

     NSNumber *_Nullable sharingEnabledNumberBool =
     [self strictParseNumberBoolWithKey:@"enableOrElseDisable"];

     if (sharingEnabledNumberBool != nil) {
     if (sharingEnabledNumberBool.boolValue) {
     [adjustThirdPartySharing enableThirdPartySharing];
     } else {
     [adjustThirdPartySharing disableThirdPartySharing];
     }
     }

     if ([self containsKey:@"granularOptions"]) {
     [self iterateWithKey:@"granularOptions"
     source:@"third party granular options"
     nameKeyValueBlock:
     ^(NSString * _Nonnull name,
     NSString * _Nonnull key,
     NSString * _Nonnull value)
     {
     [adjustThirdPartySharing
     addGranularOptionWithPartnerName:name
     key:key
     value:value];
     }];
     }

     [ADJAdjust trackThirdPartySharing:adjustThirdPartySharing];
     */
}

- (BOOL)containsKey:(nonnull NSString *)key {
    return [self.commandParameters objectForKey:key] != nil;
}

- (nullable NSString *)firstParameterValueWithKey:(nonnull NSString *)key {
    return [self parameterValueWithKey:key index:0];
}

- (nullable NSString *)parameterValueWithKey:(nonnull NSString *)key
                                       index:(NSUInteger)index
{
    NSArray<NSString *> *_Nullable valueArray = [self.commandParameters objectForKey:key];
    if ([self isNull:valueArray] || index >= valueArray.count ) {
        return nil;
    }

    NSString *_Nullable value = [valueArray objectAtIndex:index];

    if ([self isNull:value]) {
        return nil;
    }

    return value;
}

- (nullable NSNumber *)strictParseNumberBoolWithKey:(nonnull NSString *)key {
    NSString *_Nullable firstParameterValue = [self firstParameterValueWithKey:key];

    return [ATOAdjustTestOptions strictParseNumberBooleanWithString:firstParameterValue];
}

- (BOOL)isValueTrueWithKey:(nonnull NSString *)key {
    NSNumber *_Nullable strictBooleanValue = [self strictParseNumberBoolWithKey:key];

    if (strictBooleanValue == nil) {
        return NO;
    }

    return strictBooleanValue.boolValue;
}

- (nullable NSNumber *)strictParseNumberIntWithString:(nonnull NSString *)stringValue {
    if (stringValue == nil) {
        return nil;
    }

    if ([@"0" isEqualToString:stringValue]) {
        return @(0);
    }

    int intValue = [stringValue intValue];

    // 0 value means it could not parse it
    if (intValue == 0) {
        return nil;
    }

    return @(intValue);
}

- (nullable NSNumber *)strictParseNumberDoubleWithString:(nonnull NSString *)stringValue {
    if (stringValue == nil) {
        return nil;
    }

    if ([@"0" isEqualToString:stringValue]
        || [@"0.0" isEqualToString:stringValue]
        || [@"0,0" isEqualToString:stringValue])
    {
        return @(0.0);
    }

    double doubleValue = [stringValue doubleValue];

    // 0 value means it could not parse it
    if (doubleValue == 0.0) {
        return nil;
    }

    return @(doubleValue);
}

- (void)
iterateWithKey:(nonnull NSString *)key
source:(nonnull NSString *)source
keyBlock:(nonnull void (^)(NSString *_Nonnull key))keyBlock
{
    NSArray<NSString *> *_Nullable array =
    [self.commandParameters objectForKey:key];

    if (array == nil) {
        [self logError:@"%@ is null", source];
        return;
    }

    [self logDebug:@"iterating %@ with %@ keys", source, @(array.count)];

    for (NSUInteger i = 0; i < array.count ; i = i + 1) {
        NSString *_Nonnull key = [array objectAtIndex:i];

        keyBlock(key);
    }
}

- (void)iterateWithKey:(nonnull NSString *)key
                source:(nonnull NSString *)source
         keyValueBlock:(nonnull void (^)(NSString *_Nonnull key, NSString *_Nonnull value))keyValueBlock{
    NSArray<NSString *> *_Nullable array =
    [self.commandParameters objectForKey:key];

    if (array == nil) {
        [self logError:@"%@ is null", source];
        return;
    }

    if ((array.count % 2) != 0) {
        [self logError:@"%@ has uneven count: %@", source, @(array.count)];
        return;
    }

    [self logDebug:@"iterating %@ with %@ key value", source, @(array.count / 2)];

    for (NSUInteger i = 0; i < array.count ; i = i + 2) {
        NSString *_Nonnull key = [array objectAtIndex:i];
        NSString *_Nonnull value = [array objectAtIndex:(i + 1)];

        keyValueBlock(key, value);
    }
}

- (void)iterateWithKey:(nonnull NSString *)key
                source:(nonnull NSString *)source
     nameKeyValueBlock:(nonnull void (^)(NSString *_Nonnull name,
                                         NSString *_Nonnull key,
                                         NSString *_Nonnull value))nameKeyValueBlock {
    NSArray<NSString *> *_Nullable array =
    [self.commandParameters objectForKey:key];

    if (array == nil) {
        [self logError:@"%@ is null", source];
        return;
    }

    if ((array.count % 3) != 0) {
        [self logError:@"%@ has non 3 multiple count: %@", source, @(array.count)];
        return;
    }

    [self logDebug:@"iterating %@ with %@ name-key-value", source, @(array.count / 3)];

    for (NSUInteger i = 0; i < array.count ; i = i + 2) {
        NSString *_Nonnull name = [array objectAtIndex:i];
        NSString *_Nonnull key = [array objectAtIndex:(i + 1)];
        NSString *_Nonnull value = [array objectAtIndex:(i + 2)];

        nameKeyValueBlock(name, key, value);
    }
}

- (void)logDebug:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    NSString *logMessage = [[NSString alloc] initWithFormat:message arguments:parameters];
    va_end(parameters);

    NSLog(@"\t[ATAAdjustCommandExecutor][Debug] %@", logMessage);
}

- (void)logError:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    NSString *logMessage = [[NSString alloc] initWithFormat:message arguments:parameters];
    va_end(parameters);

    NSLog(@"\t[ATAAdjustCommandExecutor][Error] %@", logMessage);
}

- (BOOL)isNull:(nullable id)value {
    return value == nil || value == [NSNull null];
}

@end



