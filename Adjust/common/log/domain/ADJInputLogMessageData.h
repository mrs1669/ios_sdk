//
//  ADJInputLogMessageData.h
//  Adjust
//
//  Created by Pedro Silva on 27.10.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJLogLevelDevTrace;
FOUNDATION_EXPORT NSString *const ADJLogLevelDevDebug;
FOUNDATION_EXPORT NSString *const ADJLogLevelClientInfo;
FOUNDATION_EXPORT NSString *const ADJLogLevelClientNotice;
FOUNDATION_EXPORT NSString *const ADJLogLevelClientError;

NS_ASSUME_NONNULL_END
*/
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
    issueType:(nullable NSString *)issueType
    nsError:(nullable NSError *)nsError
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
    issueType:(nullable NSString *)issueType
    callerThreadId:(nullable NSString *)callerThreadId
    callerDescription:(nullable NSString *)callerDescription
    runningThreadId:(nullable NSString *)runningThreadId
    nsError:(nullable NSError *)nsError
    messageParams:(nullable NSDictionary<NSString *, NSString*> *)messageParams
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSString *message;
@property (nonnull, readonly, strong, nonatomic) NSString *level;
@property (nullable, readonly, strong, nonatomic) NSString *callerThreadId;
@property (nullable, readonly, strong, nonatomic) NSString *callerDescription;
@property (nullable, readonly, strong, nonatomic) NSString *runningThreadId;
@property (nullable, readonly, strong, nonatomic) NSString *issueType;
@property (nullable, readonly, strong, nonatomic) NSError *nsError;
@property (nullable, readonly, strong, nonatomic)
    NSDictionary<NSString *, NSString*> *messageParams;

@end
