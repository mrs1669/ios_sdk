//
//  ADJSdkPackageSender.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkPackageSender.h"

#import "ADJSdkPackageUrlBuilder.h"
#import "ADJSdkResponseDataBuilder.h"
#import "ADJUtilF.h"
#import "ADJUtilConv.h"
#import "ADJUtilSys.h"
#import "ADJSdkPackageSenderPinningDelegate.h"
#import "ADJTimerOnce.h"
#import "ADJAtomicBoolean.h"
#import "ADJConstantsSys.h"

#pragma mark Fields
@interface ADJSdkPackageSender ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) id<ADJSdkPackageSendingSubscriber> sdkPackageSendingCollectorWeak;
@property (nullable, readonly, weak, nonatomic) id<ADJSdkResponseSubscriber> sdkResponseCollectorWeak;
@property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *timeoutMilli;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageUrlBuilder *sdkPackageUrlBuilder;
@property (nonnull, readonly, strong, nonatomic) NSURLSession *urlSession;
@property (nullable, readonly, strong, nonatomic) ADJSdkPackageSenderPinningDelegate *sdkPackageSenderPinningDelegate;
@end

@implementation ADJSdkPackageSender
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sourceDescription:(nonnull NSString *)sourceDescription
                        threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
                   sdkPackageSendingCollector:(nonnull id<ADJSdkPackageSendingSubscriber>)sdkPackageSendingCollector
                         sdkResponseCollector:(nonnull id<ADJSdkResponseSubscriber>)sdkResponseCollector
                          networkEndpointData:(nonnull ADJNetworkEndpointData *)networkEndpointData
                        urlStrategyBaseDomain:(nullable ADJNonEmptyString *)urlStrategyBaseDomain
                                dataResidency:(nullable AdjustDataResidency)dataResidency
                     clientCustomEndpointData:(nullable ADJClientCustomEndpointData *)clientCustomEndpointData {

    self = [super initWithLoggerFactory:loggerFactory
                                 source:[NSString stringWithFormat:@"%@-Sender",
                                         sourceDescription]];
    _executor = [threadExecutorFactory createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                                 sourceDescription:self.source];
    _sdkPackageSendingCollectorWeak = sdkPackageSendingCollector;
    _sdkResponseCollectorWeak = sdkResponseCollector;
    _timeoutMilli = networkEndpointData.timeoutMilli;

    _sdkPackageUrlBuilder = [[ADJSdkPackageUrlBuilder alloc]
                             initWithUrlOverwrite:networkEndpointData.urlOverwrite
                             extraPath:networkEndpointData.extraPath
                             urlStrategyBaseDomain:urlStrategyBaseDomain
                             dataResidency:dataResidency
                             clientCustomEndpointUrl:clientCustomEndpointData != nil ? clientCustomEndpointData.url : nil];

    NSURLSessionConfiguration *_Nonnull sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];

    if (clientCustomEndpointData != nil && clientCustomEndpointData.publicKeyHash != nil) {
        _sdkPackageSenderPinningDelegate =
        [[ADJSdkPackageSenderPinningDelegate alloc]
         initWithLoggerFactory:loggerFactory
         publicKeyHash:clientCustomEndpointData.publicKeyHash];

        _urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                    delegate:self.sdkPackageSenderPinningDelegate
                                               delegateQueue:nil];
    } else {
        _sdkPackageSenderPinningDelegate = nil;
        _urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }

    return self;
}

#pragma mark Public API
- (void)sendSdkPackageWithData:(nonnull id<ADJSdkPackageData>)sdkPackageData
             sendingParameters:(nonnull ADJStringMapBuilder *)sendingParameters
              responseCallback:(nonnull id<ADJSdkResponseCallbackSubscriber>)responseCallback {
    ADJSdkResponseDataBuilder *_Nonnull sdkResponseDataBuilder =
    [[ADJSdkResponseDataBuilder alloc] initWithSourceSdkPackage:sdkPackageData
                                              sendingParameters:sendingParameters
                                                 sourceCallback:responseCallback];

    [self sendSdkPackageWithBuilder:sdkResponseDataBuilder];
}

- (nonnull NSString *)defaultTargetUrl {
    return [self.sdkPackageUrlBuilder defaultTargetUrl];
}

#pragma mark Internal Methods
- (void)sendSdkPackageWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeAsyncWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        NSURLRequest *_Nonnull urlRequest =
        [strongSelf buildUrlRequestWithBuilder:sdkResponseDataBuilder];

        [strongSelf sendWithUrlRequest:urlRequest
                    sdkResponseBuilder:sdkResponseDataBuilder];
    } source:@"send sdk package"];
}

- (nonnull NSURLRequest *)buildUrlRequestWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder {
    id<ADJSdkPackageData> _Nonnull sdkPackageData = sdkResponseBuilder.sourcePackage;

    ADJStringMap *_Nullable headersToAdd =
    [self
     publishPackageSendingAngGetHeadersToSendWithSdkPackage:sdkPackageData
     sendingParameters:sdkResponseBuilder.sendingParameters];

    NSMutableURLRequest *_Nonnull urlRequest =
    [self buildMutableUrlRequestWithSdkPackageData:sdkPackageData
                                sdkResponseBuilder:sdkResponseBuilder];

    if (headersToAdd != nil) {
        for (NSString *_Nonnull headerKey in headersToAdd.map) {
            ADJNonEmptyString *_Nonnull headerValue = [headersToAdd.map objectForKey:headerKey];

            [urlRequest setValue:headerValue.stringValue forHTTPHeaderField:headerKey];
        }
    }

    return urlRequest;
}

- (nullable ADJStringMap *)publishPackageSendingAngGetHeadersToSendWithSdkPackage:(nonnull id<ADJSdkPackageData>)sdkPackageData
                                                                sendingParameters:(nonnull ADJStringMapBuilder *)sendingParameters {
    id<ADJSdkPackageSendingSubscriber> _Nullable sdkPackageSendingCollector = self.sdkPackageSendingCollectorWeak;
    
    if (sdkPackageSendingCollector == nil) {
        return nil;
    }
    
    ADJStringMapBuilder *_Nonnull headersToAdd = [[ADJStringMapBuilder alloc] initWithEmptyMap];
    
    [sdkPackageSendingCollector willSendSdkPackageWithData:sdkPackageData
                                           parametersToAdd:sendingParameters
                                              headersToAdd:headersToAdd];

    if ([headersToAdd isEmpty]) {
        return nil;
    }

    return [[ADJStringMap alloc] initWithStringMapBuilder:headersToAdd];
}

- (nonnull NSMutableURLRequest *)buildMutableUrlRequestWithSdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
                                                       sdkResponseBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder {
    NSString *_Nonnull targetUrl =
    [self.sdkPackageUrlBuilder targetUrlWithPath:sdkPackageData.path
                               sendingParameters:sdkResponseBuilder.sendingParameters];

    ADJStringMapBuilder *_Nonnull mergedParametersBuilder =
    [[ADJStringMapBuilder alloc] initWithStringMap:sdkPackageData.parameters];

    [mergedParametersBuilder addAllPairsWithStringMapBuilder:sdkResponseBuilder.sendingParameters];

    ADJStringMap *_Nonnull mergedParameters =
    [[ADJStringMap alloc] initWithStringMapBuilder:mergedParametersBuilder];

    NSMutableArray<NSString *> *_Nonnull escapedPairsArray =
    [NSMutableArray arrayWithCapacity:[mergedParameters countPairs]];

    [self injectUrlEncodedPairsWithParameters:mergedParameters
                            escapedPairsArray:escapedPairsArray
                           sdkResponseBuilder:sdkResponseBuilder];

    NSString *_Nonnull urlString;

    if ([sdkPackageData isPostOrElseGetNetworkMethod]) {
        urlString = [NSString stringWithFormat:@"%@/%@", targetUrl, sdkPackageData.path];
    } else {
        NSString *_Nonnull queryStringParameters =
        [escapedPairsArray componentsJoinedByString:@"&"];

        urlString = [NSString stringWithFormat:@"%@/%@?%@",
                     targetUrl, sdkPackageData.path, queryStringParameters];
    }

    NSMutableURLRequest *_Nonnull request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    request.timeoutInterval = self.timeoutMilli.secondsInterval;
    [request setValue:sdkPackageData.clientSdk forHTTPHeaderField:ADJClientSdkHeaderKey];

    if ([sdkPackageData isPostOrElseGetNetworkMethod]) {
        request.HTTPMethod = @"POST";
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

        NSString *_Nonnull bodyString = [escapedPairsArray componentsJoinedByString:@"&"];

        NSData *_Nonnull bodyData =
        [NSData dataWithBytes:bodyString.UTF8String length:bodyString.length];

        [request setHTTPBody:bodyData];
    } else {
        request.HTTPMethod = @"GET";
    }

    return request;
}

- (void)injectUrlEncodedPairsWithParameters:(nonnull ADJStringMap *)parametersToInject
                          escapedPairsArray:(nonnull NSMutableArray<NSString *> *)escapedPairsArray
                         sdkResponseBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder
{
    for (NSString *_Nonnull key in parametersToInject.map) {
        ADJNonEmptyString *_Nonnull value = [parametersToInject.map valueForKey:key];

        NSString *_Nullable escapedKey =
            [ADJUtilF urlReservedEncodeWithSpaceAsPlus:key];

        if (escapedKey == nil) {
            [self.logger debugDev:@"Could not inject url escaped key"
                              key:@"key"
                            value:key
                        issueType:ADJIssueNetworkRequest];
            continue;
        }

        NSString *_Nullable escapeValue =
            [ADJUtilF urlReservedEncodeWithSpaceAsPlus:value.stringValue];

        if (escapeValue == nil) {
            [self.logger debugDev:@"Could not inject url escaped key"
                              key:@"value"
                            value:value.stringValue
                        issueType:ADJIssueNetworkRequest];
            continue;
        }

        NSString *_Nonnull encodedPair =
        [NSString stringWithFormat:@"%@=%@", escapedKey, escapeValue];

        [escapedPairsArray addObject:encodedPair];
    }
}

- (void)sendWithUrlRequest:(nonnull NSURLRequest *)urlRequest
        sdkResponseBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder {
    __typeof(self) __weak weakSelf = self;

    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block ADJAtomicBoolean *_Nonnull finished =
    [[ADJAtomicBoolean alloc] initSeqCstMemoryOrderWithInitialBoolValue:NO];

    NSURLSessionDataTask *_Nonnull sessionDatatask =
    [self.urlSession dataTaskWithRequest:urlRequest
                       completionHandler:
     ^(NSData * _Nullable data,
       NSURLResponse * _Nullable response,
       NSError * _Nullable error)
     {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        if ([finished testAndSetTrue]) {
            // after timeout
            return;
        }

        dispatch_semaphore_signal(semaphore);

        [strongSelf.executor executeAsyncWithBlock:^{
            [strongSelf handleRequestCallbackWithData:data
                                             response:response
                                                error:error
                                   sdkResponseBuilder:sdkResponseBuilder];

            [strongSelf retryOrReturnWithSdkResponseBuilder:sdkResponseBuilder];
        } source:@"request response"];
    }];
    [sessionDatatask resume];

    intptr_t waitResult =
        dispatch_semaphore_wait
        (semaphore,
         [ADJUtilSys dispatchTimeWithMilli:self.timeoutMilli.millisecondsSpan.uIntegerValue]);

    if ([finished testAndSetTrue]) {
        // after completion handler
        return;
    }

    BOOL timedOut = waitResult != 0;

    [self.logger debugDev:@"Did not succesfully ended waiting for response"
                      key:@"did wait timeout"
                    value:[ADJUtilF boolFormat:timedOut]
                issueType:ADJIssueNetworkRequest];

    [self retryOrReturnWithSdkResponseBuilder:sdkResponseBuilder];
}

+ (nonnull ADJResultNN<NSData *> *)requestResultWithData:(nullable NSData *)data
                                                   error:(nullable NSError *)error
{
    if (data != nil) {
        return [ADJResultNN okWithValue:data];
    }

    return [ADJResultNN failWithMessage:@"dataTaskWithRequest error"
                                  error:error];
}

- (void)handleRequestCallbackWithData:(nullable NSData *)data
                             response:(nullable NSURLResponse *)response
                                error:(nullable NSError *)error
                   sdkResponseBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder
{
    ADJResultNN<NSData *> *_Nonnull callbackDataResult =
        [ADJSdkPackageSender requestResultWithData:data error:error];
    if (callbackDataResult.fail) {
        [self.logger debugDev:@"Cannot process request"
                   resultFail:callbackDataResult.fail
                    issueType:ADJIssueNetworkRequest];
        return;
    }

    ADJResultNN<NSString *> *_Nonnull responseStringResult = [ADJUtilF jsonDataFormat:data];

    if (responseStringResult.fail != nil) {
        [self.logger debugDev:@"Server with response"
                   resultFail:responseStringResult.fail
                    issueType:ADJIssueNetworkRequest];
    } else {
        [self.logger debugDev:@"Server with response"
                          key:@"raw response"
                        value:responseStringResult.value];
    }

    [self injectJsonWithResponseData:callbackDataResult.value
                  sdkResponseBuilder:sdkResponseBuilder];
}

- (void)injectJsonWithResponseData:(nonnull NSData *)responseData
                sdkResponseBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder
{
    ADJResultNN<id> *_Nonnull responseJsonFoundationObjectResult =
        [ADJUtilConv convertToJsonFoundationValueWithJsonData:responseData];

    if (responseJsonFoundationObjectResult.fail != nil) {
        [self.logger debugDev:@"Cannot not parse json response data"
                   resultFail:responseJsonFoundationObjectResult.fail
                    issueType:ADJIssueNetworkRequest];
        return;
    }

    id _Nonnull responseJsonFoundationObject = responseJsonFoundationObjectResult.value;

    if (! [responseJsonFoundationObject isKindOfClass:[NSDictionary class]]) {
        [self.logger debugDev:@"Parsed json response is not of expected type dictionary"
                          key:@"json response type"
                        value:NSStringFromClass([responseJsonFoundationObject class])
                    issueType:ADJIssueNetworkRequest];
        return;
    }

    sdkResponseBuilder.jsonDictionary = (NSDictionary *)responseJsonFoundationObject;
}

- (void)retryOrReturnWithSdkResponseBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder {
    BOOL retryToSend =
        [self shouldRetryToSendWithResponseBuilder:sdkResponseBuilder];

    if (retryToSend) {
        [sdkResponseBuilder incrementRetries];
        [self sendSdkPackageWithBuilder:sdkResponseBuilder];
    } else {
        [self returnWithSdkResponseBuilder:sdkResponseBuilder];
    }
}

- (void)returnWithSdkResponseBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder {
    ADJCollectionAndValue<ADJResultFail *, id<ADJSdkResponseData>> *_Nonnull
    sdkResponseDataResultWithOptionals = [sdkResponseBuilder buildSdkResponseData];

    for (ADJResultFail *_Nonnull optionalFail in sdkResponseDataResultWithOptionals.collection) {
        [self.logger debugDev:
         @"Failed with an optional value when building sdk response from builder"
                   resultFail:optionalFail
                    issueType:ADJIssueNetworkRequest];
    }

    [sdkResponseBuilder.sourceCallback
     sdkResponseCallbackWithResponseData:sdkResponseDataResultWithOptionals.value];

    id<ADJSdkResponseSubscriber> _Nullable sdkResponseCollector = self.sdkResponseCollectorWeak;
    if (sdkResponseCollector != nil) {
        [sdkResponseCollector didReceiveSdkResponseWithData:
         sdkResponseDataResultWithOptionals.value];
    }
}

- (BOOL)shouldRetryToSendWithResponseBuilder:
    (nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder
{
    if ([sdkResponseBuilder didReceiveJsonResponse]) {
        [self.logger debugDev:@"Received network request with current url strategy"];
        [self.sdkPackageUrlBuilder resetAfterNetworkNotFailing];
        return NO;
    }

    // TODO: refac so that the check and the rotation of the urls are not separated
    //  possibly with a domain state class
    NSUInteger urlCount =
        [self.sdkPackageUrlBuilder urlCountWithPath:sdkResponseBuilder.sourcePackage.path];
    if ([sdkResponseBuilder retries] > urlCount) {
        [self.logger debugDev:
         @"Cannot retry a bigger number of times than the number of possible urls"
                         key1:@"retries tried"
                       value1:[ADJUtilF uIntegerFormat:[sdkResponseBuilder retries]]
                         key2:@"url count"
                       value2:[ADJUtilF uIntegerFormat:urlCount]];
        return NO;
    }

    if ([self.sdkPackageUrlBuilder shouldRetryAfterNetworkFailure]) {
        [self.logger debugDev:@"Failed with current url strategy, but it will retry with new"];
        return YES;
    }

    [self.logger debugDev:@"Failed with current url strategy and it will not retry"];

    //  Stop retrying with different type and return to caller
    return NO;
}

@end
