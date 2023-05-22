//
//  TestLibraryBridge.m
//  AdjustWebBridgeTestApp
//
//  Created by Pedro Silva (@nonelse) on 6th August 2018.
//  Copyright © 2018 Adjust GmbH. All rights reserved.
//

#import "TestLibraryBridge.h"
#import "ATOAdjustTestOptions.h"

#import "ADJResultNN.h"
#import "ADJConsoleLogger.h"
#import "ADJUtilF.h"
#import "ADJUtilJson.h"

@interface TestLibraryBridge () <
    AdjustCommandBulkJsonParametersDelegate,
    ADJLogCollector,
    WKScriptMessageHandler>

@property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> logSubscriber;
@property (nonnull, readonly, strong, nonatomic) ADJLogger *logger;
@property (nonnull, readonly, strong, nonatomic) ATLTestLibrary *testLibrary;
@property (nonnull, readonly, strong, nonatomic) WKWebView *webView;

@end

@implementation TestLibraryBridge

+ (nullable TestLibraryBridge *)
    instanceWithWKWebView:(nonnull WKWebView *)webView
    adjustJsLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustJsLogSubscriber
{
    if (! [webView isKindOfClass:WKWebView.class]) {
        if (adjustJsLogSubscriber != nil) {
            [adjustJsLogSubscriber
             didLogWithMessage:
                 [NSString stringWithFormat:@"Cannot use non WKWebView instance: %@",
                  NSStringFromClass([webView class])]
             logLevel:ADJAdjustLogLevelError];
        }
        return nil;
    }

    ADJResultNN<NSString *> *_Nonnull scriptSourceResult =
        [TestLibraryBridge getTestLibraryWebBridgeScript];
    NSLog(@"test library scriptSourceResult %@", scriptSourceResult.value);
    if (scriptSourceResult.fail != nil) {
        if (adjustJsLogSubscriber != nil) {
            [adjustJsLogSubscriber
             didLogWithMessage:
                 [ADJConsoleLogger clientCallbackFormatMessageWithLog:
                  [[ADJInputLogMessageData alloc]
                   initWithMessage:@"Cannot generate script for test libray web bridge"
                   level:ADJAdjustLogLevelError
                   issueType:nil
                   resultFail:scriptSourceResult.fail
                   messageParams:nil]]
             logLevel:ADJAdjustLogLevelError];
        }
        return nil;
    }

    TestLibraryBridge *_Nonnull bridge =
        [[TestLibraryBridge alloc] initWithWithWKWebView:webView
                                     adjustLogSubscriber:adjustJsLogSubscriber];
    bridge.testLibrary.jsonBulkDelegateWeak = bridge;

    WKUserContentController *controller = webView.configuration.userContentController;
    [controller addUserScript:[[WKUserScript.class alloc]
                               initWithSource:scriptSourceResult.value
                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                               forMainFrameOnly:NO]];
    [controller addScriptMessageHandler:bridge name:@"testLibrary"];

    return bridge;
}

+ (nonnull ADJResultNN<NSString *> *)getTestLibraryWebBridgeScript {
    NSBundle *_Nonnull sourceBundle = [NSBundle bundleForClass:self.class];
    // requires that the file 'TestLibraryBridge.js' is in the same location/folder
    NSString *_Nullable scriptPath = [sourceBundle pathForResource:@"TestLibraryBridge"
                                                                  ofType:@"js"];
    if  (scriptPath == nil) {
        return [ADJResultNN failWithMessage:
                @"Cannot obtain test library bridge js path from bundle"];
    }

    NSError *_Nullable error;
    NSString *_Nullable adjustScript = [NSString stringWithContentsOfFile:scriptPath
                                                                 encoding:NSUTF8StringEncoding
                                                                    error:nil];
    if (adjustScript == nil) {
        return [ADJResultNN failWithMessage:@"Cannot read test library bridge js file"
                               builderBlock:
                ^(ADJResultFailBuilder * _Nonnull resultFailBuilder) {
            [resultFailBuilder withError:error];
            [resultFailBuilder withKey:@"test library bridge js path"
                           stringValue:scriptPath];
        }];
    }

    return [ADJResultNN okWithValue:adjustScript];
}

- (nonnull instancetype)
    initWithWithWKWebView:(nonnull WKWebView *)webView
    adjustLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustLogSubscriber
{
    self = [super init];
    ADJLogger *_Nonnull logger =
        [[ADJLogger alloc] initWithName:@"TestLibraryBridge"
                           logCollector:self
                             instanceId:[[ADJInstanceIdData alloc] initNonFirstWithClientId:nil]];

    _logSubscriber = adjustLogSubscriber;
    _logger = logger;
    _webView = webView;

    _testLibrary = [[ATLTestLibrary alloc] initWithBaseUrl:baseUrl
                                                controlUrl:controlUrl];

    return self;
}

#pragma mark - ADJLogCollector
- (void)collectLogMessage:(nonnull ADJLogMessageData *)logMessageData {
    if (self.logSubscriber == nil) {
        NSLog(@"TORMV test library bridge logSubscriber = nil");
        return;
    }

    [self.logSubscriber didLogWithMessage:
     [ADJConsoleLogger clientCallbackFormatMessageWithLog:logMessageData.inputData]
                                 logLevel:logMessageData.inputData.level];
}

#pragma mark - AdjustCommandBulkJsonParametersDelegate
- (void)saveArrayOfCommandsJson:(nonnull NSString *)arrayOfCommandsJson {
    [self execJsCallbackWithCallbackMethodName:@"saveArrayOfCommands"
                         jsonParameter:arrayOfCommandsJson];
}

- (void)executeCommandInArrayPosition:(NSUInteger)arrayPosition {
    [self execJsCallbackWithCallbackMethodName:@"execCommandInPosition"
                         jsonParameter:[ADJUtilF uIntegerFormat:arrayPosition]];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(nonnull WKUserContentController *)userContentController
      didReceiveScriptMessage:(nonnull WKScriptMessage *)message
{
    if (! [message.body isKindOfClass:[NSDictionary class]]) {
        [self.logger debugDev:@"Cannot handle test library script message with non-dictionary body"
                    issueType:ADJIssueNonNativeIntegration];
        return;
    }

    NSDictionary<NSString *, id> *_Nonnull body = (NSDictionary<NSString *, id> *)message.body;

    [self.logger debugDev:@"TORMV test library userContentController"
                      key:@"js body"
              stringValue:[[ADJUtilJson toStringFromDictionary:body] value]];

    ADJResultNN<ADJNonEmptyString *> *_Nonnull methodNameResult =
        [ADJNonEmptyString instanceFromObject:[body objectForKey:ADJWBMethodNameKey]];
    if (methodNameResult.fail != nil) {
        [self.logger debugDev:@"Cannot obtain methodName field from script body"
                      resultFail:methodNameResult.fail
                    issueType:ADJIssueNonNativeIntegration];
        return;
    }
    NSString *_Nonnull methodName = methodNameResult.value.stringValue;

    ADJResultNN<ADJNonEmptyString *> *_Nonnull parametersJsonStringResult =
        [ADJNonEmptyString instanceFromObject:[body objectForKey:ADJWBParametersKey]];
    if (parametersJsonStringResult.fail != nil) {
        [self.logger debugDev:@"Cannot obtain parameters field from script body"
                          key:@"method name"
                  stringValue:methodName
                   resultFail:parametersJsonStringResult.fail
                    issueType:ADJIssueNonNativeIntegration];
        return;
    }

    ADJResultNN<NSDictionary<NSString *, id> *> *_Nonnull parametersJsonDictionaryResult =
        [ADJUtilJson toDictionaryFromString:parametersJsonStringResult.value.stringValue];
    if (parametersJsonDictionaryResult.fail != nil) {
         [self.logger debugWithMessage:
          @"Cannot convert json string from parameters field to dictionary"
                          builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
             [logBuilder withKey:@"method name" stringValue:methodName];
             [logBuilder withKey:@"json string"
                     stringValue:parametersJsonStringResult.value.stringValue];
             [logBuilder withFail:parametersJsonDictionaryResult.fail
                            issue:ADJIssueNonNativeIntegration];
         }];
        return;
    }

    NSDictionary<NSString *, id> *_Nonnull jsParameters =
        parametersJsonDictionaryResult.value;

}

- (void)
    execJsCallbackWithCallbackMethodName:(nonnull NSString *)callbackMethodName
    jsonParameter:(nonnull NSString *)jsonParameter
{
    NSString *_Nonnull jsExecCommand =
        [NSString stringWithFormat:@"TestLibrary.callback_%@(%@);",
         callbackMethodName, jsonParameter];

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
             debugWithMessage:@"Cannot evaluate test library bridge javascript"
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

/*
- (id)initWithAdjustBridgeRegister:(ADJAdjustBridge *)adjustBridge {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    self.testLibrary = [ATLTestLibrary testLibraryWithBaseUrl:baseUrl
                                                andControlUrl:controlUrl
                                           andCommandDelegate:self];
    [self augmentHybridTestWKWebView:adjustBridge.webView];
    return self;
}

#pragma mark - Test Webview Methods

#pragma mark Set up Test Webview

- (void)augmentHybridTestWKWebView:(WKWebView *_Nonnull)webView {
    if ([webView isKindOfClass:WKWebView.class]) {
        self.webView = webView;
        WKUserContentController *controller = webView.configuration.userContentController;
        [controller addScriptMessageHandler:self name:@"adjustTest"];
    }
}

#pragma mark Handle Message from Test Webview

- (void)userContentController:(nonnull WKUserContentController *)userContentController
      didReceiveScriptMessage:(nonnull WKScriptMessage *)message {

    if ([message.body isKindOfClass:[NSDictionary class]]) {

        NSString *action = [message.body objectForKey:@"action"];
        NSDictionary *data = [message.body objectForKey:@"data"];

        if ([action isEqual:@"adjustTLB_startTestSession"]) {

            [self startTestSession:(NSString *)data];

        } else if ([action isEqual:@"adjustTLB_sendInfoToServer"]) {

            [self sendInfoToServer:(NSString *)data];

        } else if ([action isEqual:@"adjustTLB_addInfoToSend"]) {

            NSString *key = [data objectForKey:@"key"];
            NSString *value = [data objectForKey:@"value"];
            [self addInfoToSend:key andValue:value];

        } else if ([action isEqual:@"adjustTLB_addTest"]) {

            [self addTest:(NSString *)data];

        } else if ([action isEqual:@"adjustTLB_addTestDirectory"]) {

            [self addTestDirectory:(NSString *)data];

        } else if ([action isEqual:@"adjustTLB_addToTestOptionsSet"]) {

            NSString *key = [data objectForKey:@"key"];
            NSString *value = [data objectForKey:@"value"];
            [self addToTestOptionsSet:key andValue:value];

        } else if ([action isEqual:@"adjustTLB_teardownAndApplyAddedTestOptionsSet"]) {

            [self teardownAndApplyAddedTestOptionsSet];
        }
    }
}

- (void)startTestSession:(NSString *)clientSdk {
    [self.testLibrary startTestSession:clientSdk];
}

- (void)addTest:(NSString *)testName {
    [self.testLibrary addTest:testName];
}

- (void)addTestDirectory:(NSString *)directoryName {
    [self.testLibrary addTestDirectory:directoryName];
}

- (void)addInfoToSend:(NSString *)key andValue:(NSString *)value {
    [self.testLibrary addInfoToSend:key value:value];
}

- (void)sendInfoToServer:(NSString *)extraPath {
    [self.testLibrary sendInfoToServer:extraPath];
}

- (void)addToTestOptionsSet:(NSString *)key andValue:(NSString *)value {
    [ATOAdjustTestOptions addToOptionsSetWithKey:key value:value];
}

- (void)teardownAndApplyAddedTestOptionsSet {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *extraPath = [ATOAdjustTestOptions
                               teardownAndApplyAddedTestOptionsSetWithUrlOverwrite:baseUrl];
        NSString *javaScript = [NSString
                                stringWithFormat:@"TestLibraryBridge.teardownReturnExtraPath('%@')",
                                extraPath];
        [self.webView evaluateJavaScript:javaScript completionHandler:nil];
    });

}

#pragma mark - Test cases command handler

- (void)executeCommandRawJson:(NSString *)json {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *javaScript = [NSString
                                stringWithFormat:@"TestLibraryBridge.adjustCommandExecutor('%@')",
                                json];
        [self.webView evaluateJavaScript:javaScript completionHandler:nil];
    });
}
*/
@end
