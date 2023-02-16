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
#import "ADJValueWO.h"
#import "ADJUtilObj.h"
#import "ADJAdjustLogMessageData.h"
#import "ADJConsoleLogger.h"

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
    self = [super initWithLoggerFactory:loggerFactory source:@"AsaAttributionController"];
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _logQueueControllerWeak = logQueueController;
    _mainQueueControllerWeak = mainQueueController;
    _storage = asaAttributionStateStorage;
    _clock = clock;
    _asaAttributionConfig = asaAttributionConfig;

    _executor = [threadExecutorFactory createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                                 sourceDescription:self.source];

    _canReadToken = [ADJAsaAttributionController
                     initialCanReadTokenWithClientConfig:clientConfigData
                     asaAttributionConfig:asaAttributionConfig
                     logger:self.logger];

    _isFinishedReading = NO;

    _isInDelay = NO;

    ADJNonNegativeInt *_Nullable asaClickCount =
        [mainQueueController.trackedPackages asaClickCount];
    _mainQueueContainsAsaClickPackage = asaClickCount != nil
        && asaClickCount.uIntegerValue > 0;

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

    [logger debugDev:@"Initial canReadToken values"
       messageParams:[NSDictionary dictionaryWithObjectsAndKeys:
                      @(canReadTokenFromClient).description, @"canReadTokenFromClient",
                      @(canReadTokenFromConfig).description, @"canReadTokenFromConfig",
                      @(hasMininumOsVersion).description, @"hasMininumOsVersion", nil]];

    return canReadTokenFromClient && canReadTokenFromConfig && hasMininumOsVersion;
}

#pragma mark - ADJKeepAlivePingSubscriber
- (void)didPingKeepAliveInActiveSession {
    if (! self.canReadToken || self.isFinishedReading) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf processAsaAttibutionWithAttemptsLeft:
         strongSelf.asaAttributionConfig.libraryMaxReadAttempts];
    } source:@"keep alive ping"];
}

#pragma mark - ADJSdkStartSubscriber
- (void)ccSdkStart {
    if (! self.canReadToken || self.isFinishedReading) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf processAsaAttibutionWithAttemptsLeft:
         strongSelf.asaAttributionConfig.libraryMaxReadAttempts];
    } source:@"sdk start"];
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
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleAsaClickPackage];
    } source:@"received asa click response"];
}

#pragma mark - ADJAttributionSubscriber
- (void)attributionWithStateData:(nonnull ADJAttributionStateData *)attributionStateData
             previousAttribution:(nullable ADJAttributionData *)previousAttribution
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleAdjustAttributionStateData:attributionStateData];
    } source:@"handle adjust attribution"];
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
                   value1:@(stateData.hasReceivedAdjustAttribution).description
                     key2:@"hasReceivedValidAsaClickResponse"
                   value2:@(stateData.hasReceivedValidAsaClickResponse).description];

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

    ADJValueWO<NSString *> *_Nonnull readAsaAttributionTokenWO = [[ADJValueWO alloc] init];

    ADJInputLogMessageData *_Nullable errorLogInput =
        [self readAsaAttributionTokenWithWO:readAsaAttributionTokenWO];

    ADJResultNL<ADJNonEmptyString *> *_Nonnull readAsaAttributionTokenResult =
        [ADJNonEmptyString instanceFromOptionalString:readAsaAttributionTokenWO.changedValue];

    if (readAsaAttributionTokenResult.failMessage != nil) {
        [self.logger debugDev:@"Read invalid asa attribution token"
                  failMessage:readAsaAttributionTokenResult.failMessage
                    issueType:ADJIssueExternalApi];

        [self retryWithAttemptsLeft:attemptsLeft];
    }

    BOOL tokenUpdated = NO;
    BOOL errorMessageUpdated = NO;

    ADJNonEmptyString *_Nullable tokenToWrite;
    ADJTimestampMilli *_Nullable timestampToWrite;

    BOOL hasReadTokenUpdatedCacheOne =
        readAsaAttributionTokenResult.value != nil
        && ! [ADJUtilObj objectEquals:readAsaAttributionTokenResult.value
                                other:currentStateData.cachedToken];

    if (hasReadTokenUpdatedCacheOne) {
        tokenToWrite = readAsaAttributionTokenResult.value;
        timestampToWrite = [self.clock nonMonotonicNowTimestampMilliWithLogger:self.logger];

        tokenUpdated = YES;
    } else {
        tokenToWrite = currentStateData.cachedToken;
        timestampToWrite = currentStateData.cacheReadTimestamp;
    }

    ADJNonEmptyString *_Nullable errorReasonToWrite;

    if (errorLogInput != nil) {
        [self.logger logWithInput:errorLogInput];

        ADJNonEmptyString *_Nonnull errorMessage =
        [[ADJNonEmptyString alloc] initWithConstStringValue:
         [ADJConsoleLogger clientFormatMessage:errorLogInput
                                  isPreSdkInit:NO]];

        if (! [ADJUtilObj objectEquals:errorMessage
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

- (nullable ADJInputLogMessageData *)readAsaAttributionTokenWithWO:
    (nonnull ADJValueWO<NSString *> *)asaAttributionTokenWO
{
    // any error that happens before trying to read the Asa Attribution Token
    //  won't change during the current app execution,
    //  so it can be assumed that the token can't be read
    if (self.asaAttributionConfig.timeoutPerAttempt == nil) {
        self.canReadToken = NO;
        return [[ADJInputLogMessageData alloc]
                initWithMessage:@"Cannot attempt to read token without a timeout"
                level:ADJAdjustLogLevelDebug];
    }

    Class _Nullable classFromName = NSClassFromString(@"AAAttribution");
    if (classFromName == nil) {
        self.canReadToken = NO;
        return [[ADJInputLogMessageData alloc]
                initWithMessage:@"Could not detect AAAttribution class"
                level:ADJAdjustLogLevelDebug];
    }

    SEL _Nullable methodSelector = NSSelectorFromString(@"attributionTokenWithError:");
    if (! [classFromName respondsToSelector:methodSelector]) {
        self.canReadToken = NO;
        return [[ADJInputLogMessageData alloc]
                initWithMessage:@"Could not detect attributionTokenWithError: method"
                level:ADJAdjustLogLevelDebug];
    }

    IMP _Nullable methodImplementation = [classFromName methodForSelector:methodSelector];

    if (! methodImplementation) {
        self.canReadToken = NO;
        return [[ADJInputLogMessageData alloc]
                initWithMessage:@"Could not detect attributionTokenWithError: method implementation"
                level:ADJAdjustLogLevelDebug];
    }

    __block NSString* (*func)(id, SEL, NSError **) = (void *)methodImplementation;

    __block NSError *error = nil;

    __block NSString *_Nullable asaAttributionToken;

    BOOL readAsaAttributionTokenFinishedSuccessfully =
    [self.executor
     executeSynchronouslyWithTimeout:self.asaAttributionConfig.timeoutPerAttempt
     blockToExecute:^{
        // TODO: cache in a dispatch_once: methodImplementation, classFromName and methodSelector
        asaAttributionToken = func(classFromName, methodSelector, &error);
    } source:@"read AAAttribution attributionTokenWithError with timeout"];

    if (! readAsaAttributionTokenFinishedSuccessfully) {
        return [[ADJInputLogMessageData alloc]
                initWithMessage:
                    @"Could not make or finish the [AAAttribution attributionTokenWithError:] call"
                level:ADJAdjustLogLevelDebug];
    }

    if (error) {
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

        return [[ADJInputLogMessageData alloc]
                initWithMessage:@"[AAAttribution attributionTokenWithError:] call"
                level:ADJAdjustLogLevelDebug
                issueType:nil
                nsError:error
                nsException:nil
                messageParams:nil];
    }

    if (asaAttributionToken == nil) {
        return [[ADJInputLogMessageData alloc]
                initWithMessage:@"Returned asa attribution token is nil"
                level:ADJAdjustLogLevelDebug];
    }

    [asaAttributionTokenWO setNewValue:asaAttributionToken];
    return nil;
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
    [self.executor scheduleInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        strongSelf.isInDelay = NO;

        [strongSelf processAsaAttibutionWithAttemptsLeft:
         [[ADJNonNegativeInt alloc] initWithUIntegerValue:nextNumberOfAttemptsLeft]];
    }
                                delayTimeMilli:self.asaAttributionConfig.delayBetweenAttempts
                                        source:@"retry asa attribution"];
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
                                        logSource:self.source];

    [logQueueController addLogPackageDataToSendWithData:logPackage];
}

@end
