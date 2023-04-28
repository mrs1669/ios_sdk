//
//  ADJWebViewCallback.m
//  Adjust
//
//  Created by Pedro Silva on 26.04.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJWebViewCallback.h"

#import "ADJUtilF.h"

@interface ADJAttributionSubscriberInternalCallback : NSObject<ADJInternalCallback>

- (nonnull instancetype)
    initWithWebViewCallback:(nonnull ADJWebViewCallback *)webViewCallback
    attributionSubscriberCallbackId:(nonnull NSString *)attributionSubscriberCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString;

- (nullable instancetype)init NS_UNAVAILABLE;

@property (nullable, readonly, weak, nonatomic) ADJWebViewCallback *webViewCallbackWeak;
@property (nonnull, readonly, strong, nonatomic) NSString *attributionSubscriberCallbackId;
@property (nonnull, readonly, strong, nonatomic) NSString *instanceIdString;

@end

@interface ADJAttributionGetterAsyncInternalCallback : NSObject<ADJInternalCallback>

- (nonnull instancetype)
    initWithWebViewCallback:(nonnull ADJWebViewCallback *)webViewCallback
    attributionGetterAsyncCallbackId:(nonnull NSString *)attributionGetterAsyncCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString;

- (nullable instancetype)init NS_UNAVAILABLE;

@property (nullable, readonly, weak, nonatomic) ADJWebViewCallback *webViewCallbackWeak;
@property (nonnull, readonly, strong, nonatomic) NSString *attributionGetterAsyncCallbackId;
@property (nonnull, readonly, strong, nonatomic) NSString *instanceIdString;

@end

@implementation ADJWebViewCallback
- (nonnull instancetype)initWithWebView:(nonnull WKWebView *)webView
                                 logger:(nonnull ADJLogger *)logger
{
    self = [super init];
    _webView = webView;
    _logger = logger;

    return self;
}
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull id<ADJInternalCallback>)
    attributionSubscriberInternalCallbackWithId:
        (nonnull NSString *)attributionSubscriberCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString
{
    return [[ADJAttributionSubscriberInternalCallback alloc]
            initWithWebViewCallback:self
            attributionSubscriberCallbackId:attributionSubscriberCallbackId
            instanceIdString:instanceIdString];
}

- (nonnull id<ADJInternalCallback>)
    attributionGetterAsyncInternalCallbackWithId:
        (nonnull NSString *)attributionGetterAsyncCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString
{
    return [[ADJAttributionGetterAsyncInternalCallback alloc]
            initWithWebViewCallback:self
            attributionGetterAsyncCallbackId:attributionGetterAsyncCallbackId
            instanceIdString:instanceIdString];
}

#pragma mark Internal Methods
- (void)
    execJsCallbackSubscriptionWithInstanceIdString:(nonnull NSString *)instanceIdString
    callbackId:(nonnull NSString *)callbackId
    methodName:(nonnull NSString *)methodName
    jsonNonStringParameter:(nonnull NSString *)jsonNonStringParameter
{
    [self execJsCallbackWithInstanceIdString:instanceIdString
                                  callbackId:callbackId
                                  methodName:methodName
                               jsonParameter:jsonNonStringParameter
                    subscriptionOrElseGetter:YES];
}
- (void)
    execJsCallbackSubscriptionWithInstanceIdString:(nonnull NSString *)instanceIdString
    callbackId:(nonnull NSString *)callbackId
    methodName:(nonnull NSString *)methodName
    jsonStringParameter:(nonnull NSString *)jsonStringParameter
{
    [self
     execJsCallbackWithInstanceIdString:instanceIdString
     callbackId:callbackId
     methodName:methodName
     jsonParameter:[NSString stringWithFormat:@"\"%@\"", jsonStringParameter]
     subscriptionOrElseGetter:YES];
}
- (void)
    execJsCallbackGetterWithInstanceIdString:(nonnull NSString *)instanceIdString
    callbackId:(nonnull NSString *)callbackId
    methodName:(nonnull NSString *)methodName
    jsonNonStringParameter:(nonnull NSString *)jsonNonStringParameter
{
    [self execJsCallbackWithInstanceIdString:instanceIdString
                                  callbackId:callbackId
                                  methodName:methodName
                               jsonParameter:jsonNonStringParameter
                    subscriptionOrElseGetter:NO];
}
- (void)
    execJsCallbackGetterWithInstanceIdString:(nonnull NSString *)instanceIdString
    callbackId:(nonnull NSString *)callbackId
    methodName:(nonnull NSString *)methodName
    jsonStringParameter:(nonnull NSString *)jsonStringParameter
{
    [self
     execJsCallbackWithInstanceIdString:instanceIdString
     callbackId:callbackId
     methodName:methodName
     jsonParameter:[NSString stringWithFormat:@"\"%@\"", jsonStringParameter]
     subscriptionOrElseGetter:NO];
}

- (void)
    execJsCallbackWithInstanceIdString:(nonnull NSString *)instanceIdString
    callbackId:(nonnull NSString *)callbackId
    methodName:(nonnull NSString *)methodName
    jsonParameter:(nonnull NSString *)jsonParameter
    subscriptionOrElseGetter:(BOOL)subscriptionOrElseGetter
{
    NSString *_Nonnull jsonInstanceId = [NSString stringWithFormat:@"\"%@\"", instanceIdString];
    NSString *_Nonnull jsExecCommand =
        [NSString stringWithFormat:@"Adjust.instance(%@).adjust_client%@(\"%@\", \"%@\", %@);",
         jsonInstanceId,
         subscriptionOrElseGetter ? @"Subscription" : @"GetterAsync",
         callbackId, methodName, jsonParameter];

    [self.logger debugWithMessage:@"TORMV execJsCallback"
                     builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
        [logBuilder withKey:@"jsonParameter"
                stringValue:jsonParameter];
        [logBuilder withKey:@"subscriptionOrElseGetter"
                stringValue:[ADJUtilF boolFormat:subscriptionOrElseGetter]];
        [logBuilder withKey:@"jsExecCommand"
                stringValue:jsExecCommand];
    }];

    __typeof(self) __weak weakSelf = self;
    [self.webView evaluateJavaScript:jsExecCommand
                   completionHandler:^(id _Nullable jsonReturnValue,
                                       NSError *_Nullable error)
     {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        if (error != nil) {
            [strongSelf.logger
             debugWithMessage:@"Cannot evaluate javascript"
             builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
                [logBuilder withFail:[[ADJResultFail alloc]
                                      initWithMessage:@"evaluateJavaScript completionHandler error"
                                      error:error]
                               issue:ADJIssueNonNativeIntegration];
                [logBuilder withKey:@"instanceIdString" stringValue:instanceIdString];
                [logBuilder withKey:@"callbackId" stringValue:callbackId];
                [logBuilder withKey:@"methodName" stringValue:methodName];
                [logBuilder withKey:@"jsonParameter" stringValue:jsonParameter];
                [logBuilder withKey:@"subscriptionOrElseGetter"
                        stringValue:[ADJUtilF boolFormat:subscriptionOrElseGetter]];
                if (jsonReturnValue != nil) {
                    [logBuilder withKey:@"jsonReturnValue"
                            stringValue:[jsonReturnValue description]];
                }
            }];
        }
    }];
}

@end

@implementation ADJAttributionSubscriberInternalCallback
#pragma mark Instantiation
- (nonnull instancetype)
    initWithWebViewCallback:(nonnull ADJWebViewCallback *)webViewCallback
    attributionSubscriberCallbackId:(nonnull NSString *)attributionSubscriberCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString
{
    self = [super init];
    _webViewCallbackWeak = webViewCallback;
    _attributionSubscriberCallbackId = attributionSubscriberCallbackId;
    _instanceIdString = instanceIdString;

    return self;
}
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma mark Public API
#pragma mark - ADJInternalCallback
- (void)didInternalCallbackWithData:(nonnull NSDictionary<NSString *, id> *)data {
    ADJWebViewCallback *_Nullable webViewCallback = self.webViewCallbackWeak;
    NSLog(@"TORMV didInternalCallbackWithData webViewCallback == nil: %@",
          @(webViewCallback == nil));
    if (webViewCallback == nil) {
        // TODO: log weak ref fail, maybe to adjust internal?
        return;
    }

    [webViewCallback.logger debugDev:@"TORMV didInternalCallbackWithData saved"
                                 key1:@"attributionSubscriberCallbackId"
                        stringValue1:self.attributionSubscriberCallbackId
                                key2:@"instanceIdString"
                        stringValue2:self.instanceIdString];

    [webViewCallback.logger debugDev:@"TORMV didInternalCallbackWithData received"
                                 key:@"data keys"
                         stringValue:[[ADJUtilJson toStringFromArray:[data allKeys]] value]];

    id _Nullable didReadAdjustAttributonJsonStringValue =
        [data objectForKey:[NSString stringWithFormat:@"%@%@",
                            ADJReadAttributionMethodName, ADJInternalCallbackJsonStringSuffix]];

    if (didReadAdjustAttributonJsonStringValue != nil
        && [didReadAdjustAttributonJsonStringValue isKindOfClass:[NSString class]])
    {
        [webViewCallback
         execJsCallbackSubscriptionWithInstanceIdString:self.instanceIdString
         callbackId:self.attributionSubscriberCallbackId
         methodName:ADJReadAttributionMethodName
         jsonNonStringParameter:(NSString *)didReadAdjustAttributonJsonStringValue];
        return;
    }

    id _Nullable didChangeAdjustAttributonJsonStringValue =
        [data objectForKey:[NSString stringWithFormat:@"%@%@",
                            ADJChangedAttributionMethodName,
                            ADJInternalCallbackJsonStringSuffix]];

    if (didChangeAdjustAttributonJsonStringValue != nil
        && [didChangeAdjustAttributonJsonStringValue isKindOfClass:[NSString class]])
    {
        [webViewCallback
         execJsCallbackSubscriptionWithInstanceIdString:self.instanceIdString
         callbackId:self.attributionSubscriberCallbackId
         methodName:ADJChangedAttributionMethodName
         jsonNonStringParameter:(NSString *)didChangeAdjustAttributonJsonStringValue];
        return;
    }

    [webViewCallback.logger
     debugWithMessage:@"Could not find either attribution subscription callback values"
     builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
        [logBuilder withKey:@"callback data keys" jsonArray:[data allKeys]];
        [logBuilder issue:ADJIssueNonNativeIntegration];
    }];
}

@end

@implementation ADJAttributionGetterAsyncInternalCallback
#pragma mark Instantiation
- (nonnull instancetype)
    initWithWebViewCallback:(nonnull ADJWebViewCallback *)webViewCallback
    attributionGetterAsyncCallbackId:(nonnull NSString *)attributionGetterAsyncCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString
{
    self = [super init];
    _webViewCallbackWeak = webViewCallback;
    _attributionGetterAsyncCallbackId = attributionGetterAsyncCallbackId;
    _instanceIdString = instanceIdString;

    return self;
}
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
#pragma mark - ADJInternalCallback
- (void)didInternalCallbackWithData:(nonnull NSDictionary<NSString *, id> *)data {
    ADJWebViewCallback *_Nullable webViewCallback = self.webViewCallbackWeak;
    NSLog(@"TORMV didInternalCallbackWithData webViewCallback == nil: %@",
          @(webViewCallback == nil));
    if (webViewCallback == nil) {
        // TODO: log weak ref fail, maybe to adjust internal?
        return;
    }

    [webViewCallback.logger debugDev:@"TORMV didInternalCallbackWithData saved"
                                 key1:@"attributionGetterAsyncCallbackId"
                        stringValue1:self.attributionGetterAsyncCallbackId
                                key2:@"instanceIdString"
                        stringValue2:self.instanceIdString];

    [webViewCallback.logger debugDev:@"TORMV didInternalCallbackWithData received"
                                 key:@"data keys"
                         stringValue:[[ADJUtilJson toStringFromArray:[data allKeys]] value]];

    id _Nullable attributionGetterJsonStringValue =
        [data objectForKey:[NSString stringWithFormat:@"%@%@",
                            ADJAttributionGetterReadMethodName,
                            ADJInternalCallbackJsonStringSuffix]];

    if (attributionGetterJsonStringValue != nil
        && [attributionGetterJsonStringValue isKindOfClass:[NSString class]])
    {
        [webViewCallback
         execJsCallbackGetterWithInstanceIdString:self.instanceIdString
         callbackId:self.attributionGetterAsyncCallbackId
         methodName:ADJAttributionGetterReadMethodName
         jsonNonStringParameter:(NSString *)attributionGetterJsonStringValue];
        return;
    }

    id _Nullable attributionGetterFailedStringValue =
        [data objectForKey:ADJAttributionGetterFailedMethodName];

    if (attributionGetterFailedStringValue != nil
        && [attributionGetterFailedStringValue isKindOfClass:[NSString class]])
    {
        [webViewCallback
         execJsCallbackGetterWithInstanceIdString:self.instanceIdString
         callbackId:self.attributionGetterAsyncCallbackId
         methodName:ADJAttributionGetterFailedMethodName
         jsonStringParameter:(NSString *)attributionGetterFailedStringValue];
        return;
    }

    [webViewCallback.logger
     debugWithMessage:@"Could not find either attribution getter callback values"
     builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
        [logBuilder withKey:@"callback data keys" jsonArray:[data allKeys]];
        [logBuilder issue:ADJIssueNonNativeIntegration];
    }];
}

@end
