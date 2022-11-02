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
    issueType:(nullable NSString *)issueType
    nsError:(nullable NSError *)nsError
    messageParams:(nullable NSDictionary<NSString *, NSString*> *)messageParams
{
    self = [super init];

    _message = message;
    _level = level;
    _issueType = issueType;
    _nsError = nsError;
    _messageParams = messageParams;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
