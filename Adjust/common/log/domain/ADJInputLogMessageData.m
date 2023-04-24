//
//  ADJInputLogMessageData.m
//  Adjust
//
//  Created by Pedro Silva on 27.10.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJInputLogMessageData.h"

#import "ADJConstants.h"
#import "ADJUtilObj.h"
#import "ADJUtilJson.h"

//#import "ADJResultFail.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSString *message;
 @property (nonnull, readonly, strong, nonatomic) NSString *level;
 @property (nullable, readonly, strong, nonatomic) NSString *callerThreadId;
 @property (nullable, readonly, strong, nonatomic) NSString *fromCaller;
 @property (nullable, readonly, strong, nonatomic) NSString *runningThreadId;
 @property (nullable, readonly, strong, nonatomic) ADJIssue issueType;
 @property (nullable, readonly, strong, nonatomic) ADJResultFail * resultFail;
 @property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, id> *messageParams;
 */

#pragma mark - Public constants
ADJIssue const ADJIssueClientInput = @"client_input";
ADJIssue const ADJIssueUnexpectedInput = @"unexpected_input";
ADJIssue const ADJIssueInvalidInput = @"invalid_input";
ADJIssue const ADJIssueExternalApi = @"external_api";
ADJIssue const ADJIssueLogicError = @"logic_error";
ADJIssue const ADJIssueNetworkRequest = @"network_request";
ADJIssue const ADJIssueNonNativeIntegration = @"non_native_integration";
ADJIssue const ADJIssueNonProdConfig = @"non_prod_config";
ADJIssue const ADJIssuePluginOrigin = @"plugin_origin";
ADJIssue const ADJIssueStorageIo = @"storage_io";
ADJIssue const ADJIssueThreadsAndLocks = @"threads_and_locks";
ADJIssue const ADJIssueWeakReference = @"weak_reference";

@implementation ADJInputLogMessageData
#pragma mark Instantiation
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
{
    return [self initWithMessage:message
                           level:level
                       issueType:nil
                  callerThreadId:nil
                      fromCaller:nil
                 runningThreadId:nil
                      resultFail:nil
                   messageParams:nil
                sdkPackageParams:nil];
}

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
                          messageParams:(nullable NSDictionary<NSString *, id> *)messageParams
{
    return [self initWithMessage:message
                           level:level
                       issueType:nil
                  callerThreadId:nil
                      fromCaller:nil
                 runningThreadId:nil
                      resultFail:nil
                   messageParams:messageParams
                sdkPackageParams:nil];
}

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
                              issueType:(nullable ADJIssue)issueType
                             resultFail:(nullable ADJResultFail *)resultFail
                          messageParams:(nullable NSDictionary<NSString *, id> *)messageParams
{
    return [self initWithMessage:message
                           level:level
                       issueType:issueType
                  callerThreadId:nil
                      fromCaller:nil
                 runningThreadId:nil
                      resultFail:resultFail
                   messageParams:messageParams
                sdkPackageParams:nil];
}

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
                         callerThreadId:(nullable NSString *)callerThreadId
                             fromCaller:(nullable NSString *)fromCaller
                        runningThreadId:(nullable NSString *)runningThreadId
{
    return [self initWithMessage:message
                           level:level
                       issueType:nil
                  callerThreadId:callerThreadId
                      fromCaller:fromCaller
                 runningThreadId:runningThreadId
                      resultFail:nil
                   messageParams:nil
                sdkPackageParams:nil];
}

- (nonnull instancetype)
    initWithMessage:(nonnull NSString *)message
    level:(nonnull ADJAdjustLogLevel)level
    issueType:(nullable ADJIssue)issueType
    callerThreadId:(nullable NSString *)callerThreadId
    fromCaller:(nullable NSString *)fromCaller
    runningThreadId:(nullable NSString *)runningThreadId
    resultFail:(nullable ADJResultFail *)resultFail
    messageParams:(nullable NSDictionary<NSString *, id> *)messageParams
    sdkPackageParams:(nullable NSDictionary<NSString *, NSString *> *)sdkPackageParams
{
    self = [super init];

    _message = message;
    _level = level;
    _issueType = issueType;
    _callerThreadId = callerThreadId;
    _fromCaller = fromCaller;
    _runningThreadId = runningThreadId;
    _resultFail = resultFail;
    _messageParams = messageParams;
    _sdkPackageParams = sdkPackageParams;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

#pragma mark Fields
@interface ADJLogBuilder ()
@property (nonnull, readonly, strong, nonatomic) NSString *message;
@property (nonnull, readonly, strong, nonatomic) NSString *level;
@property (nullable, readwrite, strong, nonatomic) NSString *callerThreadId;
@property (nullable, readwrite, strong, nonatomic) NSString *fromCaller;
@property (nullable, readwrite, strong, nonatomic) NSString *runningThreadId;
@property (nullable, readwrite, strong, nonatomic) ADJIssue issueType;
@property (nullable, readwrite, strong, nonatomic) ADJResultFail * resultFail;
@property (nullable, readwrite, strong, nonatomic)
    NSMutableDictionary<NSString *, id> *messageParams;
@property (nullable, readwrite, strong, nonatomic)
    NSDictionary<NSString *, NSString *> *sdkPackageParams;

@end

@implementation ADJLogBuilder
#pragma mark Instantiation
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
{
    self = [super init];
    _message = message;
    _level = level;

    _callerThreadId = nil;
    _fromCaller = nil;
    _runningThreadId = nil;
    _issueType = nil;
    _resultFail = nil;
    _messageParams = nil;

    return self;
}

#pragma mark Public API
- (nonnull ADJInputLogMessageData *)build {
    return [[ADJInputLogMessageData alloc]
            initWithMessage:self.message
            level:self.level
            issueType:self.issueType
            callerThreadId:self.callerThreadId
            fromCaller:self.fromCaller
            runningThreadId:self.runningThreadId
            resultFail:self.resultFail
            messageParams:self.messageParams
            sdkPackageParams:self.sdkPackageParams];
}

- (void)where:(nonnull NSString *)where {
    [self withKey:ADJLogWhereKey constValue:where];
}
- (void)issue:(nonnull ADJIssue)issueType {
    self.issueType = issueType;
}
- (void)subject:(nonnull NSString *)subject {
    [self withKey:ADJLogSubjectKey constValue:subject];
}
- (void)why:(nonnull NSString *)why {
    [self withKey:ADJLogWhyKey constValue:why];
}
- (void)fail:(nonnull ADJResultFail *)resultFail {
    self.resultFail = resultFail;
}
- (void)sdkPackageParams:(nonnull NSDictionary<NSString *, NSString *> *)sdkPackageParams {
    self.sdkPackageParams = sdkPackageParams;
}

- (void)withExpected:(nonnull NSString *)expectedValue
              actual:(nullable NSString *)actualValue
{
    [self withKey:ADJLogExpectedKey constValue:expectedValue];
    [self withKey:ADJLogActualKey value:actualValue];
}

- (void)withFail:(nonnull ADJResultFail *)resultFail
           issue:(nonnull ADJIssue)issueType
{
    [self fail:resultFail];
    [self issue:issueType];
}

- (void)withSubject:(nonnull NSString *)subject
              value:(nonnull NSString *)value
{
    [self subject:subject];
    [self value:value];
}

- (void)withSubject:(nonnull NSString *)subject
                why:(nonnull NSString *)why
{
    [self subject:subject];
    [self why:why];
}

- (void)withKey:(nonnull NSString *)key
          value:(nullable id)value
{
    if (self.messageParams == nil) {
        self.messageParams = [[NSMutableDictionary alloc] init];
    }

    [self.messageParams setObject:[ADJUtilObj idOrNsNull:value] forKey:key];
}

#pragma mark Internal Methods
- (void)value:(nonnull NSString *)value {
    [self withKey:ADJLogValueKey value:value];
}

- (void)withKey:(nonnull NSString *)key
     constValue:(nonnull NSString *)constValue
{
    if (self.messageParams == nil) {
        self.messageParams = [[NSMutableDictionary alloc] init];
    }

    [self.messageParams setObject:constValue forKey:key];
}

@end
