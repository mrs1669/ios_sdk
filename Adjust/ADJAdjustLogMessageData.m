//
//  ADJAdjustLogMessageData.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustLogMessageData.h"

#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSString *logMessage;
 @property (nonnull, readonly, strong, nonatomic) NSString *messageLogLevel;
 */

#pragma mark - Public constants
NSString *const ADJAdjustLogLevelTrace = @"trace";
NSString *const ADJAdjustLogLevelDebug = @"debug";
NSString *const ADJAdjustLogLevelInfo = @"info";
NSString *const ADJAdjustLogLevelNotice = @"notice";
NSString *const ADJAdjustLogLevelError = @"error";

@implementation ADJAdjustLogMessageData

#pragma mark Instantiation
- (nonnull instancetype)initWithLogMessage:(nonnull NSString *)logMessage
                           messageLogLevel:(nonnull NSString *)messageLogLevel {
    self = [super init];
    
    _logMessage = logMessage;
    _messageLogLevel = messageLogLevel;
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
