//
//  ADJLogger.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJLogCollector.h"
#import "ADJLogBuilder.h"
#import "ADJLogBuildCallback.h"

@interface ADJLogger : NSObject <ADJLogBuildCallback>
// instantiation
- (nonnull instancetype)initWithSource:(nonnull NSString *)source
                          logCollector:(nonnull id<ADJLogCollector>)logCollector
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

@property (nonnull, readonly, strong, nonatomic) NSString *source;

// public API
- (nonnull ADJLogBuilder *)debugDevStart:(nonnull NSString *)message;

- (nonnull id<ADJClientLogBuilder>)infoClientStart:(nonnull NSString *)message;
- (void)infoClient:(nonnull NSString *)message;
- (void)infoClient:(nonnull NSString *)message
               key:(nonnull NSString *)key
             value:(nullable NSString *)value;

- (nonnull id<ADJClientLogBuilder>)noticeClientStart:(nonnull NSString *)message;
- (void)noticeClient:(nonnull NSString *)message;
- (void)noticeClient:(nonnull NSString *)message
                 key:(nonnull NSString *)key
               value:(nullable NSString *)value;

- (nonnull id<ADJClientLogBuilder>)errorClientStart:(nonnull NSString *)message;
- (void)errorClient:(nonnull NSString *)message;
- (void)errorClient:(nonnull NSString *)message
                key:(nonnull NSString *)key
              value:(nullable NSString *)value;

//- (void)logWithBuilder:(nonnull ADJLogBuilder *)logBuilder;
/*
- (nonnull NSString *)
    traceThreadChangeWithCallerId:(nullable ADJNonNegativeInt *)callerThreadId
    runningThreadId:(nonnull ADJNonNegativeInt *)runningThreadId
    sourceDescription:(nonnull NSString *)sourceDescription;
*/
/*
- (nonnull NSString *)debugWithIssue:(nonnull NSString *)issueType
                             message:(nonnull NSString *)message;
- (nonnull NSString *)debugWithIssue:(nonnull NSString *)issueType
                  messageAndKvParams:(nonnull NSString *)message, ... NS_REQUIRES_NIL_TERMINATION;
- (nonnull NSString *)debugWithIssue:(nonnull NSString *)issueType
                             message:(nonnull NSString *)message
                      stringMapParam:(nonnull NSDictionary<NSString *, NSString*> *)stringMapParam;
*/

- (nonnull NSString *)debug:(nonnull NSString *)message, ... NS_FORMAT_FUNCTION(1,2);
- (nonnull NSString *)debug:(nonnull NSString *)message parameters:(va_list)parameters;

- (nonnull NSString *)info:(nonnull NSString *)message, ... NS_FORMAT_FUNCTION(1,2);
- (nonnull NSString *)info:(nonnull NSString *)message parameters:(va_list)parameters;

- (nonnull NSString *)error:(nonnull NSString *)message, ... NS_FORMAT_FUNCTION(1,2);
- (nonnull NSString *)error:(nonnull NSString *)message parameters:(va_list)parameters;

- (nonnull NSString *)errorWithNSError:(nonnull NSError *)error
                               message:(nonnull NSString *)message, ... NS_FORMAT_FUNCTION(2,3);
- (nonnull NSString *)errorWithNSError:(nonnull NSError *)error
                               message:(nonnull NSString *)message
                            parameters:(va_list)parameters;

+ (nonnull NSString *)formatNSError:(nonnull NSError *)error
                            message:(nonnull NSString *)message;

@end
