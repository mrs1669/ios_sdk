//
//  ATOLogger.m
//  AdjustTestApp
//
//  Created by Pedro S. on 28.05.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import "ATOLogger.h"

#import <os/log.h>
#import "ADJ5AdjustLogMessageData.h"

@interface ATOLogger ()

@property (strong, nonatomic, readwrite, nonnull)
    os_log_t osLogLogger
API_AVAILABLE(macos(10.12), ios(10.0), watchos(3.0), tvos(10.0), macCatalyst(13.0));

@end

@implementation ATOLogger

+ (nonnull instancetype)sharedInstance {
    static dispatch_once_t loggerInstanceToken;
    static ATOLogger *loggerInstance;
    dispatch_once(&loggerInstanceToken, ^{
        loggerInstance = [[ATOLogger alloc] initTestLogger];
    });

    return loggerInstance;
}

- (nonnull instancetype)initTestLogger {
    self = [super initWithSource:@"ATOLogger" logCollector:self];

    if (@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)) {
        _osLogLogger = os_log_create("com.adjust.sdk", "Adjust");
    }

    return self;
}

// copied from ADJ5ConsoleLogger
- (void)collectLogMessage:(nonnull NSString *)logMessage
                   source:(nonnull NSString *)source
           messageLogLevel:(nonnull NSString *)messageLogLevel
{
    if (@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, macCatalyst 13.0, *)) {
        NSString *fullLogMessage =
            [NSString stringWithFormat:@"[%@][%@] %@",
                messageLogLevel, source, logMessage];
        if (messageLogLevel == ADJ5AdjustLogLevelDebug) {
            os_log_debug(self.osLogLogger, "%{public}s", fullLogMessage.UTF8String);
        } else if (messageLogLevel == ADJ5AdjustLogLevelInfo) {
            os_log_info(self.osLogLogger, "%{public}s", fullLogMessage.UTF8String);
        } else if (messageLogLevel == ADJ5AdjustLogLevelError) {
            os_log_error(self.osLogLogger, "%{public}s", fullLogMessage.UTF8String);
        }
    } else {
        NSLog(@"%@", [ADJ5AdjustLogMessageData
                        generateFullLogWithMessage:logMessage
                        source:source
                        messageLogLevel:messageLogLevel]);
    }
}

@end
