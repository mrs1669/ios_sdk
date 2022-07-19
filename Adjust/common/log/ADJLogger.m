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

//#import <os/log.h>

@interface ADJLogger ()
// Injected variables
@property (nullable, readonly, weak, nonatomic) id<ADJLogCollector> logCollectorWeak;

// Internal variables
/*
@property (strong, nonatomic, readwrite, nonnull)
    os_log_t osLogLogger
    API_AVAILABLE(macos(10.12), ios(10.0), watchos(3.0), tvos(10.0));
 */
@end

@implementation ADJLogger
#pragma mark Constructors
- (nonnull instancetype)initWithSource:(nonnull NSString *)source
                          logCollector:(nonnull id<ADJLogCollector>)logCollector
{
    self = [super init];

    _source = source;
    _logCollectorWeak = logCollector;

    /*
    if (@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)) {
        _osLogLogger = os_log_create(ADJAdjustSubSystem.UTF8String, self.source.UTF8String);
    }
     */
    return self;
}
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull NSString *)debug:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);

    return [self debug:message parameters:parameters];
}
- (nonnull NSString *)debug:(nonnull NSString *)message parameters:(va_list)parameters {
    return [self log:message parameters:parameters messageLogLevel:ADJAdjustLogLevelDebug];
}

- (nonnull NSString *)info:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);

    return [self info:message parameters:parameters];
}
- (nonnull NSString *)info:(nonnull NSString *)message parameters:(va_list)parameters {
    return [self log:message parameters:parameters messageLogLevel:ADJAdjustLogLevelInfo];
}

- (nonnull NSString *)error:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);

    return [self error:message parameters:parameters];
}
- (nonnull NSString *)error:(nonnull NSString *)message parameters:(va_list)parameters {
    return [self log:message parameters:parameters messageLogLevel:ADJAdjustLogLevelError];
}

- (nonnull NSString *)errorWithNSError:(nonnull NSError *)error
                               message:(nonnull NSString *)message, ...
{
    va_list parameters; va_start(parameters, message);

    return [self errorWithNSError:error message:message parameters:parameters];
}
- (nonnull NSString *)errorWithNSError:(nonnull NSError *)error
                               message:(nonnull NSString *)message
                            parameters:(va_list)parameters
{
    NSString *_Nonnull formattedWithError = [ADJLogger formatNSError:error message:message];
    return [self log:formattedWithError parameters:parameters messageLogLevel:ADJAdjustLogLevelError];
}

+ (nonnull NSString *)formatNSError:(nonnull NSError *)error
                            message:(nonnull NSString *)message
{
    return [NSString stringWithFormat:@"%@, with NSError: %@",
            message, [ADJUtilF errorFormat:error]];
}

#pragma mark Internal methods
- (nonnull NSString *)log:(nonnull NSString *)message
               parameters:(va_list)parameters
           messageLogLevel:(nonnull NSString *)messageLogLevel
{
    NSString *_Nonnull formattedMessage =
        [[NSString alloc] initWithFormat:message arguments:parameters];
    va_end(parameters);

    id<ADJLogCollector> _Nullable logCollector = self.logCollectorWeak;
    if (logCollector != nil) {
        /*
        if (@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)) {
            [self.logCollector collectLogMessage:formattedMessage
                                          source:self.source
                                  adjustLogLevel:adjustLogLevel
                                     osLogLogger:self.osLogLogger];
        } else {
         */
        [logCollector collectLogMessage:formattedMessage
                                 source:self.source
                         messageLogLevel:messageLogLevel];
        //}
    }

    return formattedMessage;
}

@end
