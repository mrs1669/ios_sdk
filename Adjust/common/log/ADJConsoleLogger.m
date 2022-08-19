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

#pragma mark Fields
@interface ADJConsoleLogger ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic)
NSMutableArray<ADJAdjustLogMessageData *> *logMessageDataArray;
@property (nonnull, readwrite, strong, nonatomic) ADJNonEmptyString *configLogLevel;
@property (assign, nonatomic) BOOL hasSdkInit;
@property (assign, nonatomic) BOOL isInSandboxEnvironment;
@property (strong, nonatomic, readwrite, nonnull)
os_log_t osLogLogger
API_AVAILABLE(macos(10.12), ios(10.0), watchos(3.0), tvos(10.0), macCatalyst(13.0));

@end

@implementation ADJConsoleLogger
#pragma mark Instantiation
- (nonnull instancetype)init {
    self = [super init];
    
    _logMessageDataArray = [NSMutableArray array];
    
    _configLogLevel = [[ADJNonEmptyString alloc]
                       initWithConstStringValue:ADJAdjustLogLevelDebug];
    
    _isInSandboxEnvironment = NO;
    
    _hasSdkInit = NO;
    
    if (@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)) {
        _osLogLogger =
        os_log_create(ADJAdjustSubSystem.UTF8String, ADJAdjustCategory.UTF8String);
    }
    
    return self;
}

#pragma mark Public API
- (void)setEnvironmentToSandbox {
    if (self.isInSandboxEnvironment) {
        return;
    }
    
    self.isInSandboxEnvironment = YES;
    
    /*
     if (@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)) {
     for (ADJAdjustLogMessageData *logMessageData in self.logMessageDataArray) {
     [self printLogMessage:[NSString stringWithFormat:
     @"[%@]%@", logMessageData.source, logMessageData.logMessage]
     adjustLogLevel:logMessageData.adjustLogLevel
     osLogLogger:osLogLogger];
     }
     } else {
     */
    for (ADJAdjustLogMessageData *logMessageData in self.logMessageDataArray) {
        [self printLogMessage:[NSString stringWithFormat:
                               @"Pre-Init|%@", logMessageData.logMessage]
                       source:logMessageData.source
              messageLogLevel:logMessageData.messageLogLevel];
    }
    //}
    [self.logMessageDataArray removeAllObjects];
}

- (void)didLogMessage:(nonnull NSString *)logMessage
               source:(nonnull NSString *)source
      messageLogLevel:(nonnull NSString *)messageLogLevel {
    if (self.isInSandboxEnvironment) {
        [self printLogMessage:logMessage
                       source:source
              messageLogLevel:messageLogLevel];
        return;
    }
    // discard if SDK has been initialised in production
    if (self.hasSdkInit) {
        return;
    }
    
    // save log message to process when SDK gets initialised
    [self.logMessageDataArray addObject:[[ADJAdjustLogMessageData alloc]
                                         initWithLogMessage:logMessage
                                         source:source
                                         messageLogLevel:messageLogLevel]];
    
    // print error log, when it's in debug mode, even in production environment
#ifdef DEBUG
    if ([messageLogLevel isEqualToString:ADJAdjustLogLevelError]) {
        [self printLogMessage:logMessage
                       source:source
              messageLogLevel:messageLogLevel];
    }
#endif
}

- (void)didSdkInitWithIsSandboxEnvironment:(BOOL)isSandboxEnvironment
                                  logLevel:(nullable ADJNonEmptyString *)logLevel {
    self.hasSdkInit = YES;
    
    if (logLevel != nil) {
        self.configLogLevel = logLevel;
    }
    
    if (isSandboxEnvironment) {
        [self setEnvironmentToSandbox];
    }
}

#pragma mark Internal Methods
- (void)printLogMessage:(nonnull NSString *)logMessage
                 source:(nonnull NSString *)source
        messageLogLevel:(nonnull NSString *)messageLogLevel {

    // TODO: (Gena) Simplify the following block - call [self logOnConsoleWithLogMessage...] only in one place.

    if ([self.configLogLevel.stringValue isEqual:ADJAdjustLogLevelDebug]) {
        //  - AdjustLogLevel.DEBUG -> print any android log level message
        [self logOnConsoleWithLogMessage:logMessage
                                  source:source
                         messageLogLevel:messageLogLevel];
    } else if ([self.configLogLevel.stringValue isEqual:ADJAdjustLogLevelInfo]) {
        //  - AdjustLogLevel.INFO -> print INFO and ERROR android log level messages
        if (! [messageLogLevel isEqualToString:ADJAdjustLogLevelDebug]) {
            [self logOnConsoleWithLogMessage:logMessage
                                      source:source
                             messageLogLevel:messageLogLevel];
        }
    } else {
        //  - AdjustLogLevel.ERROR -> print only ERROR android log level messages
        if ([messageLogLevel isEqualToString:ADJAdjustLogLevelError]) {
            [self logOnConsoleWithLogMessage:logMessage
                                      source:source
                             messageLogLevel:messageLogLevel];
        }
    }
}

- (void)logOnConsoleWithLogMessage:(nonnull NSString *)logMessage
                            source:(nonnull NSString *)source
                   messageLogLevel:(nonnull NSString *)messageLogLevel {
    if (@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, macCatalyst 13.0, *)) {
        NSString *fullLogMessage =
        [NSString stringWithFormat:@"[%@][%@] %@",
         messageLogLevel, source, logMessage];
        if (messageLogLevel == ADJAdjustLogLevelDebug) {
            os_log_debug(self.osLogLogger, "%{public}s", fullLogMessage.UTF8String);
        } else if (messageLogLevel == ADJAdjustLogLevelInfo) {
            os_log_info(self.osLogLogger, "%{public}s", fullLogMessage.UTF8String);
        } else if (messageLogLevel == ADJAdjustLogLevelError) {
            os_log_error(self.osLogLogger, "%{public}s", fullLogMessage.UTF8String);
        }
    } else {
        NSLog(@"%@", [ADJAdjustLogMessageData
                      generateFullLogWithMessage:logMessage
                      source:source
                      messageLogLevel:messageLogLevel]);
    }
}

@end

