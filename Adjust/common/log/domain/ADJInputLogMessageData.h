//
//  ADJInputLogMessageData.h
//  Adjust
//
//  Created by Pedro Silva on 27.10.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJAdjustLogMessageData.h"

NS_ASSUME_NONNULL_BEGIN

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
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level;

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
                          messageParams:(nullable NSDictionary<NSString *, id> *)messageParams;

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
                              issueType:(nullable ADJIssue)issueType
                                nsError:(nullable NSError *)nsError
                            nsException:(nullable NSException *)nsException
                          messageParams:(nullable NSDictionary<NSString *, id> *)messageParams;

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
                         callerThreadId:(nullable NSString *)callerThreadId
                      callerDescription:(nullable NSString *)callerDescription
                        runningThreadId:(nullable NSString *)runningThreadId;

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level
                              issueType:(nullable ADJIssue)issueType
                         callerThreadId:(nullable NSString *)callerThreadId
                      callerDescription:(nullable NSString *)callerDescription
                        runningThreadId:(nullable NSString *)runningThreadId
                                nsError:(nullable NSError *)nsError
                            nsException:(nullable NSException *)nsException
                          messageParams:(nullable NSDictionary<NSString *, id> *)messageParams
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
@property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, id> *messageParams;

@end

@interface ADJLogBuilder : NSObject

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  level:(nonnull ADJAdjustLogLevel)level;

- (nonnull ADJInputLogMessageData *)build;

- (void)where:(nonnull NSString *)where;
- (void)issue:(nonnull ADJIssue)issueType;
- (void)subject:(nonnull NSString *)subject;
- (void)why:(nonnull NSString *)why;

- (void)withExpected:(nonnull NSString *)expectedValue
              actual:(nullable NSString *)actualValue;

- (void)withFailMessage:(nonnull NSString *)failMessage
                  issue:(nonnull ADJIssue)issueType;

- (void)withError:(nullable NSError *)nserror
            issue:(nonnull ADJIssue)issueType;

- (void)withSubject:(nonnull NSString *)subject
              value:(nonnull NSString *)value;

- (void)withSubject:(nonnull NSString *)subject
                why:(nonnull NSString *)why;

- (void)withKey:(nonnull NSString *)key
          value:(nullable NSString *)value;

@end
