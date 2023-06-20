//
//  ADJWebViewCallback.m
//  Adjust
//
//  Created by Pedro Silva on 26.04.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJWebViewCallback.h"

#import "ADJUtilF.h"
#import "ADJUtilJson.h"

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

@interface ADJAttributionGetterInternalCallback : NSObject<ADJInternalCallback>

- (nonnull instancetype)
    initWithWebViewCallback:(nonnull ADJWebViewCallback *)webViewCallback
    attributionGetterCallbackId:(nonnull NSString *)attributionGetterCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString;

- (nullable instancetype)init NS_UNAVAILABLE;

@property (nullable, readonly, weak, nonatomic) ADJWebViewCallback *webViewCallbackWeak;
@property (nonnull, readonly, strong, nonatomic) NSString *attributionGetterCallbackId;
@property (nonnull, readonly, strong, nonatomic) NSString *instanceIdString;

@end

@interface ADJDeviceIdsGetterInternalCallback : NSObject<ADJInternalCallback>

- (nonnull instancetype)
    initWithWebViewCallback:(nonnull ADJWebViewCallback *)webViewCallback
    deviceIdsGetterCallbackId:(nonnull NSString *)deviceIdsGetterCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString;

- (nullable instancetype)init NS_UNAVAILABLE;

@property (nullable, readonly, weak, nonatomic) ADJWebViewCallback *webViewCallbackWeak;
@property (nonnull, readonly, strong, nonatomic) NSString *deviceIdsGetterCallbackId;
@property (nonnull, readonly, strong, nonatomic) NSString *instanceIdString;

@end

@interface ADJWebViewCallback ()

@property (nonnull, readonly, strong, nonatomic) ADJLogger *logger;

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

#pragma mark - Public API

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
    attributionGetterInternalCallbackWithId:
        (nonnull NSString *)attributionGetterCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString
{
    return [[ADJAttributionGetterInternalCallback alloc]
            initWithWebViewCallback:self
            attributionGetterCallbackId:attributionGetterCallbackId
            instanceIdString:instanceIdString];
}

- (nonnull id<ADJInternalCallback>)
    deviceIdsGetterInternalCallbackWithId:
        (nonnull NSString *)deviceIdsGetterCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString
{
    return [[ADJDeviceIdsGetterInternalCallback alloc]
            initWithWebViewCallback:self
            deviceIdsGetterCallbackId:deviceIdsGetterCallbackId
            instanceIdString:instanceIdString];
}

- (void)execJsTopLevelCallbackWithId:(nonnull NSString *)callbackId
                         stringParam:(nonnull NSString *)stringParam
{
    [self execJsWithExecCommand:
     [NSString stringWithFormat:@"Adjust.%@('%@');", callbackId, stringParam]];
}

#pragma mark Internal Methods

- (void)
    execJsCallbackSubscriberWithInstanceIdString:(nonnull NSString *)instanceIdString
    callbackId:(nonnull NSString *)callbackId
    methodName:(nonnull NSString *)methodName
    jsonNonStringParameter:(nonnull NSString *)jsonNonStringParameter
{
    [self execJsCallbackWithInstanceIdString:instanceIdString
                                  callbackId:callbackId
                                  methodName:methodName
                               jsonParameter:jsonNonStringParameter
                      subscriberOrElseGetter:YES];
}

- (void)
    execJsCallbackSubscriberWithInstanceIdString:(nonnull NSString *)instanceIdString
    callbackId:(nonnull NSString *)callbackId
    methodName:(nonnull NSString *)methodName
    jsonStringParameter:(nonnull NSString *)jsonStringParameter
{
    [self
     execJsCallbackWithInstanceIdString:instanceIdString
     callbackId:callbackId
     methodName:methodName
     jsonParameter:[NSString stringWithFormat:@"'%@'", jsonStringParameter]
     subscriberOrElseGetter:YES];
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
                      subscriberOrElseGetter:NO];
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
     jsonParameter:[NSString stringWithFormat:@"'%@'", jsonStringParameter]
     subscriberOrElseGetter:NO];
}

- (void)
    execJsCallbackWithInstanceIdString:(nonnull NSString *)instanceIdString
    callbackId:(nonnull NSString *)callbackId
    methodName:(nonnull NSString *)methodName
    jsonParameter:(nonnull NSString *)jsonParameter
    subscriberOrElseGetter:(BOOL)subscriberOrElseGetter
{
    NSString *_Nonnull jsExecCommand =
        [NSString stringWithFormat:@"Adjust.instance('%@').adjust_client%@('%@', '%@', %@);",
         instanceIdString,
         subscriberOrElseGetter ? @"Subscriber" : @"Getter",
         callbackId, methodName, jsonParameter];

    [self.logger debugWithMessage:@"TORMV execJsCallback"
                     builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
        [logBuilder withKey:@"jsonParameter"
                stringValue:jsonParameter];
        [logBuilder withKey:@"subscriberOrElseGetter"
                stringValue:[ADJUtilF boolFormat:subscriberOrElseGetter]];
        [logBuilder withKey:@"jsExecCommand"
                stringValue:jsExecCommand];
    }];

    [self execJsWithExecCommand:jsExecCommand];
}

- (void)execJsWithExecCommand:(nonnull NSString *)jsExecCommand {
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
                [logBuilder withKey:@"jsExecCommand" stringValue:jsExecCommand];
                [logBuilder withKey:@"jsonReturnValue" stringValue:jsonReturnValue];
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
         execJsCallbackSubscriberWithInstanceIdString:self.instanceIdString
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
         execJsCallbackSubscriberWithInstanceIdString:self.instanceIdString
         callbackId:self.attributionSubscriberCallbackId
         methodName:ADJChangedAttributionMethodName
         jsonNonStringParameter:(NSString *)didChangeAdjustAttributonJsonStringValue];
        return;
    }

    [webViewCallback.logger
     debugWithMessage:@"Could not find either attribution subscriber callback values"
     builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
        [logBuilder withKey:@"callback data keys" jsonArray:[data allKeys]];
        [logBuilder issue:ADJIssueNonNativeIntegration];
    }];
}

@end

@implementation ADJAttributionGetterInternalCallback

#pragma mark Instantiation

- (nonnull instancetype)
    initWithWebViewCallback:(nonnull ADJWebViewCallback *)webViewCallback
    attributionGetterCallbackId:(nonnull NSString *)attributionGetterCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString
{
    self = [super init];
    _webViewCallbackWeak = webViewCallback;
    _attributionGetterCallbackId = attributionGetterCallbackId;
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
                                 key1:@"attributionGetterCallbackId"
                        stringValue1:self.attributionGetterCallbackId
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
         callbackId:self.attributionGetterCallbackId
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
         callbackId:self.attributionGetterCallbackId
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

@implementation ADJDeviceIdsGetterInternalCallback\

#pragma mark Instantiation

- (nonnull instancetype)
    initWithWebViewCallback:(nonnull ADJWebViewCallback *)webViewCallback
    deviceIdsGetterCallbackId:(nonnull NSString *)deviceIdsGetterCallbackId
    instanceIdString:(nonnull NSString *)instanceIdString
{
    self = [super init];
    _webViewCallbackWeak = webViewCallback;
    _deviceIdsGetterCallbackId = deviceIdsGetterCallbackId;
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
                                 key1:@"deviceIdsGetterCallbackId"
                        stringValue1:self.deviceIdsGetterCallbackId
                                key2:@"instanceIdString"
                        stringValue2:self.instanceIdString];

    [webViewCallback.logger debugDev:@"TORMV didInternalCallbackWithData received"
                                 key:@"data keys"
                         stringValue:[[ADJUtilJson toStringFromArray:[data allKeys]] value]];

    id _Nullable readDeviceIdsJsonStringValue =
        [data objectForKey:[NSString stringWithFormat:@"%@%@",
                            ADJDeviceIdsGetterReadMethodName,
                            ADJInternalCallbackJsonStringSuffix]];

    if (readDeviceIdsJsonStringValue != nil
        && [readDeviceIdsJsonStringValue isKindOfClass:[NSString class]])
    {
        [webViewCallback
         execJsCallbackGetterWithInstanceIdString:self.instanceIdString
         callbackId:self.deviceIdsGetterCallbackId
         methodName:ADJDeviceIdsGetterReadMethodName
         jsonNonStringParameter:(NSString *)readDeviceIdsJsonStringValue];
        return;
    }

    id _Nullable deviceIdsGetterFailedStringValue =
        [data objectForKey:ADJDeviceIdsGetterFailedMethodName];

    if (deviceIdsGetterFailedStringValue != nil
        && [deviceIdsGetterFailedStringValue isKindOfClass:[NSString class]])
    {
        [webViewCallback
         execJsCallbackGetterWithInstanceIdString:self.instanceIdString
         callbackId:self.deviceIdsGetterCallbackId
         methodName:ADJDeviceIdsGetterFailedMethodName
         jsonStringParameter:(NSString *)deviceIdsGetterFailedStringValue];
        return;
    }

    [webViewCallback.logger
     debugWithMessage:@"Could not find either device ids getter callback values"
     builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
        [logBuilder withKey:@"callback data keys" jsonArray:[data allKeys]];
        [logBuilder issue:ADJIssueNonNativeIntegration];
    }];
}

@end
