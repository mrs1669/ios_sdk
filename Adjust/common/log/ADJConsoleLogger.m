//
//  ADJConsoleLogger.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJConsoleLogger.h"

#import <os/log.h>

#import "ADJAdjustLogMessageData.h"
#import "ADJConstants.h"
#import "ADJUtilObj.h"

#pragma mark Fields
@interface ADJConsoleLogger ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) NSMutableArray<ADJLogMessageData *> *preSdkInitLogArray;
//@property (nonnull, readwrite, strong, nonatomic) ADJNonEmptyString *configLogLevel;
@property (assign, nonatomic) BOOL printClientLogs;
@property (assign, nonatomic) BOOL printDevLogs;
@property (assign, nonatomic) BOOL hasSdkInit;
@property (assign, nonatomic) BOOL isInSandboxEnvironment;
@property (nonnull, readonly, strong, nonatomic) os_log_t osLogLogger;

@end

@implementation ADJConsoleLogger
#pragma mark Instantiation
- (nonnull instancetype)initWithSdkConfigData:(nonnull ADJSdkConfigData *)sdkConfigData {
    self = [super init];

    _preSdkInitLogArray = [NSMutableArray array];

    _printClientLogs = YES;

    _printDevLogs = sdkConfigData.assumeDevLogs;

    _isInSandboxEnvironment = sdkConfigData.assumeSandboxEnvironmentForLogging;

    _hasSdkInit = NO;

    _osLogLogger = os_log_create(ADJAdjustSubSystem.UTF8String, ADJAdjustCategory.UTF8String);

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (void)didLogMessage:(nonnull ADJLogMessageData *)logMessageData {
    if (self.isInSandboxEnvironment) {
        [self printToConsoleWithData:logMessageData isPreSdkInit:NO];
        return;
    }

    // discard if SDK has been initialised in production
    if (self.hasSdkInit) {
        return;
    }

    // save log message to process when SDK gets initialised
    [self.preSdkInitLogArray addObject:logMessageData];

    // print error log, when it's in debug mode, even in production environment
    /*
     #ifdef DEBUG
     if ([messageLogLevel isEqualToString:ADJAdjustLogLevelError]) {
     [self printLogMessage:logMessage
     source:source
     messageLogLevel:messageLogLevel];
     }
     #endif
     */
}

- (void)didSdkInitWithIsSandboxEnvironment:(BOOL)isSandboxEnvironment
                                  doLogAll:(BOOL)doLogAll
                               doNotLogAny:(BOOL)doNotLogAny {
    self.hasSdkInit = YES;

    if (! isSandboxEnvironment) {
        return;
    }

    if (self.isInSandboxEnvironment) {
        return;
    }

    self.isInSandboxEnvironment = YES;

    if (doNotLogAny) {
        self.printClientLogs = NO;
        self.printDevLogs = NO;
    } else if (doLogAll) {
        self.printClientLogs = YES;
        self.printDevLogs = YES;
    }

    if (self.printDevLogs || self.printClientLogs) {
        for (ADJLogMessageData *logMessageData in self.preSdkInitLogArray) {
            [self printToConsoleWithData:logMessageData
                            isPreSdkInit:YES];
        }
    }

    [self.preSdkInitLogArray removeAllObjects];
}

#pragma mark Internal Methods
- (void)printToConsoleWithData:(nonnull ADJLogMessageData *)logMessageData
                  isPreSdkInit:(BOOL)isPreSdkInit {
    if (logMessageData.inputData.level == ADJAdjustLogLevelTrace
        || logMessageData.inputData.level == ADJAdjustLogLevelDebug)
    {
        if (! self.printDevLogs) {
            return;
        }

        NSString *_Nonnull devFormattedMessage = [self devFormatMessage:logMessageData
                                                           isPreSdkInit:isPreSdkInit];

        [self osLogWithFullMessage:devFormattedMessage
                   messageLogLevel:logMessageData.inputData.level];

        return;
    }

    // assume it's one of the client log levels
    if (! self.printClientLogs) {
        return;
    }

    NSString *_Nonnull clientFormattedMessage =
    [ADJConsoleLogger clientFormatMessage:logMessageData.inputData
                             isPreSdkInit:isPreSdkInit];

    [self osLogWithFullMessage:clientFormattedMessage
               messageLogLevel:logMessageData.inputData.level];
}

+ (nonnull NSString *)clientFormatMessage:(nonnull ADJInputLogMessageData *)inputLogMessageData
                             isPreSdkInit:(BOOL)isPreSdkInit {
    NSString *_Nonnull message = isPreSdkInit ?
    [NSString stringWithFormat:@"Pre-Init| %@", inputLogMessageData.message]
    : inputLogMessageData.message;

    NSMutableString *_Nonnull stringBuilder =
    [[NSMutableString alloc] initWithFormat:@"%@%@",
     [ADJConsoleLogger logLevelFormat:inputLogMessageData.level],
     message];

    if (inputLogMessageData.messageParams != nil) {
        [stringBuilder appendFormat:@" %@",
         [ADJLogMessageData generateJsonStringFromFoundationDictionary:
          inputLogMessageData.messageParams]];
    }

    if (inputLogMessageData.nsError != nil) {
        [stringBuilder appendFormat:@" %@",
         [ADJLogMessageData generateJsonStringFromFoundationDictionary:
          [ADJLogMessageData generateFoundationDictionaryFromNsError:
           inputLogMessageData.nsError]]];
    }

    if (inputLogMessageData.nsException != nil) {
        [stringBuilder appendFormat:@" %@",
         [ADJLogMessageData generateJsonStringFromFoundationDictionary:
          [ADJLogMessageData generateFoundationDictionaryFromNsException:
           inputLogMessageData.nsException]]];
    }

    return [stringBuilder description];
}

- (nonnull NSString *)devFormatMessage:(nonnull ADJLogMessageData *)logMessageData
                          isPreSdkInit:(BOOL)isPreSdkInit {
    NSMutableDictionary <NSString *, id> *_Nonnull foundationDictionary =
        [logMessageData generateFoundationDictionary];

    if (isPreSdkInit) {
        [foundationDictionary setObject:@(YES) forKey:ADJLogIsPreSdkInitKey];
    }

    [foundationDictionary removeObjectForKey:ADJLogInstanceIdKey];
    NSString *_Nonnull instanceIdFormat =
        logMessageData.idString == nil ?
        @"" : [NSString stringWithFormat:@"_%@", logMessageData.idString];

    [foundationDictionary removeObjectForKey:ADJLogCallerThreadIdKey];
    [foundationDictionary removeObjectForKey:ADJLogRunningThreadIdKey];
    NSString *_Nonnull threadIdFormat =
        [ADJConsoleLogger threadIdFormat:logMessageData];

    [foundationDictionary removeObjectForKey:ADJLogIssueKey];
    NSString *_Nonnull issueFormat =
        logMessageData.inputData.issueType == nil ?
        @"" : [NSString stringWithFormat:@"{%@}", logMessageData.inputData.issueType];

    [foundationDictionary removeObjectForKey:ADJLogLevelKey];
    ADJAdjustLogLevel _Nonnull logLevelFormat =
        [ADJConsoleLogger logLevelFormat:logMessageData.inputData.level];

    [foundationDictionary removeObjectForKey:ADJLogSourceKey];
    [foundationDictionary removeObjectForKey:ADJLogMessageKey];
    return [NSString stringWithFormat:@"%@%@%@[%@]%@ %@ %@",
            logLevelFormat,
            instanceIdFormat,
            threadIdFormat,
            logMessageData.sourceDescription,
            issueFormat,
            logMessageData.inputData.message,
            [ADJLogMessageData
             generateJsonStringFromFoundationDictionary:foundationDictionary]];
}

+ (nonnull NSString *)logLevelFormat:(nonnull ADJAdjustLogLevel)logLevel {
    if (logLevel == ADJAdjustLogLevelTrace) {
        return @"t/";
    }
    if (logLevel == ADJAdjustLogLevelDebug) {
        return @"d/";
    }
    if (logLevel == ADJAdjustLogLevelInfo) {
        return @"i/";
    }
    if (logLevel == ADJAdjustLogLevelNotice) {
        return @"n/";
    }
    if (logLevel == ADJAdjustLogLevelError) {
        return @"err/";
    }
    return @"u/";
}

+ (nonnull NSString *)threadIdFormat:(nonnull ADJLogMessageData *)logMessageData {
    NSString *_Nullable runningThreadId =
    logMessageData.inputData.runningThreadId != nil ?
    logMessageData.inputData.runningThreadId
    : logMessageData.runningThreadId != nil ?
    logMessageData.runningThreadId : nil;
    NSString *_Nullable callingThreadId = logMessageData.inputData.callerThreadId;

    if (callingThreadId == nil) {
        if (runningThreadId == nil) {
            return @"";
        }

        return [NSString stringWithFormat:@"<%@>", runningThreadId];
    }

    if (runningThreadId == nil) {
        return [NSString stringWithFormat:@"<%@->", callingThreadId];
    }

    return [NSString stringWithFormat:@"<%@-%@>",
            callingThreadId, runningThreadId];
}

- (void)osLogWithFullMessage:(nonnull NSString *)fullLogMessage
             messageLogLevel:(nonnull ADJAdjustLogLevel)messageLogLevel {
    uint8_t osLogType;

    if (messageLogLevel == ADJAdjustLogLevelDebug
        || messageLogLevel == ADJAdjustLogLevelTrace)
    {
        osLogType = OS_LOG_TYPE_DEBUG;
    } else if (messageLogLevel == ADJAdjustLogLevelInfo) {
        osLogType = OS_LOG_TYPE_INFO;
    } else if (messageLogLevel == ADJAdjustLogLevelNotice) {
        osLogType = OS_LOG_TYPE_DEFAULT;
    } else if (messageLogLevel == ADJAdjustLogLevelError) {
        osLogType = OS_LOG_TYPE_ERROR;
    } else {
        return;
    }

    os_log_with_type(self.osLogLogger, osLogType,
                     "%{public}s", fullLogMessage.UTF8String);
}

@end


