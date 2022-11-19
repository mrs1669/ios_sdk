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

@end

@implementation ADJLogger
#pragma mark Constructors
- (nonnull instancetype)initWithSource:(nonnull NSString *)source
                          logCollector:(nonnull id<ADJLogCollector>)logCollector {
    self = [super init];
    
    _source = source;
    _logCollectorWeak = logCollector;
    
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

- (void)debugDev:(nonnull NSString *)message {
    [self logWithMessage:message logLevel:ADJAdjustLogLevelDebug];
}
- (void)debugDev:(nonnull NSString *)message
            from:(nonnull NSString *)from
{
    [self logWithMessage:message
                logLevel:ADJAdjustLogLevelDebug
                     key:@"from"
                   value:from];
}

- (void)debugDev:(nonnull NSString *)message
             key:(nonnull NSString *)key
           value:(nullable NSString *)value
{
    [self logWithMessage:message
                logLevel:ADJAdjustLogLevelDebug
                     key:key
                   value:[ADJLogger stringOrNsNull:value]];
}
- (void)debugDev:(nonnull NSString *)message
            from:(nonnull NSString *)from
             key:(nonnull NSString *)key
           value:(nullable NSString *)value
{
    [self logWithMessage:message
                logLevel:ADJAdjustLogLevelDebug
                    key1:@"from"
                  value1:from
                    key2:key
                  value2:[ADJLogger stringOrNsNull:value]];
}
- (void)debugDev:(nonnull NSString *)message
            key1:(nonnull NSString *)key1
          value1:(nullable NSString *)value1
            key2:(nonnull NSString *)key2
          value2:(nullable NSString *)value2
{
    [self logWithMessage:message
                logLevel:ADJAdjustLogLevelDebug
                    key1:key1
                  value1:[ADJLogger stringOrNsNull:value1]
                    key2:key2
                  value2:[ADJLogger stringOrNsNull:value2]];
}
- (void)debugDev:(nonnull NSString *)message
   messageParams:(nonnull NSDictionary<NSString *, id> *)messageParams
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:nil
                        nsError:nil
                        nsException:nil
                        messageParams:messageParams]];
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
                             [ADJLogger stringOrNsNull:actualValue], @"actual", nil]]];
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
                             [ADJLogger stringOrNsNull:value], key, nil]]];
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
                             [ADJLogger stringOrNsNull:value1], key1,
                             [ADJLogger stringOrNsNull:value2], key2, nil]]];
}
- (void)debugDev:(nonnull NSString *)message
   messageParams:(nonnull NSDictionary<NSString *, id> *)messageParams
       issueType:(nonnull ADJIssue)issueType
{
    [self logWithInput:[[ADJInputLogMessageData alloc]
                        initWithMessage:message
                        level:ADJAdjustLogLevelDebug
                        issueType:issueType
                        nsError:nil
                        nsException:nil
                        messageParams:messageParams]];
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
                   value:[ADJLogger stringOrNsNull:value]];
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
                  value1:[ADJLogger stringOrNsNull:value1]
                    key2:key2
                  value2:[ADJLogger stringOrNsNull:value2]];
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
                   value:[ADJLogger stringOrNsNull:value]];
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
                   value:[ADJLogger stringOrNsNull:value]];
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
                  value2:[ADJLogger stringOrNsNull:actualValue]];
}

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

#pragma mark Internal methods
- (void)logWithMessage:(nonnull NSString *)message
              logLevel:(nonnull ADJAdjustLogLevel)logLevel
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
              logLevel:(nonnull ADJAdjustLogLevel)logLevel
                   key:(nonnull NSString *)key
                 value:(nonnull id)value
{
    [self logWithInput:
        [[ADJInputLogMessageData alloc]
            initWithMessage:message
            level:logLevel
            messageParams:[[NSDictionary alloc] initWithObjectsAndKeys:value, key, nil]]];
}
- (void)logWithMessage:(nonnull NSString *)message
              logLevel:(nonnull ADJAdjustLogLevel)logLevel
                  key1:(nonnull NSString *)key1
                value1:(nonnull id)value1
                  key2:(nonnull NSString *)key2
                value2:(nonnull id)value2
{
    [self logWithInput:
        [[ADJInputLogMessageData alloc]
            initWithMessage:message
            level:logLevel
            messageParams:[[NSDictionary alloc] initWithObjectsAndKeys:
                           value1, key1, value2, key2, nil]]];
}

+ (nonnull id)stringOrNsNull:(nullable NSString *)string {
    return string == nil ? [NSNull null] : string;
}

@end
