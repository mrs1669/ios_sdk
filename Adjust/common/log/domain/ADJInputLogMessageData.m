//
//  ADJInputLogMessageData.m
//  Adjust
//
//  Created by Pedro Silva on 27.10.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJInputLogMessageData.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSString *message;
 @property (nonnull, readonly, strong, nonatomic) NSString *level;
 @property (nullable, readonly, strong, nonatomic) NSString *callerThreadId;
 @property (nullable, readonly, strong, nonatomic) NSString *callerDescription;
 @property (nullable, readonly, strong, nonatomic) NSString *runningThreadId;
 @property (nullable, readonly, strong, nonatomic) ADJIssue issueType;
 @property (nullable, readonly, strong, nonatomic) NSError *nsError;
 @property (nullable, readonly, strong, nonatomic) NSException* nsException;
 @property (nullable, readonly, strong, nonatomic)
 NSDictionary<NSString *, id> *messageParams;
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
                                  level:(nonnull ADJAdjustLogLevel)level {
    return [self initWithMessage:message
                           level:level
                       issueType:nil
                  callerThreadId:nil
               callerDescription:nil
                 runningThreadId:nil
                         nsError:nil
                     nsException:nil
                   messageParams:nil];
}

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
                          messageParams:(nullable NSDictionary<NSString *, id> *)messageParams {
    return [self initWithMessage:message
                           level:level
                       issueType:nil
                  callerThreadId:nil
               callerDescription:nil
                 runningThreadId:nil
                         nsError:nil
                     nsException:nil
                   messageParams:messageParams];
}

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
                              issueType:(nullable ADJIssue)issueType
                                nsError:(nullable NSError *)nsError
                            nsException:(nullable NSException *)nsException
                          messageParams:(nullable NSDictionary<NSString *, id> *)messageParams {
    return [self initWithMessage:message
                           level:level
                       issueType:issueType
                  callerThreadId:nil
               callerDescription:nil
                 runningThreadId:nil
                         nsError:nsError
                     nsException:nsException
                   messageParams:messageParams];
}

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
                         callerThreadId:(nullable NSString *)callerThreadId
                      callerDescription:(nullable NSString *)callerDescription
                        runningThreadId:(nullable NSString *)runningThreadId {
    return [self initWithMessage:message
                           level:level
                       issueType:nil
                  callerThreadId:callerThreadId
               callerDescription:callerDescription
                 runningThreadId:runningThreadId
                         nsError:nil
                     nsException:nil
                   messageParams:nil];
}

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
                              issueType:(nullable ADJIssue)issueType
                         callerThreadId:(nullable NSString *)callerThreadId
                      callerDescription:(nullable NSString *)callerDescription
                        runningThreadId:(nullable NSString *)runningThreadId
                                nsError:(nullable NSError *)nsError
                            nsException:(nullable NSException *)nsException
                          messageParams:(nullable NSDictionary<NSString *, id> *)messageParams
{
    self = [super init];

    _message = message;
    _level = level;
    _issueType = issueType;
    _callerThreadId = callerThreadId;
    _callerDescription = callerDescription;
    _runningThreadId = runningThreadId;
    _nsError = nsError;
    _nsException = nsException;
    _messageParams = messageParams;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

