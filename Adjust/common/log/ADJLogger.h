//
//  ADJLogger.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJLogCollector.h"
#import "ADJInputLogMessageData.h"
#import "ADJInstanceIdData.h"

@interface ADJLogger : NSObject
// instantiation
- (nonnull instancetype)initWithName:(nonnull NSString *)name
                        logCollector:(nonnull id<ADJLogCollector>)logCollector
                          instanceId:(nonnull ADJInstanceIdData *)instanceId
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

@property (nonnull, readonly, strong, nonatomic) NSString *name;

// public API
- (nonnull ADJInputLogMessageData *)
    traceThreadChangeWithCallerThreadId:(nonnull NSString *)callerThreadId
    runningThreadId:(nonnull NSString *)runningThreadId
    callerDescription:(nonnull NSString *)callerDescription;

- (void)
    debugWithMessage:(nonnull NSString *)message
    builderBlock:(void (^ _Nonnull NS_NOESCAPE)(ADJLogBuilder *_Nonnull logBuilder))builderBlock;

// debug dev without issue
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message;

- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        from:(nonnull NSString *)from;

- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                         key:(nonnull NSString *)key
                                       value:(nullable NSString *)value;

- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        from:(nonnull NSString *)from
                                         key:(nonnull NSString *)key
                                       value:(nullable NSString *)value;

- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        key1:(nonnull NSString *)key1
                                      value1:(nullable NSString *)value1
                                        key2:(nonnull NSString *)key2
                                      value2:(nullable NSString *)value2;

// debug dev with issue
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                  resultFail:(nonnull ADJResultFail *)resultFail
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                               expectedValue:(nonnull NSString *)expectedValue
                                 actualValue:(nullable NSString *)actualValue
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                     subject:(nonnull NSString *)subject
                                  resultFail:(nonnull ADJResultFail *)resultFail
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                         key:(nonnull NSString *)key
                                       value:(nullable NSString *)value
                                   issueType:(nonnull ADJIssue)issueType;

- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                         key:(nonnull NSString *)key
                                       value:(nullable NSString *)value
                                  resultFail:(nonnull ADJResultFail *)resultFail
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        key1:(nonnull NSString *)key1
                                      value1:(nullable NSString *)value1
                                        key2:(nonnull NSString *)key2
                                      value2:(nullable NSString *)value2
                                   issueType:(nonnull ADJIssue)issueType;

// info client
- (nonnull ADJInputLogMessageData *)infoClient:(nonnull NSString *)message;

- (nonnull ADJInputLogMessageData *)infoClient:(nonnull NSString *)message
                                           key:(nonnull NSString *)key
                                         value:(nullable NSString *)value;

- (nonnull ADJInputLogMessageData *)infoClient:(nonnull NSString *)message
                                          key1:(nonnull NSString *)key1
                                        value1:(nullable NSString *)value1
                                          key2:(nonnull NSString *)key2
                                        value2:(nullable NSString *)value2;

// notice client
- (nonnull ADJInputLogMessageData *)noticeClient:(nonnull NSString *)message;

- (nonnull ADJInputLogMessageData *)noticeClient:(nonnull NSString *)message
                                             key:(nonnull NSString *)key
                                           value:(nullable NSString *)value;

- (nonnull ADJInputLogMessageData *)noticeClient:(nonnull NSString *)message
                                      resultFail:(nonnull ADJResultFail *)resultFail;

// error client
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message;

- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                            key:(nonnull NSString *)key
                                          value:(nullable NSString *)value;

- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                  expectedValue:(nonnull NSString *)expectedValue
                                    actualValue:(nullable NSString *)actualValue;

- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                     resultFail:(nonnull ADJResultFail *)resultFail;
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                            key:(nonnull NSString *)key
                                          value:(nullable NSString *)value
                                     resultFail:(nonnull ADJResultFail *)resultFail;

@end
