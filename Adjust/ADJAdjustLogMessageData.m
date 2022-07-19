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
 @property (nonnull, readonly, strong, nonatomic) NSString *source;
 @property (nonnull, readonly, strong, nonatomic) NSString *messageLogLevel;
 */

#pragma mark - Public constants
NSString *const ADJAdjustLogLevelDebug = @"Debug";
NSString *const ADJAdjustLogLevelInfo = @"Info";
NSString *const ADJAdjustLogLevelError = @"Error";

@implementation ADJAdjustLogMessageData
#pragma mark Instantiation
- (nonnull instancetype)initWithLogMessage:(nonnull NSString *)logMessage
                                    source:(nonnull NSString *)source
                            messageLogLevel:(nonnull NSString *)messageLogLevel
{
    self = [super init];

    _logMessage = logMessage;
    _source = source;
    _messageLogLevel = messageLogLevel;

    return self;
}
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull NSString *)generateFullLog {
    return [ADJAdjustLogMessageData generateFullLogWithMessage:self.logMessage
                                                         source:self.source
                                                messageLogLevel:self.messageLogLevel];
}

+ (nonnull NSString *)generateFullLogWithMessage:(nonnull NSString *)logMessage
                                          source:(nonnull NSString *)source
                                 messageLogLevel:(nonnull NSString *)messageLogLevel
{
    return [NSString stringWithFormat:@"[%@][%@][%@] %@",
            ADJAdjustCategory, messageLogLevel, source, logMessage];
}

@end
