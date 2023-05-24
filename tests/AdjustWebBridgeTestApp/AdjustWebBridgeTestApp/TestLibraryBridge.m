//
//  TestLibraryBridge.m
//  AdjustWebBridgeTestApp
//
//  Created by Pedro Silva (@nonelse) on 6th August 2018.
//  Copyright © 2018 Adjust GmbH. All rights reserved.
//

#import "TestLibraryBridge.h"
#import "ATOAdjustTestOptions.h"

#import "ADJResult.h"

@interface TestLibraryBridge () <
    AdjustCommandBulkJsonParametersDelegate,
    WKScriptMessageHandler>

@property (nonnull, readonly, strong, nonatomic) ATLTestLibrary *testLibrary;
@property (nonnull, readonly, strong, nonatomic) WKWebView *webView;
@property (nullable, readwrite, nonatomic, strong) NSString *extraPathTestOptions;

@end

@implementation TestLibraryBridge
+ (nullable TestLibraryBridge *)
    instanceWithWKWebView:(nonnull WKWebView *)webView
{
    if (! [webView isKindOfClass:WKWebView.class]) {
        NSLog(@"Cannot use non WKWebView instance: %@", NSStringFromClass([webView class]));
        return nil;
    }

    ADJResultNN<NSString *> *_Nonnull scriptSourceResult =
        [TestLibraryBridge getTestLibraryWebBridgeScript];
    NSLog(@"test library scriptSourceResult %@", scriptSourceResult.value);
    if (scriptSourceResult.fail != nil) {
        NSString *_Nullable failString =
            [self toStringWithJsonDictionary:scriptSourceResult.fail.toJsonDictionary];
        NSLog(@"Cannot generate script for test libray web bridge: %@", failString);
        return nil;
    }

    TestLibraryBridge *_Nonnull bridge = [[TestLibraryBridge alloc] initWithWithWKWebView:webView];
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
{
    self = [super init];
    _webView = webView;

    _testLibrary = [[ATLTestLibrary alloc] initWithBaseUrl:baseUrl controlUrl:controlUrl];

    _extraPathTestOptions = nil;

    return self;
}

#pragma mark - AdjustCommandBulkJsonParametersDelegate
- (void)saveArrayOfCommandsJson:(nonnull NSString *)arrayOfCommandsJson {
    [self
     execJsCallbackWithCallbackMethodName:@"saveArrayOfCommands"
     jsonParameter:[NSString stringWithFormat:@"'%@'", arrayOfCommandsJson]];
}

- (void)executeCommandInArrayPosition:(NSUInteger)arrayPosition {
    [self execJsCallbackWithCallbackMethodName:@"execCommandInPosition"
                         jsonParameter:
     [NSString stringWithFormat:@"%lu", (unsigned long)arrayPosition]];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView evaluateJavaScript:jsExecCommand
                       completionHandler:^(id _Nullable jsonReturnValue,
                                           NSError *_Nullable error)
         {
            if (error != nil) {
                NSLog(@"Cannot evaluate test library bridge javascript");
                NSLog(@"with jsExecCommand %@", jsExecCommand);
                NSLog(@"with jsonReturnValue %@", jsonReturnValue);
                NSLog(@"with error %@", error);
            } else {
                NSLog(@"TORMV Evaluated test library bridge javascript");
                NSLog(@"TORMV with jsExecCommand %@", jsExecCommand);
            }
        }];
    });
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(nonnull WKUserContentController *)userContentController
      didReceiveScriptMessage:(nonnull WKScriptMessage *)message
{
    if (! [message.body isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Cannot handle test library script message with non-dictionary body");
        return;
    }

    NSDictionary<NSString *, id> *_Nonnull body = (NSDictionary<NSString *, id> *)message.body;

    NSLog(@"TORMV test library userContentController: %@",
          [TestLibraryBridge toStringWithJsonDictionary:body]);

    id _Nullable methodNameObject = [body objectForKey:@"_methodName"];
    if (methodNameObject == nil || ! [methodNameObject isKindOfClass:[NSString class]]) {
        NSLog(@"Could not obtain method name");
        return;
    }
    NSString *_Nonnull methodName = (NSString *)methodNameObject;

    id _Nullable parametersObject = [body objectForKey:@"_parameters"];
    if (parametersObject == nil || ! [parametersObject isKindOfClass:[NSString class]]) {
        NSLog(@"Could not obtain parameters of method: %@", methodName);
        return;
    }
    NSString *_Nonnull parametersString = (NSString *)parametersObject;

    NSDictionary<NSString *, id> *_Nullable jsParameters =
        [TestLibraryBridge toDictionaryFromJsonString:parametersString];
    if (jsParameters == nil) {
        NSLog(@"Could not convert parameters to dictionary from method %@", methodName);
        return;
    }

    if ([methodName isEqualToString:@"TORMV"]) {
        [self execJsCallbackWithCallbackMethodName:@"TORMV"
                                     jsonParameter:@"\"TORMV data\""];
        return;
    }

    if ([methodName isEqualToString:@"addTestDirectory"]) {
        NSString *_Nullable directoryName =
            [TestLibraryBridge stringWithJsParameters:jsParameters
                                                  key:@"_directoryName"];
        if (directoryName == nil) {
            NSLog(@"Could not get 'directoryName' from 'addTestDirectory'");
            return;
        }
        [self.testLibrary addTestDirectory:directoryName];
    } else if ([methodName isEqualToString:@"addTest"]) {
        NSString *_Nullable testName =
            [TestLibraryBridge stringWithJsParameters:jsParameters
                                                  key:@"_testName"];
        if (testName == nil) {
            NSLog(@"Could not get 'testName' from 'addTest'");
            return;
        }
        [self.testLibrary addTest:testName];
    } else if ([methodName isEqualToString:@"startTestSession"]) {
        NSString *_Nullable sdkVersion =
            [TestLibraryBridge stringWithJsParameters:jsParameters
                                                  key:@"_sdkVersion"];
        if (sdkVersion == nil) {
            NSLog(@"Could not get 'sdkVersion' from 'startTestSession'");
            return;
        }
        [self.testLibrary startTestSession:sdkVersion];
    } else if ([methodName isEqualToString:@"teardown"]) {
        NSString *_Nullable testOptionsParametersString =
            [TestLibraryBridge jsonStringWithJsParameters:jsParameters
                                                      key:@"_testOptionsParameters"];
        if (testOptionsParametersString == nil) {
            NSLog(@"Could not get 'testOptionsParameters' from 'teardown'");
            return;
        }

        NSDictionary<NSString *, id> *_Nullable testOptionsParameters =
            [TestLibraryBridge toDictionaryFromJsonString:testOptionsParametersString];
        if (testOptionsParameters == nil) {
            NSLog(@"Could not convert test options parameters to dictionary");
            return;
        }

        self.extraPathTestOptions =
            [ATOAdjustTestOptions
             teardownAndExecuteTestOptionsCommandWithUrlOverwrite:baseUrl
             commandParameters:testOptionsParameters];
    } else if ([methodName isEqualToString:@"jsFail"]) {
        NSLog(@"Js failed: %@", parametersString);
    } else {
        NSLog(@"Could not match method name to any expected value: %@, %@",
              methodName, parametersString);
    }
}


#pragma mark Internal Methods
+ (nullable NSString *)
    toStringWithJsonDictionary:(nonnull NSDictionary<NSString *, id> *)jsonDictionary
{
    @try {
        NSError *_Nullable errorPtr = nil;
        // If the object will not produce valid JSON then an exception will be thrown
        NSData *_Nullable jsonData =
            [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                            options:0
                                              error:&errorPtr];

        if (jsonData == nil) {
            NSLog(@"Could not convert json dictionary to data (%@)",
                  [errorPtr localizedDescription]);
            return nil;
        }

        NSString *_Nullable jsonString =
            [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (jsonString == nil) {
            NSLog(@"Could not convert json data to string");
        }
        return jsonString;
    } @catch (NSException *exception) {
        NSLog(@"Exception while converting json dictionary to string (%@)",
              [exception description]);
        return nil;
    }
}

+ (nullable NSDictionary<NSString *, id> *)toDictionaryFromJsonString:
    (nonnull NSString *)jsonString
{
    NSData *_Nullable jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData == nil) {
        NSLog(@"Cannot convert json string to data, %@", jsonString);
        return nil;
    }

    NSError *_Nullable errorPtr = nil;

    id _Nullable jsonObject =
        [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&errorPtr];

    if (jsonObject == nil) {
        NSLog(@"Cannot convert json data to object, %@ (%@)",
              jsonString, [errorPtr localizedDescription]);
        return nil;
    }

    if (! [jsonObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Converted Json object is not a dictionary, %@, %@",
              jsonString, NSStringFromClass([jsonObject class]));
        return nil;
    }

    return (NSDictionary *)jsonObject;
}

+ (nullable NSString *)
    stringWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
{
    id _Nullable typeObject =
        [jsParameters objectForKey:[NSString stringWithFormat:@"%@Type", key]];

    if (typeObject == nil) {
        NSLog(@"Type of expected string field is nil");
        return nil;
    }
    if (! [typeObject isKindOfClass:[NSString class]]) {
        NSLog(@"Type field of expected string field is not string, instead: %@",
              NSStringFromClass([typeObject class]));
        return nil;
    }
    if (! [@"string" isEqualToString:(NSString *)typeObject]) {
        NSLog(@"Type of expected string field is not string, instead: %@", typeObject);
        return nil;
    }

    id _Nullable stringObject = [jsParameters objectForKey:key];

    if (stringObject == nil) {
        NSLog(@"Expected string field is nil");
        return nil;
    }
    if (! [stringObject isKindOfClass:[NSString class]]) {
        NSLog(@"Expected string field is not string, instead: %@",
              NSStringFromClass([stringObject class]));
        return nil;
    }

    return (NSString *)stringObject;
}

+ (nullable NSString *)
    jsonStringWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
{
    id _Nullable typeObject =
        [jsParameters objectForKey:[NSString stringWithFormat:@"%@Type", key]];

    if (typeObject == nil) {
        NSLog(@"Type of expected json string field is nil");
        return nil;
    }
    if (! [typeObject isKindOfClass:[NSString class]]) {
        NSLog(@"Type field of expected json string field is not string, instead: %@",
              NSStringFromClass([typeObject class]));
        return nil;
    }
    if (! [@"object" isEqualToString:(NSString *)typeObject]) {
        NSLog(@"Type of expected json string field is not object, instead: %@", typeObject);
        return nil;
    }

    id _Nullable stringObject = [jsParameters objectForKey:key];

    if (stringObject == nil) {
        NSLog(@"Expected json string field is nil");
        return nil;
    }
    if (! [stringObject isKindOfClass:[NSString class]]) {
        NSLog(@"Expected json string field is not string, instead: %@",
              NSStringFromClass([stringObject class]));
        return nil;
    }

    return (NSString *)stringObject;
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
