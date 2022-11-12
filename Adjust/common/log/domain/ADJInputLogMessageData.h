//
//  ADJInputLogMessageData.h
//  Adjust
//
//  Created by Pedro Silva on 27.10.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *ADJLogLevel NS_TYPED_ENUM;
FOUNDATION_EXPORT ADJLogLevel const ADJLogLevelDevTrace;
FOUNDATION_EXPORT ADJLogLevel const ADJLogLevelDevDebug;
FOUNDATION_EXPORT ADJLogLevel const ADJLogLevelClientInfo;
FOUNDATION_EXPORT ADJLogLevel const ADJLogLevelClientNotice;
FOUNDATION_EXPORT ADJLogLevel const ADJLogLevelClientError;

typedef NSString *ADJIssue NS_TYPED_ENUM;
FOUNDATION_EXPORT ADJIssue const ADJIssueClientInput;
FOUNDATION_EXPORT ADJIssue const ADJIssueUnexpectedInput;
FOUNDATION_EXPORT ADJIssue const ADJIssueInvalidInput;
FOUNDATION_EXPORT ADJIssue const ADJIssueExternalApi;
FOUNDATION_EXPORT ADJIssue const ADJIssueLogicError;
FOUNDATION_EXPORT ADJIssue const ADJIssueNetworkRequest;
FOUNDATION_EXPORT ADJIssue const ADJIssueNonNativeIntegration;
FOUNDATION_EXPORT ADJIssue const ADJIssueNonProdConfig;
FOUNDATION_EXPORT ADJIssue const ADJIssuePluginOrigin;
FOUNDATION_EXPORT ADJIssue const ADJIssueStorageIo;
FOUNDATION_EXPORT ADJIssue const ADJIssueThreadsAndLocks;
FOUNDATION_EXPORT ADJIssue const ADJIssueWeakReference;

/*
 FOUNDATION_EXPORT NSSTRING *const ADJIssueType CLIENT_INPUT = "CLIENT_INPUT";
 FOUNDATION_EXPORT NSSTRING *const ADJIssueType EXTERNAL_API = "EXTERNAL_API";
 FOUNDATION_EXPORT NSSTRING *const ADJIssueType LOGIC_ERROR = "LOGIC_ERROR";
 FOUNDATION_EXPORT NSSTRING *const ADJIssueType NETWORK_REQUEST = "NETWORK_REQUEST";
 FOUNDATION_EXPORT NSSTRING *const ADJIssueType NON_NATIVE_INTEGRATION = "NON_NATIVE_INTEGRATION";
 FOUNDATION_EXPORT NSSTRING *const ADJIssueType NON_PROD_CONFIG = "NON_PROD_CONFIG";
 FOUNDATION_EXPORT NSSTRING *const ADJIssueType PLUGIN_ORIGIN = "PLUGIN_ORIGIN";
 FOUNDATION_EXPORT NSSTRING *const ADJIssueType STORAGE_IO = "STORAGE";
 FOUNDATION_EXPORT NSSTRING *const ADJIssueType THREADS_AND_LOCKS = "THREADS_AND_LOCKS";
 FOUNDATION_EXPORT NSSTRING *const ADJIssueType UNEXPECTED_INPUT = "UNEXPECTED_INPUT";
 FOUNDATION_EXPORT NSSTRING *const ADJIssueType WEAK_REFERENCE = "WEAK_REFERENCE";

 */
NS_ASSUME_NONNULL_END

@interface ADJInputLogMessageData : NSObject
// instantiation
- (nonnull instancetype)
    initWithMessage:(nonnull NSString *)message
    level:(nonnull NSString *)level;

- (nonnull instancetype)
    initWithMessage:(nonnull NSString *)message
    level:(nonnull NSString *)level
    messageParams:(nullable NSDictionary<NSString *, NSString*> *)messageParams;

- (nonnull instancetype)
    initWithMessage:(nonnull NSString *)message
    level:(nonnull NSString *)level
    issueType:(nullable ADJIssue)issueType
    nsError:(nullable NSError *)nsError
    nsException:(nullable NSException *)nsException
    messageParams:(nullable NSDictionary<NSString *, NSString*> *)messageParams;

- (nonnull instancetype)
    initWithMessage:(nonnull NSString *)message
    level:(nonnull NSString *)level
    callerThreadId:(nullable NSString *)callerThreadId
    callerDescription:(nullable NSString *)callerDescription
    runningThreadId:(nullable NSString *)runningThreadId;

- (nonnull instancetype)
    initWithMessage:(nonnull NSString *)message
    level:(nonnull NSString *)level
    issueType:(nullable ADJIssue)issueType
    callerThreadId:(nullable NSString *)callerThreadId
    callerDescription:(nullable NSString *)callerDescription
    runningThreadId:(nullable NSString *)runningThreadId
    nsError:(nullable NSError *)nsError
    nsException:(nullable NSException *)nsException
    messageParams:(nullable NSDictionary<NSString *, NSString*> *)messageParams
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSString *message;
@property (nonnull, readonly, strong, nonatomic) NSString *level;
@property (nullable, readonly, strong, nonatomic) NSString *callerThreadId;
@property (nullable, readonly, strong, nonatomic) NSString *callerDescription;
@property (nullable, readonly, strong, nonatomic) NSString *runningThreadId;
@property (nullable, readonly, strong, nonatomic) ADJIssue issueType;
@property (nullable, readonly, strong, nonatomic) NSError *nsError;
@property (nullable, readonly, strong, nonatomic) NSException* nsException;
@property (nullable, readonly, strong, nonatomic)
    NSDictionary<NSString *, NSString*> *messageParams;

@end
