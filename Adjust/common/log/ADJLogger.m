//
//  ADJLogger.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLogger.h"

#import "ADJAdjustLogMessageData.h"
#import "ADJUtilF.h"
#import "ADJConstants.h"
#import "ADJLocalThreadController.h"

//#import <os/log.h>

@interface ADJLogger ()
// Injected variables
@property (nullable, readonly, weak, nonatomic) id<ADJLogCollector> logCollectorWeak;

// Internal variables
/*
 @property (strong, nonatomic, readwrite, nonnull)
 os_log_t osLogLogger
 API_AVAILABLE(macos(10.12), ios(10.0), watchos(3.0), tvos(10.0));
 */
@end

@implementation ADJLogger
#pragma mark Constructors
- (nonnull instancetype)initWithSource:(nonnull NSString *)source
                          logCollector:(nonnull id<ADJLogCollector>)logCollector {
    self = [super init];
    
    _source = source;
    _logCollectorWeak = logCollector;
    
    /*
     if (@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)) {
     _osLogLogger = os_log_create(ADJAdjustSubSystem.UTF8String, self.source.UTF8String);
     }
     */
    return self;
}
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (void)
    traceThreadChangeWithCallerThreadId:(nonnull NSString *)callerThreadId
    runningThreadId:(nonnull NSString *)runningThreadId
    callerDescription:(nonnull NSString *)callerDescription
{
    [self logWithInput:
        [[ADJInputLogMessageData alloc]
        initWithMessage:@"New thread"
        level:ADJAdjustLogLevelTrace
        callerThreadId:callerThreadId
        callerDescription:callerDescription
        runningThreadId:runningThreadId]];
}

- (nonnull ADJLogBuilder *)debugDevStart:(nonnull NSString *)message {
    return [[ADJLogBuilder alloc]
            initWithLevel:ADJAdjustLogLevelDebug
            message:message
            logBuildCallback:self];
}

- (void)debugDev:(nonnull NSString *)message {
    [self logWithMessage:message logLevel:ADJAdjustLogLevelDebug];
}
- (void)debugDev:(nonnull NSString *)message
            from:(nonnull NSString *)from
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:nil
                        nsError:nil
                        nsException:nil
                        messageParams:
                            [[NSDictionary alloc] initWithObjectsAndKeys:
                             from, @"from", nil]]];
}
- (void)debugDev:(nonnull NSString *)message
             key:(nonnull NSString *)key
           value:(nullable NSString *)value
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:nil
                        nsError:nil
                        nsException:nil
                        messageParams:
                            [[NSDictionary alloc] initWithObjectsAndKeys:
                             value, key, nil]]];
}
- (void)debugDev:(nonnull NSString *)message
            from:(nonnull NSString *)from
             key:(nonnull NSString *)key
           value:(nullable NSString *)value
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:nil
                        nsError:nil
                        nsException:nil
                        messageParams:
                            [[NSDictionary alloc] initWithObjectsAndKeys:
                             value, key,
                             from, @"from", nil]]];
}
- (void)debugDev:(nonnull NSString *)message
            key1:(nonnull NSString *)key1
          value1:(nullable NSString *)value1
            key2:(nonnull NSString *)key2
          value2:(nullable NSString *)value2
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:nil
                        nsError:nil
                        nsException:nil
                        messageParams:
                            [[NSDictionary alloc] initWithObjectsAndKeys:
                             value1, key1,
                             value2, key2, nil]]];
}

- (void)debugDev:(nonnull NSString *)message
       issueType:(nonnull ADJIssue)issueType
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:issueType
                        nsError:nil
                        nsException:nil
                        messageParams:nil]];
}
- (void)debugDev:(nonnull NSString *)message
         nserror:(nullable NSError *)nserror
       issueType:(nonnull ADJIssue)issueType
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:issueType
                        nsError:nserror
                        nsException:nil
                        messageParams:nil]];
}

- (void)debugDev:(nonnull NSString *)message
       valueName:(nonnull NSString *)valueName
       issueType:(nonnull ADJIssue)issueType
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:issueType
                        nsError:nil
                        nsException:nil
                        messageParams:
                            [[NSDictionary alloc] initWithObjectsAndKeys:
                             valueName, @"value_name", nil]]];
}
- (void)debugDev:(nonnull NSString *)message
            from:(nonnull NSString *)from
       issueType:(nonnull ADJIssue)issueType
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:issueType
                        nsError:nil
                        nsException:nil
                        messageParams:
                            [[NSDictionary alloc] initWithObjectsAndKeys:
                             from, @"from", nil]]];
}
- (void)debugDev:(nonnull NSString *)message
   expectedValue:(nonnull NSString *)expectedValue
     actualValue:(nullable NSString *)actualValue
       issueType:(nonnull ADJIssue)issueType
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:issueType
                        nsError:nil
                        nsException:nil
                        messageParams:
                            [[NSDictionary alloc] initWithObjectsAndKeys:
                             expectedValue, @"expected",
                             actualValue, @"actual", nil]]];
}
- (void)debugDev:(nonnull NSString *)message
             key:(nonnull NSString *)key
           value:(nullable NSString *)value
       issueType:(nonnull ADJIssue)issueType
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:issueType
                        nsError:nil
                        nsException:nil
                        messageParams:
                            [[NSDictionary alloc] initWithObjectsAndKeys:
                             value, key, nil]]];
}
- (void)debugDev:(nonnull NSString *)message
            key1:(nonnull NSString *)key1
          value1:(nullable NSString *)value1
            key2:(nonnull NSString *)key2
          value2:(nullable NSString *)value2
       issueType:(nonnull ADJIssue)issueType
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:issueType
                        nsError:nil
                        nsException:nil
                        messageParams:
                            [[NSDictionary alloc] initWithObjectsAndKeys:
                             value1, key1,
                             value2, key2, nil]]];
}

- (nonnull id<ADJClientLogBuilder>)infoClientStart:(nonnull NSString *)message {
    return [[ADJLogBuilder alloc]
                initWithLevel:ADJAdjustLogLevelInfo
                message:message
                logBuildCallback:self];
}
- (void)infoClient:(nonnull NSString *)message {
    [self logWithMessage:message logLevel:ADJAdjustLogLevelInfo];
}
- (void)infoClient:(nonnull NSString *)message
               key:(nonnull NSString *)key
             value:(nullable NSString *)value
{
    [self logWithMessage:message
                logLevel:ADJAdjustLogLevelInfo
                     key:key
                   value:value];
}
- (void)infoClient:(nonnull NSString *)message
              key1:(nonnull NSString *)key1
            value1:(nullable NSString *)value1
              key2:(nonnull NSString *)key2
            value2:(nullable NSString *)value2
{
    [self logWithMessage:message
                logLevel:ADJAdjustLogLevelInfo
                     key1:key1
                  value1:value1
                    key2:key2
                  value2:value2];
}

- (nonnull id<ADJClientLogBuilder>)noticeClientStart:(nonnull NSString *)message {
    return [[ADJLogBuilder alloc]
                initWithLevel:ADJAdjustLogLevelNotice
                message:message
                logBuildCallback:self];
}
- (void)noticeClient:(nonnull NSString *)message {
    [self logWithMessage:message logLevel:ADJAdjustLogLevelNotice];
}
- (void)noticeClient:(nonnull NSString *)message
                 key:(nonnull NSString *)key
               value:(nullable NSString *)value
{
    [self logWithMessage:message
                logLevel:ADJAdjustLogLevelNotice
                     key:key
                   value:value];
}

- (nonnull id<ADJClientLogBuilder>)errorClientStart:(nonnull NSString *)message {
    return [[ADJLogBuilder alloc]
                initWithLevel:ADJAdjustLogLevelError
                message:message
                logBuildCallback:self];
}
- (void)errorClient:(nonnull NSString *)message {
    [self logWithMessage:message logLevel:ADJAdjustLogLevelError];
}
- (void)errorClient:(nonnull NSString *)message
            nserror:(nullable NSError *)nserror
{
    [self logWithInput:
        [[ADJInputLogMessageData alloc] initWithMessage:message
                                                  level:ADJAdjustLogLevelError
                                              issueType:nil
                                                nsError:nserror
                                            nsException:nil
                                          messageParams:nil]];
}

- (void)errorClient:(nonnull NSString *)message
                key:(nonnull NSString *)key
              value:(nullable NSString *)value
{
    [self logWithMessage:message
                logLevel:ADJAdjustLogLevelError
                     key:key
                   value:value];
}
- (void)errorClient:(nonnull NSString *)message
      expectedValue:(nonnull NSString *)expectedValue
        actualValue:(nullable NSString *)actualValue
{
    [self logWithMessage:message
                logLevel:ADJAdjustLogLevelError
                    key1:@"expected"
                  value1:expectedValue
                    key2:@"actual"
                  value2:actualValue];
}

#pragma mark - ADJLogBuildCallback
- (void)logWithInput:(nonnull ADJInputLogMessageData *)inputLogMessageData {
    id<ADJLogCollector> _Nullable logCollector = self.logCollectorWeak;
    if (logCollector == nil) {
        return;
    }

    NSString *_Nullable runningThreadId = nil;
    if (inputLogMessageData.runningThreadId == nil) {
        runningThreadId = [[ADJLocalThreadController instance] localIdOrOutside];
    }

    ADJLogMessageData *_Nonnull logMessageData =
        [[ADJLogMessageData alloc] initWithInputData:inputLogMessageData
                                   sourceDescription:self.source
                                     runningThreadId:runningThreadId
                                          instanceId:nil];

    [logCollector collectLogMessage:logMessageData];
}

- (nonnull NSString *)debug:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    
    return [self debug:message parameters:parameters];
}
- (nonnull NSString *)debug:(nonnull NSString *)message parameters:(va_list)parameters {
    return [self log:message parameters:parameters messageLogLevel:ADJAdjustLogLevelDebug];
}

- (nonnull NSString *)info:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    
    return [self info:message parameters:parameters];
}
- (nonnull NSString *)info:(nonnull NSString *)message parameters:(va_list)parameters {
    return [self log:message parameters:parameters messageLogLevel:ADJAdjustLogLevelInfo];
}

- (nonnull NSString *)error:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    
    return [self error:message parameters:parameters];
}
- (nonnull NSString *)error:(nonnull NSString *)message parameters:(va_list)parameters {
    return [self log:message parameters:parameters messageLogLevel:ADJAdjustLogLevelError];
}

- (nonnull NSString *)errorWithNSError:(nonnull NSError *)error
                               message:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    
    return [self errorWithNSError:error message:message parameters:parameters];
}
- (nonnull NSString *)errorWithNSError:(nonnull NSError *)error
                               message:(nonnull NSString *)message
                            parameters:(va_list)parameters {
    NSString *_Nonnull formattedWithError = [ADJLogger formatNSError:error message:message];
    return [self log:formattedWithError parameters:parameters messageLogLevel:ADJAdjustLogLevelError];
}

+ (nonnull NSString *)formatNSError:(nonnull NSError *)error
                            message:(nonnull NSString *)message
{
    return [NSString stringWithFormat:@"%@, with NSError: %@",
            message, [ADJUtilF errorFormat:error]];
}

#pragma mark Internal methods
- (void)logWithMessage:(nonnull NSString *)message
              logLevel:(nonnull NSString *)logLevel
{
    [self logWithInput:
        [[ADJInputLogMessageData alloc] initWithMessage:message
                                                  level:logLevel
                                              issueType:nil
                                                nsError:nil
                                            nsException:nil
                                          messageParams:nil]];

}
- (void)logWithMessage:(nonnull NSString *)message
              logLevel:(nonnull NSString *)logLevel
                   key:(nonnull NSString *)key
                 value:(nullable NSString *)value
{
    [self logWithInput:
        [[ADJInputLogMessageData alloc]
            initWithMessage:message
            level:logLevel
            messageParams:[[NSDictionary alloc] initWithObjectsAndKeys:value, key, nil]]];
}
- (void)logWithMessage:(nonnull NSString *)message
              logLevel:(nonnull NSString *)logLevel
                  key1:(nonnull NSString *)key1
                value1:(nullable NSString *)value1
                  key2:(nonnull NSString *)key2
                value2:(nullable NSString *)value2
{
    [self logWithInput:
        [[ADJInputLogMessageData alloc]
            initWithMessage:message
            level:logLevel
            messageParams:[[NSDictionary alloc] initWithObjectsAndKeys:
                           value1, key1, value2, key2, nil]]];
}

- (nonnull NSString *)log:(nonnull NSString *)message
               parameters:(va_list)parameters
          messageLogLevel:(nonnull NSString *)messageLogLevel
{
    NSString *_Nonnull formattedMessage =
        [[NSString alloc] initWithFormat:message arguments:parameters];
    va_end(parameters);

    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:[NSString stringWithFormat:@"TOUPDT|%@", formattedMessage]
                        level:ADJAdjustLogLevelDebug]];

    return formattedMessage;
    /*;
    id<ADJLogCollector> _Nullable logCollector = self.logCollectorWeak;
    if (logCollector != nil) {
        [logCollector collectLogMessage:formattedMessage
                                 source:self.source
                        messageLogLevel:messageLogLevel];
    }
    
    return formattedMessage;
     */
}

@end
