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
                            adjustUrlStrategy:(nullable ADJNonEmptyString *)adjustUrlStrategy
                     clientCustomEndpointData:(nullable ADJClientCustomEndpointData *)clientCustomEndpointData {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:[NSString stringWithFormat:@"%@-SdkPackageSender",
                                         sourceDescription]];
    _executor = [threadExecutorFactory createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                     sourceDescription:self.source];
    _sdkPackageSendingCollectorWeak = sdkPackageSendingCollector;
    _sdkResponseCollectorWeak = sdkResponseCollector;
    _timeoutMilli = networkEndpointData.timeoutMilli;

    _sdkPackageUrlBuilder = [[ADJSdkPackageUrlBuilder alloc]
                             initWithUrlOverwrite:networkEndpointData.urlOverwrite
                             extraPath:networkEndpointData.extraPath
                             adjustUrlStrategy:adjustUrlStrategy
                             clientCustomEndpointUrl:clientCustomEndpointData != nil ?
                             clientCustomEndpointData.url : nil];

    NSURLSessionConfiguration *_Nonnull sessionConfiguration =
    [NSURLSessionConfiguration defaultSessionConfiguration];

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
    //previousErrorMessages:nil];

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
    id<ADJSdkPackageSendingSubscriber> _Nullable sdkPackageSendingCollector =
    self.sdkPackageSendingCollectorWeak;

    if (sdkPackageSendingCollector == nil) {
        return nil;
    }

    ADJStringMapBuilder *_Nonnull headersToAdd =
    [[ADJStringMapBuilder alloc] initWithEmptyMap];

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
                         sdkResponseBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder {
    for (NSString *_Nonnull key in parametersToInject.map) {
        ADJNonEmptyString *_Nonnull value = [parametersToInject.map valueForKey:key];

        NSString *_Nullable escapedKey =
        [ADJUtilF urlReservedEncodeWithSpaceAsPlus:key];

        if (escapedKey == nil) {
            [sdkResponseBuilder
             logErrorWithLogger:self.logger
             nsError:nil
             errorMessage:[NSString stringWithFormat:
                           @"Could not inject url escaped key with key/value pair: %@, %@",
                           key, value]];
            continue;
        }

        NSString *_Nullable escapeValue =
        [ADJUtilF urlReservedEncodeWithSpaceAsPlus:value.stringValue];

        if (escapeValue == nil) {
            [sdkResponseBuilder
             logErrorWithLogger:self.logger
             nsError:nil
             errorMessage:[NSString stringWithFormat:
                           @"Could not inject url escaped value with key/value pair: %@, %@",
                           key, value]];
            continue;
        }

        NSString *_Nonnull encodedPair =
        [NSString stringWithFormat:@"%@=%@", escapedKey, escapeValue];

        [escapedPairsArray addObject:encodedPair];
    }
}

- (void)sendWithUrlRequest:(nonnull NSURLRequest *)urlRequest
        sdkResponseBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder
{
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

    [sdkResponseBuilder logErrorWithLogger:self.logger
                                   nsError:nil
                              errorMessage:timedOut ? @"Request timeout" : @"Unexpected wait end"];

    [self retryOrReturnWithSdkResponseBuilder:sdkResponseBuilder];
}

- (void)handleRequestCallbackWithData:(nullable NSData *)data
                             response:(nullable NSURLResponse *)response
                                error:(nullable NSError *)error
                   sdkResponseBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder
{
    if (error != nil) {
        [sdkResponseBuilder logErrorWithLogger:self.logger
                                       nsError:error
                                  errorMessage:@"Sending request error"];
        return;
    }

    if (data == nil) {
        [sdkResponseBuilder logErrorWithLogger:self.logger
                                       nsError:nil
                                  errorMessage:@"Cannot read data from request"];
        return;
    }

    NSString *_Nullable responseString = [ADJUtilF jsonDataFormat:data];

    if (responseString != nil) {
        [self.logger debugDev:@"Server with response"
                          key:@"raw response"
                        value:responseString];
    } else {
        [self.logger debugDev:@"Without server response"];
    }

    [self injectJsonWithResponseData:data
                  sdkResponseBuilder:sdkResponseBuilder];
}

- (void)injectJsonWithResponseData:(nonnull NSData *)responseData
                sdkResponseBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder {
    NSError *jsonError = nil;

    id _Nullable responseJsonFoundationObject =
    [ADJUtilConv convertToJsonFoundationValueWithJsonData:responseData
                                                 errorPtr:&jsonError];

    if (jsonError != nil) {
        [sdkResponseBuilder logErrorWithLogger:self.logger
                                       nsError:jsonError
                                  errorMessage:@"Parsing json response"];
        return;
    }

    if (responseJsonFoundationObject == nil
        || ! [responseJsonFoundationObject isKindOfClass:[NSDictionary class]])
    {
        [sdkResponseBuilder
         logErrorWithLogger:self.logger
         nsError:nil
         errorMessage:[NSString stringWithFormat:
                       @"Parsed JSON Data is not of expected NSDictionary type, but of %@",
                       NSStringFromClass([responseJsonFoundationObject class])]];
        return;
    }

    sdkResponseBuilder.jsonDictionary = (NSDictionary *)responseJsonFoundationObject;
}

- (void)retryOrReturnWithSdkResponseBuilder:
(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder {
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
    id<ADJSdkResponseData> _Nonnull sdkResponseData =
    [sdkResponseBuilder buildSdkResponseDataWithLogger:self.logger];

    [sdkResponseBuilder.sourceCallback sdkResponseCallbackWithResponseData:sdkResponseData];

    id<ADJSdkResponseSubscriber> _Nullable sdkResponseCollector = self.sdkResponseCollectorWeak;
    if (sdkResponseCollector != nil) {
        [sdkResponseCollector didReceiveSdkResponseWithData:sdkResponseData];
    }
}

- (BOOL)shouldRetryToSendWithResponseBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseBuilder {
    if ([sdkResponseBuilder didReceiveJsonResponse]) {
        [self.logger debugDev:@"Received network request with current url strategy"];
        [self.sdkPackageUrlBuilder resetAfterNetworkNotFailing];
        return NO;
    }

    if ([sdkResponseBuilder retries] >
        [self.sdkPackageUrlBuilder urlCountWithPath:sdkResponseBuilder.sourcePackage.path])
    {
        [sdkResponseBuilder
         logErrorWithLogger:self.logger
         nsError:nil
         errorMessage:
             @"Cannot retry a bigger number of times than the number of possible urls"];

        return NO;
    }

    if ([self.sdkPackageUrlBuilder shouldRetryAfterNetworkFailure]) {
        [sdkResponseBuilder
         logErrorWithLogger:self.logger
         nsError:nil
         errorMessage:@"Failed with current url strategy, but it will retry with new"];
        return YES;
    }

    [sdkResponseBuilder
     logErrorWithLogger:self.logger
     nsError:nil
     errorMessage:@"Failed with current url strategy and it will not retry"];

    //  Stop retrying with different type and return to caller
    return NO;
}

@end


