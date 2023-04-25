//
//  ADJLogger.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLogger.h"

#import "ADJAdjustLogMessageData.h"
#import "ADJUtilObj.h"
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
                        logCollector:(nullable id<ADJLogCollector>)logCollector
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
                      jsonValue:from];
}
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                         key:(nonnull NSString *)key
                                 stringValue:(nullable NSString *)stringValue
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelDebug
                            key:key
                      jsonValue:[ADJUtilObj idOrNsNull:stringValue]];
}
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        from:(nonnull NSString *)from
                                         key:(nonnull NSString *)key
                                 stringValue:(nullable NSString *)stringValue
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelDebug
                           key1:ADJLogFromKey
                     jsonValue1:from
                           key2:key
                     jsonValue2:[ADJUtilObj idOrNsNull:stringValue]];
}
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        key1:(nonnull NSString *)key1
                                stringValue1:(nullable NSString *)stringValue1
                                        key2:(nonnull NSString *)key2
                                stringValue2:(nullable NSString *)stringValue2
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelDebug
                           key1:key1
                     jsonValue1:[ADJUtilObj idOrNsNull:stringValue1]
                           key2:key2
                     jsonValue2:[ADJUtilObj idOrNsNull:stringValue2]];
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
                           actualStringValue:(nullable NSString *)actualStringValue
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
                                    [ADJUtilObj idOrNsNull:actualStringValue], ADJLogActualKey,
                                    nil]]];
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
                                 stringValue:(nullable NSString *)stringValue
                                   issueType:(nonnull ADJIssue)issueType
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelDebug
                               issueType:issueType
                               resultFail:nil
                               messageParams:
                                   [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [ADJUtilObj idOrNsNull:stringValue], key, nil]]];
}
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                         key:(nonnull NSString *)key
                                 stringValue:(nullable NSString *)stringValue
                                  resultFail:(nonnull ADJResultFail *)resultFail
                                   issueType:(nullable ADJIssue)issueType
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelDebug
                               issueType:issueType
                               resultFail:resultFail
                               messageParams:
                                   [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [ADJUtilObj idOrNsNull:stringValue], key, nil]]];
}

- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        key1:(nonnull NSString *)key1
                                stringValue1:(nullable NSString *)stringValue1
                                        key2:(nonnull NSString *)key2
                                stringValue2:(nullable NSString *)stringValue2
                                   issueType:(nullable ADJIssue)issueType
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelDebug
                               issueType:issueType
                               resultFail:nil
                               messageParams:
                                   [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [ADJUtilObj idOrNsNull:stringValue1], key1,
                                    [ADJUtilObj idOrNsNull:stringValue2], key2, nil]]];
}

#pragma mark - info client
- (nonnull ADJInputLogMessageData *)infoClient:(nonnull NSString *)message {
    return [self logWithMessage:message logLevel:ADJAdjustLogLevelInfo];
}
- (nonnull ADJInputLogMessageData *)infoClient:(nonnull NSString *)message
                                           key:(nonnull NSString *)key
                                   stringValue:(nullable NSString *)stringValue
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelInfo
                            key:key
                      jsonValue:[ADJUtilObj idOrNsNull:stringValue]];
}
- (nonnull ADJInputLogMessageData *)infoClient:(nonnull NSString *)message
                                          key1:(nonnull NSString *)key1
                                  stringValue1:(nullable NSString *)stringValue1
                                          key2:(nonnull NSString *)key2
                                  stringValue2:(nullable NSString *)stringValue2
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelInfo
                           key1:key1
                     jsonValue1:[ADJUtilObj idOrNsNull:stringValue1]
                           key2:key2
                     jsonValue2:[ADJUtilObj idOrNsNull:stringValue2]];
}

#pragma mark - notice client
- (nonnull ADJInputLogMessageData *)noticeClient:(nonnull NSString *)message {
    return [self logWithMessage:message logLevel:ADJAdjustLogLevelNotice];
}
- (nonnull ADJInputLogMessageData *)noticeClient:(nonnull NSString *)message
                                             key:(nonnull NSString *)key
                                     stringValue:(nullable NSString *)stringValue
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelNotice
                            key:key
                      jsonValue:[ADJUtilObj idOrNsNull:stringValue]];
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
                                    stringValue:(nullable NSString *)stringValue
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelError
                            key:key
                      jsonValue:[ADJUtilObj idOrNsNull:stringValue]];
}
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                  expectedValue:(nonnull NSString *)expectedValue
                              actualStringValue:(nullable NSString *)actualStringValue
{
    return [self logWithMessage:message
                       logLevel:ADJAdjustLogLevelError
                           key1:ADJLogExpectedKey
                     jsonValue1:expectedValue
                           key2:ADJLogActualKey
                     jsonValue2:[ADJUtilObj idOrNsNull:actualStringValue]];
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
                                           from:(nonnull NSString *)from
                                     resultFail:(nullable ADJResultFail *)resultFail
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelError
                               issueType:nil
                               resultFail:resultFail
                               messageParams:[[NSDictionary alloc] initWithObjectsAndKeys:
                                              from, ADJLogFromKey, nil]]];
}
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                            key:(nonnull NSString *)key
                                    stringValue:(nullable NSString *)stringValue
                                     resultFail:(nonnull ADJResultFail *)resultFail
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:ADJAdjustLogLevelError
                               issueType:nil
                               resultFail:resultFail
                               messageParams:[[NSDictionary alloc] initWithObjectsAndKeys:
                                              [ADJUtilObj idOrNsNull:stringValue], key, nil]]];
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
                                         jsonValue:(nonnull id)jsonValue
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:logLevel
                               messageParams:[[NSDictionary alloc]
                                              initWithObjectsAndKeys:jsonValue, key, nil]]];
}

- (nonnull ADJInputLogMessageData *)logWithMessage:(nonnull NSString *)message
                                          logLevel:(nonnull ADJAdjustLogLevel)logLevel
                                              key1:(nonnull NSString *)key1
                                        jsonValue1:(nonnull id)jsonValue1
                                              key2:(nonnull NSString *)key2
                                        jsonValue2:(nonnull id)jsonValue2
{
    return [self logWithInput:[[ADJInputLogMessageData alloc]
                               initWithMessage:message
                               level:logLevel
                               messageParams:[[NSDictionary alloc] initWithObjectsAndKeys:
                                              jsonValue1, key1,
                                              jsonValue2, key2, nil]]];
}

@end
