//
//  AdjustTestLibrary.m
//  AdjustTestLibrary
//
//  Created by Pedro on 18.04.17.
//  Copyright © 2017 adjust. All rights reserved.
//

#import "ATLTestLibrary.h"
#import "ATLUtil.h"
#import "ATLConstants.h"
#import "ATLBlockingQueue.h"
#import "ATLControlWebSocketClient.h"
#import "ATLSingleThreadExecutor.h"

@interface ATLTestLibrary()

@property (nonatomic, strong) ATLControlWebSocketClient *controlClient;
@property (nonatomic, weak, nullable) id<AdjustCommandDelegate> commandDelegate;
@property (nonatomic, strong) ATLBlockingQueue *waitControlQueue;
@property (nonnull, readonly, strong, nonatomic) ATLSingleThreadExecutor *singleThreadExecutor;
@property (nonatomic, copy) NSString *currentExtraPath;
@property (nonatomic, copy) NSString *currentTestName;
@property (nonatomic, strong) NSMutableString *testNames;
@property (nonnull, readonly, strong, nonatomic)
    NSMutableDictionary<NSString *, NSString *> *infoToServer;

@end

@implementation ATLTestLibrary

BOOL exitAfterEnd = YES;
static NSURL *_baseUrl = nil;

static NSString * const TEST_INFO_PATH = @"/test_info";

+ (NSURL *)baseUrl {
    return _baseUrl;
}

+ (ATLTestLibrary *)testLibraryWithBaseUrl:(NSString *)baseUrl
                             andControlUrl:(NSString *)controlUrl
                        andCommandDelegate:(NSObject<AdjustCommandDelegate> *)commandDelegate {
    return [[ATLTestLibrary alloc] initWithBaseUrl:baseUrl
                                     andControlUrl:controlUrl
                                andCommandDelegate:commandDelegate];
}

- (nonnull instancetype)initWithBaseUrl:(nonnull NSString *)baseUrl
                             controlUrl:(nonnull NSString *)controlUrl
{
    return [self initWithBaseUrl:baseUrl
                   andControlUrl:controlUrl
              andCommandDelegate:nil];
}

- (id)initWithBaseUrl:(NSString *)baseUrl
        andControlUrl:(NSString *)controlUrl
   andCommandDelegate:(NSObject<AdjustCommandDelegate> *)commandDelegate;
{
    self = [super init];

    _baseUrl = [NSURL URLWithString:baseUrl];
    self.commandDelegate = commandDelegate;
    self.testNames = [[NSMutableString alloc] init];

    _singleThreadExecutor = [[ATLSingleThreadExecutor alloc] init];

    _infoToServer = [[NSMutableDictionary alloc] init];
    
    self.controlClient = [[ATLControlWebSocketClient alloc] init];
    [self.controlClient initializeWebSocketWithControlUrl:controlUrl andTestLibrary:self];
    
    return self;
}

- (void)addTest:(NSString *)testName {
    [self.testNames appendString:testName];

    if (![testName hasSuffix:@";"]) {
        [self.testNames appendString:@";"];
    }
}

- (void)addTestDirectory:(NSString *)testDirectory {
    [self.testNames appendString:testDirectory];

    if (![testDirectory hasSuffix:@"/"] || ![testDirectory hasSuffix:@"/;"]) {
        [self.testNames appendString:@"/"];
    }

    if (![testDirectory hasSuffix:@";"]) {
        [self.testNames appendString:@";"];
    }
}

- (void)startTestSession:(NSString *)clientSdk {
    // reconnect web socket client if disconnected
    [self.controlClient reconnectIfNeeded];
    [self resetTestLibrary];

    __typeof(self) __weak weakSelf = self;
    [self.singleThreadExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf sendTestSessionI:clientSdk];
    }];
}

- (void)resetTestLibrary {
    [self teardown];
    [self initTestLibrary];
}

- (void)teardown {
    [self.singleThreadExecutor clearQueuedBlocks];
    [self clearTest];
}

- (void)clearTest {
    if (self.waitControlQueue != nil) {
        [self.waitControlQueue teardown];
    }
    self.waitControlQueue = nil;
    [self.infoToServer removeAllObjects];
}

- (void) initTestLibrary {
    self.waitControlQueue = [[ATLBlockingQueue alloc] init];
}

// reset for each test
- (void)resetForNextTest {
    [self clearTest];
    [self initTest];
}

- (void)initTest {
    self.waitControlQueue = [[ATLBlockingQueue alloc] init];
}

- (void)addInfoToSend:(nonnull NSString *)key
                value:(nonnull NSString *)value
{
    [self.infoToServer setObject:value forKey:key];
}

- (void)signalEndWaitWithReason:(NSString *)reason {
    [[self waitControlQueue] enqueue:reason];
}

- (void)cancelTestAndGetNext {
    [self resetTestLibrary];

    __typeof(self) __weak weakSelf = self;
    [self.singleThreadExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        ATLHttpRequest *requestData = [[ATLHttpRequest alloc] init];
        requestData.path = [ATLUtilNetworking appendBasePath:strongSelf.currentExtraPath
                                                        path:@"/end_test_read_next"];
        [ATLUtilNetworking sendPostRequest:requestData
                           responseHandler:^(ATLHttpResponse *httpResponse) {
                               [strongSelf readResponse:httpResponse];
                           }];
    }];
}

- (void)sendInfoToServer:(NSString *)basePath {
    ATLHttpRequest * requestData = [[ATLHttpRequest alloc] init];

    requestData.path = [ATLUtil appendBasePath:basePath path:TEST_INFO_PATH];

    if (self.infoToServer) {
        requestData.bodyString = [ATLUtil queryString:self.infoToServer];
    }

    __typeof(self) __weak weakSelf = self;
    [ATLUtilNetworking sendPostRequest:requestData
                       responseHandler:^(ATLHttpResponse *httpResponse)
    {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf.infoToServer removeAllObjects];
        [strongSelf readResponse:httpResponse];
    }];
}

- (void)sendTestSessionI:(NSString *)clientSdk {
    ATLHttpRequest *requestData = [[ATLHttpRequest alloc] init];
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:clientSdk, @"Client-SDK", nil];

    if (self.testNames != nil) {
        [headerFields setObject:self.testNames forKey:@"Test-Names"];
    }

    requestData.headerFields = headerFields;
    requestData.path = @"/init_session";
    
    [ATLUtilNetworking sendPostRequest:requestData
                        responseHandler:^(ATLHttpResponse *httpResponse) {
                            NSString *testSessionId = httpResponse.headerFields[TEST_SESSION_ID_HEADER];
                            [[self controlClient] sendInitTestSessionSignal:testSessionId];
                            [self readResponse:httpResponse];
                        }];
}

- (void)readResponse:(ATLHttpResponse *)httpResponse {
    if (httpResponse == nil) {
        [ATLUtil debug:@"httpResponse is null"];
        return;
    }

    if (! [httpResponse.jsonFoundation isKindOfClass:[NSArray class]]) {
        [ATLUtil debug:@"json response is not an array or is nil"];
        return;
    }
    NSArray *_Nonnull jsonArray = (NSArray *)httpResponse.jsonFoundation;

    __typeof(self) __weak weakSelf = self;

    __block id<AdjustCommandBulkJsonParametersDelegate> _Nullable jsonBulkDelegate =
        self.jsonBulkDelegateWeak;
    if (jsonBulkDelegate != nil) {
        [self.singleThreadExecutor executeInSequenceWithBlock:^{
            __typeof(weakSelf) __strong strongSelf = weakSelf;
            if (strongSelf == nil) { return; }

            [jsonBulkDelegate saveArrayOfCommandsJson:httpResponse.responseString];
        }];
    }

    for (NSUInteger i = 0; jsonArray.count < i; i = i + 1) {
        [self.singleThreadExecutor executeInSequenceWithBlock:^{
            __typeof(weakSelf) __strong strongSelf = weakSelf;
            if (strongSelf == nil) { return; }

            NSDate *timeBefore = [NSDate date];
            [ATLUtil debug:@"time before %@", [ATLUtil formatDate:timeBefore]];

            [strongSelf executeCommandWithTestCommandI:[jsonArray objectAtIndex:i]
                                                 index:i];

            NSDate *timeAfter = [NSDate date];
            [ATLUtil logDebug:@"time after %@", [ATLUtil formatDate:timeAfter]];

            NSTimeInterval timeElapsedSeconds = [timeAfter timeIntervalSinceDate:timeBefore];
            [ATLUtil logDebug:@"seconds elapsed %f", timeElapsedSeconds];
        }];
    }
}

- (void)executeCommandWithTestCommandI:(nonnull NSDictionary *)testCommand
                                 index:(NSUInteger)index
{
    NSString *className = [testCommand objectForKey:@"className"];
    NSString *functionName = [testCommand objectForKey:@"functionName"];
    NSDictionary *params = [testCommand objectForKey:@"params"];
    [ATLUtil debug:@"className: %@, functionName: %@, params: %@",
        className, functionName, params];

    if ([className isEqualToString:TEST_LIBRARY_CLASSNAME]) {
        [self execTestLibraryCommandI:functionName params:params];
        return;
    }

    id<AdjustCommandBulkJsonParametersDelegate> _Nullable jsonBulkDelegate =
        self.jsonBulkDelegateWeak;
    if (jsonBulkDelegate != nil) {
        [jsonBulkDelegate executeCommandInArrayPosition:index];
        return;
    }


    NSObject<AdjustCommandDelegate> *_Nullable localV4CommandDelegate = self.commandDelegate;
    if (localV4CommandDelegate != nil) {
        [self executeCommandInV4Delegate:localV4CommandDelegate
                               className:className
                            functionName:functionName
                                  params:params
                             testCommand:testCommand];
        return;
    }

    id<AdjustCommandDictionaryParametersDelegate> _Nullable dictionaryParametersDelegate =
        self.dictionaryParametersDelegateWeak;
    if (dictionaryParametersDelegate != nil) {
        [dictionaryParametersDelegate executeCommandWithDictionaryParameters:params
                                                                   className:className
                                                                  methodName:functionName];
        return;
    }


    [ATLUtil logError:@"Could not find delegate for command"];
}

- (void)executeCommandInV4Delegate:(nonnull NSObject<AdjustCommandDelegate> *)v4CommandDelegate
                         className:(nullable NSString *)className
                      functionName:(nullable NSString *)functionName
                            params:(nullable NSDictionary *)params
                       testCommand:(nonnull NSDictionary *)testCommand
{
    if ([v4CommandDelegate respondsToSelector:
         @selector(executeCommand:methodName:parameters:)])
    {
        [v4CommandDelegate executeCommand:className
                               methodName:functionName
                               parameters:params];
        return;
    }

    if ([v4CommandDelegate respondsToSelector:
                @selector(executeCommand:methodName:jsonParameters:)])
    {
        NSString *paramsJsonString = [ATLUtil parseDictionaryToJsonString:params];
        [v4CommandDelegate executeCommand:className
                               methodName:functionName
                           jsonParameters:paramsJsonString];

        return;
    }

    if ([v4CommandDelegate respondsToSelector:@selector(executeCommandRawJson:)]) {
        NSString *commandJsonString = [ATLUtil parseDictionaryToJsonString:testCommand];
        [v4CommandDelegate executeCommandRawJson:commandJsonString];

        return;
    }

    [ATLUtil logError:@"Could not find selector for v4 command delegate"];
}

- (void)execTestLibraryCommandI:(NSString *)functionName
                         params:(NSDictionary *)params {
    if ([functionName isEqualToString:@"resetTest"]) {
        [self resetTestI:params];
    } else if ([functionName isEqualToString:@"endTestReadNext"]) {
        [self endTestReadNextI];
    } else if ([functionName isEqualToString:@"endTestSession"]) {
        [self endTestSessionI];
    } else if ([functionName isEqualToString:@"wait"]) {
        [self waitI:params];
    }
}

- (void)resetTestI:(NSDictionary *)params {
    if ([params objectForKey:@"extraPath"]) {
        self.currentExtraPath = [params objectForKey:@"extraPath"][0];
        [ATLUtil debug:@"current extra path %@", self.currentExtraPath];
    }
    if ([params objectForKey:@"testName"]) {
        self.currentTestName = [params objectForKey:@"testName"][0];
        [ATLUtil debug:@"current test name %@", self.currentTestName];
    }
    [self resetForNextTest];
}

- (void)endTestReadNextI {
    ATLHttpRequest *requestData = [[ATLHttpRequest alloc] init];
    requestData.path = [ATLUtilNetworking appendBasePath:self.currentExtraPath
                                                    path:@"/end_test_read_next"];
    [ATLUtilNetworking sendPostRequest:requestData
                       responseHandler:^(ATLHttpResponse *httpResponse) {
                           [self readResponse:httpResponse];
                       }];
}

- (void)endTestSessionI {
    [self teardown];
    if (exitAfterEnd) {
        exit(0);
    }
}

- (void)doNotExitAfterEnd {
    exitAfterEnd = false;
}

- (void)waitI:(NSDictionary *)params {
    if ([params objectForKey:WAIT_FOR_CONTROL]) {
        NSString *waitExpectedReason = [params objectForKey:WAIT_FOR_CONTROL][0];
        [ATLUtil debug:@"wait for %@", waitExpectedReason];
        NSString *endReason = [self.waitControlQueue dequeue];
        [ATLUtil debug:@"wait ended due to %@", endReason];
    }
    if ([params objectForKey:WAIT_FOR_SLEEP]) {
        NSString *millisToSleepS = [params objectForKey:WAIT_FOR_SLEEP][0];
        [ATLUtil debug:@"sleep for %@", millisToSleepS];
        double secondsToSleep = [millisToSleepS intValue] / 1000;
        [NSThread sleepForTimeInterval:secondsToSleep];
        [ATLUtil debug:@"sleep ended"];
    }
}

@end
