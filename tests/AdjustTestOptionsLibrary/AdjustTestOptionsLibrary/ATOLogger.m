//
//  ATOLogger.m
//  AdjustTestApp
//
//  Created by Pedro S. on 28.05.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import "ATOLogger.h"

#import <os/log.h>
#import "ADJAdjustLogMessageData.h"
#import "ADJUtilObj.h"

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
    // TODO: fix logging bootstrapping with ADJNonNegativeInt
    self = [super initWithSource:@"ATOLogger" logCollector:self instanceId:nil];

    if (@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)) {
        _osLogLogger = os_log_create("com.adjust.sdk", "Adjust");
    }

    return self;
}

// copied from ADJConsoleLogger
- (void)collectLogMessage:(nonnull ADJLogMessageData *)logMessageData {
    NSMutableDictionary <NSString *, id> *_Nonnull foundationDictionary =
        [logMessageData generateFoundationDictionary];

    [foundationDictionary removeObjectForKey:ADJLogMessageKey];

    NSString *_Nonnull devFormattedMessage =
        [ADJUtilObj formatInlineKeyValuesWithName:logMessageData.inputData.message
                              stringKeyDictionary:foundationDictionary];

    if (@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, macCatalyst 13.0, *)) {
        uint8_t osLogType;

        NSString *_Nonnull messageLogLevel = logMessageData.inputData.message;

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
                         "%{public}s", devFormattedMessage.UTF8String);
    } else {
        NSLog(@"%@", devFormattedMessage);
    }
}

@end
