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
#import "ADJUtilF.h"

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

+ (nonnull NSString *)clientCallbackFormatMessageWithLog:
    (nonnull ADJInputLogMessageData *)inputLogMessageData
{
    NSMutableString *_Nonnull stringBuilder =
        [[NSMutableString alloc] initWithString:inputLogMessageData.message];

    return [ADJConsoleLogger buildClientLogParamsWithStringBuilder:stringBuilder
                                               inputLogMessageData:inputLogMessageData];
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

    return [ADJConsoleLogger buildClientLogParamsWithStringBuilder:stringBuilder
                                               inputLogMessageData:inputLogMessageData];
}

+ (nonnull NSString *)
    buildClientLogParamsWithStringBuilder:(nonnull NSMutableString *)stringBuilder
    inputLogMessageData:(nonnull ADJInputLogMessageData *)inputLogMessageData
{
    [stringBuilder appendString:
     [ADJUtilF
      emptyFallbackWithFormat:@"%@"
      string:inputLogMessageData.messageParams == nil ? nil :
         [[ADJUtilJson toStringFromDictionary:inputLogMessageData.messageParams] value]]];

    [stringBuilder appendString:
     [ADJUtilF
      emptyFallbackWithFormat:@" fail:%@"
      string:inputLogMessageData.resultFail == nil ? nil :
         [[ADJUtilJson toStringFromDictionary:[inputLogMessageData.resultFail
                                               toJsonDictionary]] value]]];

    return [stringBuilder description];
}

- (nonnull NSString *)devFormatMessage:(nonnull ADJLogMessageData *)logMessageData
                          isPreSdkInit:(BOOL)isPreSdkInit
{
    NSString *_Nonnull issueFormat = [ADJUtilF
                                      emptyFallbackWithFormat:@"{%@}"
                                      string:logMessageData.inputData.issueType];

    NSString *_Nonnull fromCallerFormat = [ADJUtilF
                                           emptyFallbackWithFormat:@" %@"
                                           string:logMessageData.inputData.fromCaller];

    // optional fails of json dictionary to string conversions are being ignored
    //  might be possible to do something with them in the future
    NSString *_Nonnull paramsFormat =
        [ADJUtilF
         emptyFallbackWithFormat:@"%@"
         string:logMessageData.inputData.messageParams == nil ? nil :
            [[ADJUtilJson toStringFromDictionary:logMessageData.inputData.messageParams] value]];

    NSString *_Nonnull failResultFormat =
        [ADJUtilF
         emptyFallbackWithFormat:@"fail:%@"
         string:logMessageData.inputData.resultFail == nil ? nil :
            [[ADJUtilJson toStringFromDictionary:[logMessageData.inputData.resultFail
                                                  toJsonDictionary]] value]];

    NSString *_Nonnull sdkPackageParamsFormat =
        [ADJUtilF
         emptyFallbackWithFormat:@"sdkPkg:%@"
         string:logMessageData.inputData.sdkPackageParams == nil ? nil :
             [ADJUtilObj
              formatNewlineKeyValuesWithName:@""
              stringKeyDictionary:logMessageData.inputData.sdkPackageParams]];

    ADJAdjustLogLevel _Nonnull clientLogLevelFormat =
        [ADJConsoleLogger clientLogLevelFormat:logMessageData.inputData.level];

    NSString *_Nonnull instanceIdFormat =
        [NSString stringWithFormat:@"_%@", logMessageData.idString];

    NSString *_Nonnull threadIdFormat = [ADJConsoleLogger threadIdFormat:logMessageData];

    NSString *_Nonnull preInitFormat = !isPreSdkInit ? @"" : @"PreInit";


    NSString *_Nonnull collectionsFormat =
        paramsFormat.length
            + failResultFormat.length
            + sdkPackageParamsFormat.length == 0 ? @"" :
        [NSString stringWithFormat:@" %@%@%@",
         paramsFormat, failResultFormat, sdkPackageParamsFormat];

    /**
     [loggerName]{issue} message fromCaller {params}fail:{fail}rest:{rest} clientLevel_instanceId<threadId>PreInit
     */
    return [NSString stringWithFormat:@"[%@]%@ %@%@%@ %@%@%@%@",
            logMessageData.loggerName,
            issueFormat,

            logMessageData.inputData.message,
            fromCallerFormat,

            collectionsFormat,

            clientLogLevelFormat,
            instanceIdFormat,
            threadIdFormat,
            preInitFormat];
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

+ (nonnull NSString *)clientLogLevelFormat:(nonnull ADJAdjustLogLevel)logLevel {
    if (logLevel == ADJAdjustLogLevelInfo) {
        return @"Info/";
    }
    if (logLevel == ADJAdjustLogLevelNotice) {
        return @"Notice/";
    }
    if (logLevel == ADJAdjustLogLevelError) {
        return @"Error/";
    }
    return @"";
}

+ (nonnull NSString *)threadIdFormat:(nonnull ADJLogMessageData *)logMessageData {
    NSString *_Nullable runningThreadId = [logMessageData runningThreadIdCoalesce];
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

+ (nonnull NSString *)formatSdkPackageParams:
    (nonnull NSDictionary<NSString *, NSString *> *)sdkPackageParams
{
    return [ADJUtilObj formatNewlineKeyValuesWithName:@""
                                  stringKeyDictionary:sdkPackageParams];
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


