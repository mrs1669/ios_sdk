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
 @property (nullable, readonly, strong, nonatomic) NSString *issueType;
 @property (nullable, readonly, strong, nonatomic) NSError *nsError;
 @property (nullable, readonly, strong, nonatomic)
     NSDictionary<NSString *, NSString*> *messageParams;
 */
/*
#pragma mark - Public constants
NSString *const ADJLogLevelDevTrace = @"trace";
NSString *const ADJLogLevelDevDebug = @"debug";
NSString *const ADJLogLevelClientInfo = @"info";
NSString *const ADJLogLevelClientNotice = @"notice";
NSString *const ADJLogLevelClientError = @"error";
*/
@implementation ADJInputLogMessageData
#pragma mark Instantiation
- (nonnull instancetype)
    initWithMessage:(nonnull NSString *)message
    level:(nonnull NSString *)level
{
    return [self initWithMessage:message
                           level:level
                       issueType:nil
                  callerThreadId:nil
               callerDescription:nil
                 runningThreadId:nil
                         nsError:nil
                   messageParams:nil];
}

- (nonnull instancetype)
    initWithMessage:(nonnull NSString *)message
    level:(nonnull NSString *)level
    messageParams:(nullable NSDictionary<NSString *, NSString*> *)messageParams
{
    return [self initWithMessage:message
                           level:level
                       issueType:nil
                  callerThreadId:nil
               callerDescription:nil
                 runningThreadId:nil
                         nsError:nil
                   messageParams:messageParams];
}

- (nonnull instancetype)
    initWithMessage:(nonnull NSString *)message
    level:(nonnull NSString *)level
    issueType:(nullable NSString *)issueType
    nsError:(nullable NSError *)nsError
    messageParams:(nullable NSDictionary<NSString *, NSString*> *)messageParams
{
    return [self initWithMessage:message
                           level:level
                       issueType:issueType
                  callerThreadId:nil
               callerDescription:nil
                 runningThreadId:nil
                         nsError:nsError
                   messageParams:messageParams];
}

- (nonnull instancetype)
    initWithMessage:(nonnull NSString *)message
    level:(nonnull NSString *)level
    callerThreadId:(nullable NSString *)callerThreadId
    callerDescription:(nullable NSString *)callerDescription
    runningThreadId:(nullable NSString *)runningThreadId
{
    return [self initWithMessage:message
                           level:level
                       issueType:nil
                  callerThreadId:callerThreadId
               callerDescription:callerDescription
                 runningThreadId:runningThreadId
                         nsError:nil
                   messageParams:nil];
}

- (nonnull instancetype)
    initWithMessage:(nonnull NSString *)message
    level:(nonnull NSString *)level
    issueType:(nullable NSString *)issueType
    callerThreadId:(nullable NSString *)callerThreadId
    callerDescription:(nullable NSString *)callerDescription
    runningThreadId:(nullable NSString *)runningThreadId
    nsError:(nullable NSError *)nsError
    messageParams:(nullable NSDictionary<NSString *, NSString*> *)messageParams
{
    self = [super init];

    _message = message;
    _level = level;
    _issueType = issueType;
    _callerThreadId = callerThreadId;
    _callerDescription = callerDescription;
    _runningThreadId = runningThreadId;
    _nsError = nsError;
    _messageParams = messageParams;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
