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

// TODO: fix import references
@class ADJInstanceIdData;
//#import "ADJInstanceIdData.h"

@interface ADJLogger : NSObject
// instantiation
- (nonnull instancetype)initWithSource:(nonnull NSString *)source
                          logCollector:(nonnull id<ADJLogCollector>)logCollector
                            instanceId:(nonnull ADJInstanceIdData *)instanceId
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

@property (nonnull, readonly, strong, nonatomic) NSString *source;

// public API
- (nonnull ADJInputLogMessageData *)logWithInput:
    (nonnull ADJInputLogMessageData *)inputLogMessageData;

- (nonnull ADJInputLogMessageData *)
    traceThreadChangeWithCallerThreadId:(nonnull NSString *)callerThreadId
    runningThreadId:(nonnull NSString *)runningThreadId
    callerDescription:(nonnull NSString *)callerDescription;

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
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                               messageParams:(nonnull NSDictionary<NSString *, id> *)messageParams;

// debug dev with issue
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                     nserror:(nullable NSError *)nserror
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                     nserror:(nullable NSError *)nserror
                                         key:(nonnull NSString *)key
                                       value:(nullable NSString *)value
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                               expectedValue:(nonnull NSString *)expectedValue
                                 actualValue:(nullable NSString *)actualValue
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                   valueName:(nonnull NSString *)valueName
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        from:(nonnull NSString *)from
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                         key:(nonnull NSString *)key
                                       value:(nullable NSString *)value
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        from:(nonnull NSString *)from
                                         key:(nonnull NSString *)key
                                       value:(nullable NSString *)value
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                                        key1:(nonnull NSString *)key1
                                      value1:(nullable NSString *)value1
                                        key2:(nonnull NSString *)key2
                                      value2:(nullable NSString *)value2
                                   issueType:(nonnull ADJIssue)issueType;
- (nonnull ADJInputLogMessageData *)debugDev:(nonnull NSString *)message
                               messageParams:(nonnull NSDictionary<NSString *, id> *)messageParams
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
                                            from:(nonnull NSString *)from;

// error client
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message;
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                        nserror:(nullable NSError *)nserror;
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                            key:(nonnull NSString *)key
                                          value:(nullable NSString *)value;
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                  expectedValue:(nonnull NSString *)expectedValue
                                    actualValue:(nullable NSString *)actualValue;
- (nonnull ADJInputLogMessageData *)errorClient:(nonnull NSString *)message
                                           from:(nonnull NSString *)from;


@end
