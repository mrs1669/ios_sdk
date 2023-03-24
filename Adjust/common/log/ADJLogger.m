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

#pragma mark Fields
@interface ADJLogger ()
// Injected variables
@property (nullable, readonly, weak, nonatomic) id<ADJLogCollector> logCollectorWeak;
@property (nonnull, readonly, strong, nonatomic) ADJInstanceIdData *instanceId;

@end

@implementation ADJLogger
#pragma mark Constructors
- (nonnull instancetype)initWithName:(nonnull NSString *)name
                        logCollector:(nonnull id<ADJLogCollector>)logCollector
                          instanceId:(nonnull ADJInstanceIdData *)instanceId
{
    self = [super init];
    
    _name = name;
    _logCollectorWeak = logCollector;
    _instanceId = instanceId;
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull ADJInputLogMessageData *)
    traceThreadChangeWithCallerThreadId:(nonnull NSString *)callerThreadId
    runningThreadId:(nonnull NSString *)runningThreadId
    fromCaller:(nonnull NSString *)fromCaller
{
    return [self logWithInput: [[ADJInputLogMessageData alloc]
                                initWithMessage:@"New thread"
                                level:ADJAdjustLogLevelTrace
                                callerThreadId:callerThreadId
                                fromCaller:fromCaller
                                runningThreadId:runningThreadId]];
}

- (void)
    debugWithMessage:(nonnull NSString *)message
    builderBlock:(void (^ _Nonnull NS_NOESCAPE)(ADJLogBuilder *_Nonnull logBuilder))builderBlock
{
    ADJLogBuilder *_Nonnull builder =
        [[ADJLogBuilder alloc] initWithMessage:message level:ADJAdjustLogLevelDebug];
    builderBlock(builder);
    [self logWithInput:[builder build]];
}

#pragma mark - debug dev without issue
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message {
    return [self logWithMessage:message logLevel:ADJAdjustLogLevelDebug];
}
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        from:(nonnull NSString *)from
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelDebug
                            key:ADJLogFromKey
                          value:from];
}
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                         key:(nonnull NSString *)key
                                       value:(nullable NSString *)value
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelDebug
                            key:key
                          value:[ADJUtilF stringOrNsNull:value]];
}
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        from:(nonnull NSString *)from
                                         key:(nonnull NSString *)key
                                       value:(nullable NSString *)value
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelDebug
                           key1:ADJLogFromKey
                         value1:from
                           key2:key
                         value2:[ADJUtilF stringOrNsNull:value]];
}
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        key1:(nonnull NSString *)key1
                                      value1:(nullable NSString *)value1
                                        key2:(nonnull NSString *)key2
                                      value2:(nullable NSString *)value2
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelDebug
                           key1:key1
                         value1:[ADJUtilF stringOrNsNull:value1]
                           key2:key2
                         value2:[ADJUtilF stringOrNsNull:value2]];
}

#pragma mark - debug dev with issue
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                   issueType:(nonnull ADJIssue)issueType
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelDebug
                               issueType:issueType
                               resultFail:nil
                               messageParams:nil]];
}
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                  resultFail:(nonnull ADJResultFail *)resultFail
                                   issueType:(nonnull ADJIssue)issueType
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelDebug
                               issueType:issueType
                               resultFail:resultFail
                               messageParams:nil]];
}
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        from:(nonnull NSString *)from
                                  resultFail:(nullable ADJResultFail *)resultFail
                                   issueType:(nonnull ADJIssue)issueType
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelDebug
                               issueType:issueType
                               resultFail:resultFail
                               messageParams:[[NSDictionary alloc] initWithObjectsAndKeys:
                                              from, ADJLogFromKey, nil]]];
}

- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                               expectedValue:(nonnull NSString *)expectedValue
                                 actualValue:(nullable NSString *)actualValue
                                   issueType:(nonnull ADJIssue)issueType
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelDebug
                               issueType:issueType
                               resultFail:nil
                               messageParams:
                                   [[NSDictionary alloc] initWithObjectsAndKeys:
                                    expectedValue, ADJLogExpectedKey,
                                    [ADJUtilF stringOrNsNull:actualValue], ADJLogActualKey, nil]]];
}
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                     subject:(nonnull NSString *)subject
                                  resultFail:(nonnull ADJResultFail *)resultFail
                                   issueType:(nonnull ADJIssue)issueType
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelDebug
                               issueType:issueType
                               resultFail:resultFail
                               messageParams:
                                   [[NSDictionary alloc] initWithObjectsAndKeys:
                                    subject, ADJLogSubjectKey, nil]]];
}

- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                         key:(nonnull NSString *)key
                                       value:(nullable NSString *)value
                                   issueType:(nonnull ADJIssue)issueType
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelDebug
                               issueType:issueType
                               resultFail:nil
                               messageParams:
                                   [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [ADJUtilF stringOrNsNull:value], key, nil]]];
}
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                         key:(nonnull NSString *)key
                                       value:(nullable NSString *)value
                                  resultFail:(nonnull ADJResultFail *)resultFail
                                   issueType:(nonnull ADJIssue)issueType
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelDebug
                               issueType:issueType
                               resultFail:resultFail
                               messageParams:
                                   [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [ADJUtilF stringOrNsNull:value], key, nil]]];
}

- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        key1:(nonnull NSString *)key1
                                      value1:(nullable NSString *)value1
                                        key2:(nonnull NSString *)key2
                                      value2:(nullable NSString *)value2
                                   issueType:(nonnull ADJIssue)issueType
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelDebug
                               issueType:issueType
                               resultFail:nil
                               messageParams:
                                   [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [ADJUtilF stringOrNsNull:value1], key1,
                                    [ADJUtilF stringOrNsNull:value2], key2, nil]]];
}

#pragma mark - info client
- (nonnull ADJInputLogMessageData *)infoClient:(nonnull NSString *)message {
    return [self logWithMessage:message logLevel:ADJAdjustLogLevelInfo];
}
- (nonnull ADJInputLogMessageData *)infoClient:(nonnull NSString *)message
                                           key:(nonnull NSString *)key
                                         value:(nullable NSString *)value
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelInfo
                            key:key
                          value:[ADJUtilF stringOrNsNull:value]];
}
- (nonnull ADJInputLogMessageData *)infoClient:(nonnull NSString *)message
                                          key1:(nonnull NSString *)key1
                                        value1:(nullable NSString *)value1
                                          key2:(nonnull NSString *)key2
                                        value2:(nullable NSString *)value2
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelInfo
                           key1:key1
                         value1:[ADJUtilF stringOrNsNull:value1]
                           key2:key2
                         value2:[ADJUtilF stringOrNsNull:value2]];
}

#pragma mark - notice client
- (nonnull ADJInputLogMessageData *)noticeClient:(nonnull NSString *)message {
    return [self logWithMessage:message logLevel:ADJAdjustLogLevelNotice];
}
- (nonnull ADJInputLogMessageData *)noticeClient:(nonnull NSString *)message
                                             key:(nonnull NSString *)key
                                           value:(nullable NSString *)value
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelNotice
                            key:key
                          value:[ADJUtilF stringOrNsNull:value]];
}
- (nonnull ADJInputLogMessageData *)noticeClient:(nonnull NSString *)message
                                      resultFail:(nonnull ADJResultFail *)resultFail
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelNotice
                               issueType:nil
                               resultFail:resultFail
                               messageParams:nil]];
}

#pragma mark - error client
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message {
    return [self logWithMessage:message logLevel:ADJAdjustLogLevelError];
}
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                            key:(nonnull NSString *)key
                                          value:(nullable NSString *)value
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelError
                            key:key
                          value:[ADJUtilF stringOrNsNull:value]];
}
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                  expectedValue:(nonnull NSString *)expectedValue
                                    actualValue:(nullable NSString *)actualValue
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelError
                           key1:ADJLogExpectedKey
                         value1:expectedValue
                           key2:ADJLogActualKey
                         value2:[ADJUtilF stringOrNsNull:actualValue]];
}
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                     resultFail:(nonnull ADJResultFail *)resultFail
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelError
                               issueType:nil
                               resultFail:resultFail
                               messageParams:nil]];
}
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                            key:(nonnull NSString *)key
                                          value:(nullable NSString *)value
                                     resultFail:(nonnull ADJResultFail *)resultFail
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelError
                               issueType:nil
                               resultFail:resultFail
                               messageParams:[[NSDictionary alloc] initWithObjectsAndKeys:
                                              [ADJUtilF stringOrNsNull:value], key, nil]]];
}

#pragma mark Internal methods
- (nonnull ADJInputLogMessageData *)logWithInput:
    (nonnull ADJInputLogMessageData *)inputLogMessageData
{
    id<ADJLogCollector> _Nullable logCollector = self.logCollectorWeak;
    if (logCollector == nil) {
        return inputLogMessageData;
    }

    NSString *_Nullable runningThreadId = nil;
    if (inputLogMessageData.runningThreadId == nil) {
        runningThreadId = [[ADJLocalThreadController instance] localIdOrOutside];
    }

    ADJLogMessageData *_Nonnull logMessageData = [[ADJLogMessageData alloc]
                                                  initWithInputData:inputLogMessageData
                                                  loggerName:self.name
                                                  idString:self.instanceId.idString
                                                  runningThreadId:runningThreadId];

    [logCollector collectLogMessage:logMessageData];

    return inputLogMessageData;
}

- (nonnull ADJInputLogMessageData *)logWithMessage:(nonnull NSString *)message
              logLevel:(nonnull ADJAdjustLogLevel)logLevel
{
    return [self logWithInput:[[ADJInputLogMessageData alloc] initWithMessage:message
                                                                        level:logLevel
                                                                    issueType:nil
                                                                   resultFail:nil
                                                                messageParams:nil]];
}

- (nonnull ADJInputLogMessageData *)logWithMessage:(nonnull NSString *)message
                                          logLevel:(nonnull ADJAdjustLogLevel)logLevel
                                               key:(nonnull NSString *)key
                                             value:(nonnull id)value
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:logLevel
                               messageParams:[[NSDictionary alloc]
                                              initWithObjectsAndKeys:value, key, nil]]];
}

- (nonnull ADJInputLogMessageData *)logWithMessage:(nonnull NSString *)message
                                          logLevel:(nonnull ADJAdjustLogLevel)logLevel
                                              key1:(nonnull NSString *)key1
                                            value1:(nonnull id)value1
                                              key2:(nonnull NSString *)key2
                                            value2:(nonnull id)value2
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:logLevel
                               messageParams:[[NSDictionary alloc] initWithObjectsAndKeys:
                                              value1, key1, value2, key2, nil]]];
}

@end
