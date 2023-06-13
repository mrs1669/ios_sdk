//
//  ADJAsaAttributionController.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAsaAttributionController.h"

#import "ADJUtilSys.h"
#import "ADJAsaAttributionStateStorageAction.h"
#import "ADJClickPackageData.h"
#import "ADJConstantsParam.h"
#import "ADJUtilMap.h"
#import "ADJUtilR.h"
#import "ADJUtilObj.h"
#import "ADJUtilF.h"
#import "ADJUtilJson.h"
#import "ADJAdjustLogMessageData.h"
#import "ADJConsoleLogger.h"

//#import "ADJResultFail.h"

#pragma mark Fields

@interface ADJAsaAttributionController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJLogQueueController *logQueueControllerWeak;
@property (nullable, readonly, weak, nonatomic) ADJMainQueueController *mainQueueControllerWeak;
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nonnull, readonly, strong, nonatomic) ADJAsaAttributionStateStorage *storage;
@property (nonnull, readonly, strong, nonatomic) ADJClock *clock;
@property (nonnull, readonly, strong, nonatomic) ADJExternalConfigData *asaAttributionConfig;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (assign, readwrite, nonatomic) BOOL canReadToken;
@property (assign, readwrite, nonatomic) BOOL isFinishedReading;
@property (assign, readwrite, nonatomic) BOOL isInDelay;
@property (assign, readwrite, nonatomic) BOOL mainQueueContainsAsaClickPackage;

@end

@implementation ADJAsaAttributionController
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    asaAttributionStateStorage:(nonnull ADJAsaAttributionStateStorage *)asaAttributionStateStorage
    clock:(nonnull ADJClock *)clock
    clientConfigData:(nonnull ADJClientConfigData *)clientConfigData
    asaAttributionConfig:(nonnull ADJExternalConfigData *)asaAttributionConfig
    logQueueController:(nonnull ADJLogQueueController *)logQueueController
    mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
    adjustAttributionStateStorage:
        (nonnull ADJAttributionStateStorage *)adjustAttributionStateStorage
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"AsaAttributionController"];
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _logQueueControllerWeak = logQueueController;
    _mainQueueControllerWeak = mainQueueController;
    _storage = asaAttributionStateStorage;
    _clock = clock;
    _asaAttributionConfig = asaAttributionConfig;

    _executor = [threadExecutorFactory
                 createSingleThreadExecutorWithLoggerFactory:loggerFactory
                 sourceLoggerName:self.logger.name];

    _canReadToken = [ADJAsaAttributionController
                     initialCanReadTokenWithClientConfig:clientConfigData
                     asaAttributionConfig:asaAttributionConfig
                     logger:self.logger];

    _isFinishedReading = NO;

    _isInDelay = NO;

    ADJResult<ADJNonNegativeInt *> *_Nonnull asaClickCountResult =
        [mainQueueController.trackedPackages asaClickCount];
    _mainQueueContainsAsaClickPackage = asaClickCountResult.value != nil
        && asaClickCountResult.value.uIntegerValue > 0;

    return self;
}

+ (BOOL)initialCanReadTokenWithClientConfig:(ADJClientConfigData *)clientConfigData
                       asaAttributionConfig:(nonnull ADJExternalConfigData *)asaAttributionConfig
                                     logger:(nonnull ADJLogger *)logger {
    BOOL canReadTokenFromClient = ! clientConfigData.doNotReadAsaAttribution;

    BOOL canTryToReadAtLeastOnce =
    asaAttributionConfig.libraryMaxReadAttempts != nil
    && ! [asaAttributionConfig.libraryMaxReadAttempts isZero];

    BOOL hasTimeoutToRead =
    asaAttributionConfig.timeoutPerAttempt != nil
    && ! [asaAttributionConfig.timeoutPerAttempt isZero];

    BOOL canReadTokenFromConfig = canTryToReadAtLeastOnce && hasTimeoutToRead;

    BOOL hasMininumOsVersion;
    if (@available(iOS 14.3, tvOS 14.3, macOS 11.1, macCatalyst 14.3, *)) {
        hasMininumOsVersion = YES;
    } else {
        hasMininumOsVersion = NO;
    }

    [logger debugWithMessage:@"Initial canReadToken values"
                builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
     {
        [logBuilder withKey:@"canReadTokenFromClient"
                      stringValue:[ADJUtilF boolFormat:canReadTokenFromClient]];
        [logBuilder withKey:@"canReadTokenFromConfig"
                stringValue:[ADJUtilF boolFormat:canReadTokenFromConfig]];
        [logBuilder withKey:@"hasMininumOsVersion"
                stringValue:[ADJUtilF boolFormat:hasMininumOsVersion]];
    }];

    return canReadTokenFromClient && canReadTokenFromConfig && hasMininumOsVersion;
}

#pragma mark - ADJKeepAlivePingSubscriber
- (void)didPingKeepAliveInActiveSession {
    if (! self.canReadToken || self.isFinishedReading) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                          from:@"keep alive ping"
                                         block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf processAsaAttibutionWithAttemptsLeft:
         strongSelf.asaAttributionConfig.libraryMaxReadAttempts];
    }];
}

#pragma mark - ADJSdkStartSubscriber
- (void)ccSdkStart {
    if (! self.canReadToken || self.isFinishedReading) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                          from:@"sdk start"
                                         block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf processAsaAttibutionWithAttemptsLeft:
         strongSelf.asaAttributionConfig.libraryMaxReadAttempts];
    }];
}

#pragma mark - ADJSdkResponseSubscriber
- (void)didReceiveSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    if (sdkResponseData.shouldRetry) {
        return;
    }

    if (! [ADJMainQueueTrackedPackages isAsaClickPackageWithData:sdkResponseData.sourcePackage]) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                          from:@"received asa click response"
                                         block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleAsaClickPackage];
    }];
}

#pragma mark - ADJAttributionSubscriber
- (void)attributionWithStateData:(nonnull ADJAttributionStateData *)attributionStateData {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                          from:@"handle adjust attribution"
                                         block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleAdjustAttributionStateData:attributionStateData];
    }];
}

#pragma mark - ADJSdkPackageSendingSubscriber
- (void)willSendSdkPackageWithData:(nonnull id<ADJSdkPackageData>)sdkPackageData
                   parametersToAdd:(nonnull ADJStringMapBuilder *)parametersToAdd
                      headersToAdd:(nonnull ADJStringMapBuilder *)headersToAdd
{
    if (! [ADJMainQueueTrackedPackages isAsaClickPackageWithData:sdkPackageData]) {
        return;
    }

    ADJAsaAttributionStateData *_Nonnull stateData = [self.storage readOnlyStoredDataValue];

    [ADJUtilMap
     injectIntoPackageParametersWithBuilder:parametersToAdd
     key:ADJParamAsaAttributionTokenKey
     packageParamValueSerializable:stateData.cachedToken];

    [ADJUtilMap
     injectIntoPackageParametersWithBuilder:parametersToAdd
     key:ADJParamAsaAttributionReadAtKey
     packageParamValueSerializable:stateData.cacheReadTimestamp];
}

#pragma mark Internal Methods
- (void)handleAdjustAttributionStateData:
    (nonnull ADJAttributionStateData *)adjustAttributionStateData
{
    ADJAsaAttributionStateData *_Nonnull currentStateData = [self.storage readOnlyStoredDataValue];

    if (currentStateData.hasReceivedAdjustAttribution) { return; }
    if (! [adjustAttributionStateData hasAcceptedResponseFromBackend]) { return; }

    [self.storage updateWithNewDataValue:[currentStateData withHasReceivedAdjustAttribution]];
}

- (void)handleAsaClickPackage {
    self.mainQueueContainsAsaClickPackage = NO;

    ADJAsaAttributionStateData *_Nonnull currentStateData = [self.storage readOnlyStoredDataValue];

    // no need to update, since it already received a asa click previously
    if (currentStateData.hasReceivedValidAsaClickResponse) {
        return;
    }

    [self.storage updateWithNewDataValue:[currentStateData withHasReceivedValidAsaClickResponse]];
}

- (void)processAsaAttibutionWithAttemptsLeft:(nullable ADJNonNegativeInt *)attemptsLeft {
    if (self.isInDelay || ! self.canReadToken) {
        return;
    }

    ADJAsaAttributionStateData *_Nonnull stateData = [self.storage readOnlyStoredDataValue];

    BOOL hasFinishedReadingAsaAttribution =
        stateData.hasReceivedAdjustAttribution && stateData.hasReceivedValidAsaClickResponse;

    [self.logger debugDev:@"Has Finished Reading Asa Attribution?"
                     key1:@"hasReceivedAdjustAttribution"
             stringValue1:[ADJUtilF boolFormat:stateData.hasReceivedAdjustAttribution]
                     key2:@"hasReceivedValidAsaClickResponse"
             stringValue2:[ADJUtilF boolFormat:stateData.hasReceivedValidAsaClickResponse]];

    if (hasFinishedReadingAsaAttribution) {
        self.isFinishedReading = YES;
        return;
    }

    BOOL stateDataUpdated = [self refreshTokenWithAttemptsLeft:attemptsLeft];
    if (stateDataUpdated) {
        stateData = [self.storage readOnlyStoredDataValue];
    }

    [self trackAsaClickWithStateData:stateData];
}

- (BOOL)refreshTokenWithAttemptsLeft:(nullable ADJNonNegativeInt *)attemptsLeft {
    if (attemptsLeft == nil) {
        [self.logger debugDev:@"Cannot refresh token with invalid number of attempts left"];
        return NO;
    }

    if (attemptsLeft.uIntegerValue == 0) {
        [self.logger debugDev:@"No more attempts left to refresh token"];
        return NO;
    }

    ADJAsaAttributionStateData *_Nonnull currentStateData = [self.storage readOnlyStoredDataValue];

    ADJResult<ADJNonEmptyString *> *_Nonnull asaAttributionTokenResult =
        [self readAsaAttributionToken];

    if (asaAttributionTokenResult.fail != nil) {
        [self.logger debugDev:@"Failed to read asa attribution token"
                  resultFail:asaAttributionTokenResult.fail
                    issueType:ADJIssueExternalApi];

        [self retryWithAttemptsLeft:attemptsLeft];
    }

    BOOL tokenUpdated = NO;
    BOOL errorMessageUpdated = NO;

    ADJNonEmptyString *_Nullable tokenToWrite;
    ADJTimestampMilli *_Nullable timestampToWrite;

    BOOL hasReadTokenUpdatedCacheOne =
        asaAttributionTokenResult.fail == nil
        && ! [ADJUtilObj objectEquals:asaAttributionTokenResult.value
                                other:currentStateData.cachedToken];

    if (hasReadTokenUpdatedCacheOne) {
        tokenToWrite = asaAttributionTokenResult.value;

        ADJResult<ADJTimestampMilli *> *_Nonnull nowResult =
            [self.clock nonMonotonicNowTimestamp];
        if (nowResult.fail != nil) {
            [self.logger debugDev:@"Failed now timestamp when refreshing token"
                       resultFail:nowResult.fail
                        issueType:ADJIssueExternalApi];
            timestampToWrite = nil;
        } else {
            timestampToWrite = nowResult.value;
        }

        tokenUpdated = YES;
    } else {
        tokenToWrite = currentStateData.cachedToken;
        timestampToWrite = currentStateData.cacheReadTimestamp;
    }

    ADJNonEmptyString *_Nullable errorReasonToWrite;

    if (asaAttributionTokenResult.fail != nil) {
        ADJNonEmptyString *_Nullable errorMessage =
            [self toJsonStringWithFail:asaAttributionTokenResult.fail];

        if (errorMessage != nil &&
            ! [ADJUtilObj objectEquals:errorMessage
                                 other:currentStateData.errorReason])
        {
            errorReasonToWrite = errorMessage;
            errorMessageUpdated = YES;

            [self trackNewErrorReason:errorMessage];
        }
    }
    if (! errorMessageUpdated) {
        errorReasonToWrite = currentStateData.errorReason;
    }

    if (! (tokenUpdated || errorMessageUpdated)) {
        return NO;
    }

    [self.storage updateWithNewDataValue:[currentStateData withToken:tokenToWrite
                                                           timestamp:timestampToWrite
                                                         errorReason:errorReasonToWrite]];

    return YES;
}
- (nullable ADJNonEmptyString *)toJsonStringWithFail:(nonnull ADJResultFail *)resultFail {
    ADJOptionalFails<NSString *> *_Nonnull jsonStringOptFails =
        [ADJUtilJson toStringFromDictionary:[resultFail toJsonDictionary]];
    for (ADJResultFail *_Nonnull optFail in jsonStringOptFails.optionalFails) {
        [self.logger debugDev:@"Issue while converting fail to string"
                   resultFail:optFail
                    issueType:ADJIssueLogicError];
    }

    ADJResult<ADJNonEmptyString *> *_Nonnull jsonStringResult =
        [ADJNonEmptyString instanceFromString:jsonStringOptFails.value];
    if (jsonStringResult.fail != nil) {
        [self.logger debugDev:@"Invalid json string from fail"
                   resultFail:jsonStringResult.fail
                    issueType:ADJIssueLogicError];

        return nil;
    }

    return jsonStringResult.value;
}

// TODO return Result
//- (nullable ADJInputLogMessageData *)readAsaAttributionTokenWithWO:
- (nonnull ADJResult<ADJNonEmptyString *> *)readAsaAttributionToken {
    // any error that happens before trying to read the Asa Attribution Token
    //  won't change during the current app execution,
    //  so it can be assumed that the token can't be read
    if (self.asaAttributionConfig.timeoutPerAttempt == nil) {
        self.canReadToken = NO;
        return [ADJResult failWithMessage:@"Cannot attempt to read token without a timeout"];
    }

    Class _Nullable classFromName = NSClassFromString(@"AAAttribution");
    if (classFromName == nil) {
        self.canReadToken = NO;
        return [ADJResult failWithMessage:@"Could not detect AAAttribution class"];
    }

    SEL _Nullable methodSelector = NSSelectorFromString(@"attributionTokenWithError:");
    if (! [classFromName respondsToSelector:methodSelector]) {
        self.canReadToken = NO;
        return [ADJResult failWithMessage:@"Could not detect attributionTokenWithError: method"];
    }

    IMP _Nullable methodImplementation = [classFromName methodForSelector:methodSelector];

    if (! methodImplementation) {
        self.canReadToken = NO;
        return [ADJResult failWithMessage:
                @"Could not detect attributionTokenWithError: method implementation"];
    }

    __block NSString* (*func)(id, SEL, NSError **) = (void *)methodImplementation;

    __block NSError *error = nil;

    __block NSString *_Nullable asaAttributionTokenString;

    ADJResultFail *_Nullable execFail  =
        [self.executor
         executeSynchronouslyFrom:@"read AAAttribution attributionTokenWithError with timeout"
         timeout:self.asaAttributionConfig.timeoutPerAttempt
         block:^{
            // TODO: cache in a dispatch_once: methodImplementation, classFromName and methodSelector
            asaAttributionTokenString = func(classFromName, methodSelector, &error);
        }];

    if (execFail != nil) {
        return [ADJResult failWithMessage:
                @"Could not make or finish the [AAAttribution attributionTokenWithError:] call"
                                        key:@"exec fail"
                                  otherFail:execFail];
    }

    if (asaAttributionTokenString != nil) {
        ADJResult<ADJNonEmptyString *> *_Nonnull asaAttributionTokenResult =
            [ADJNonEmptyString instanceFromString:asaAttributionTokenString];
        if (asaAttributionTokenResult.fail != nil) {
            return [ADJResult
                    failWithMessage:@"Cannot parse asaAttributionToken"
                    key:@"neString fail"
                    otherFail:asaAttributionTokenResult.fail];
        } else {
            return asaAttributionTokenResult;
        }
    }

    if (error != nil) {
        /** typedef NS_ERROR_ENUM(AAAttributionErrorDomain, AAAttributionErrorCode)
         {
         AAAttributionErrorCodeNetworkError = 1,
         AAAttributionErrorCodeInternalError = 2,
         AAAttributionErrorCodePlatformNotSupported = 3
         } API_AVAILABLE(ios(14.3), macosx(11.1), tvos(14.3));
         */
        // AAAttributionError.platformNotSupported == 3 implies that it won't change
        if (error.code == 3) {
            self.canReadToken = NO;
        }
    }

    return [ADJResult failWithMessage:@"from [AAAttribution attributionTokenWithError:]"
                                error:error];
}

- (void)retryWithAttemptsLeft:(nonnull ADJNonNegativeInt *)attemptsLeft {
    if ([attemptsLeft isZero]) {
        [self.logger debugDev:@"Cannot attempt to retry with zero attempts left"];
        return;
    }

    NSUInteger nextNumberOfAttemptsLeft = attemptsLeft.uIntegerValue - 1;
    if (nextNumberOfAttemptsLeft == 0) {
        [self.logger debugDev:@"Cannot attempt to retry after it was left with zero attempts"];
        return;
    }

    if (! self.canReadToken) {
        return;
    }

    if (self.asaAttributionConfig.delayBetweenAttempts == nil) {
        return;
    }

    self.isInDelay = YES;

    __typeof(self) __weak weakSelf = self;
    [self.executor scheduleInSequenceWithLogger:self.logger
                                           from:@"retry asa attribution"
                                 delayTimeMilli:self.asaAttributionConfig.delayBetweenAttempts
                                          block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        strongSelf.isInDelay = NO;

        [strongSelf processAsaAttibutionWithAttemptsLeft:
         [[ADJNonNegativeInt alloc] initWithUIntegerValue:nextNumberOfAttemptsLeft]];
    }];
}

- (void)trackAsaClickWithStateData:(nonnull ADJAsaAttributionStateData *)stateData {
    if (self.mainQueueContainsAsaClickPackage) {
        [self.logger debugDev:
         @"Does not need to track asa click package since the main queue already contains one"];
        return;
    }

    if (stateData.cachedToken == nil) {
        [self.logger debugDev:@"Cannot track asa click without a read token"];
        return;
    }

    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger debugDev:@"Cannot track asa click without a reference to package builder"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger debugDev:
         @"Cannot track asa click without a reference to main queue controller"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJClickPackageData *_Nonnull clickPackage =
        [sdkPackageBuilder buildAsaAttributionClickWithToken:stateData.cachedToken
                                 asaAttributionReadTimestamp:stateData.cacheReadTimestamp];

    [mainQueueController addClickPackageToSendWithData:clickPackage
                                   sqliteStorageAction:nil];

    self.mainQueueContainsAsaClickPackage = YES;
}

- (void)trackNewErrorReason:(nonnull ADJNonEmptyString *)errorMessage {
    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger debugDev:
         @"Cannot track new error reason without a reference to package builder"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJLogQueueController *_Nullable logQueueController = self.logQueueControllerWeak;
    if (logQueueController == nil) {
        [self.logger debugDev:
         @"Cannot track new error reason without a reference to log queue controller"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJLogPackageData *_Nonnull logPackage =
    [sdkPackageBuilder buildLogPackageWithMessage:errorMessage
                                         logLevel:ADJAdjustLogLevelError
                                        logSource:self.logger.name];

    [logQueueController addLogPackageDataToSendWithData:logPackage];
}

@end
