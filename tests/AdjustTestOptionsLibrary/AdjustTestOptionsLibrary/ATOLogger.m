//
//  ATOLogger.m
//  AdjustTestApp
//
//  Created by Pedro S. on 28.05.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import "ATOLogger.h"

#import <os/log.h>

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
    self = [super init];

    _osLogLogger = os_log_create("com.adjust.sdk", "AdjustTestOptions");

    return self;
}

+ (void)log:(nonnull NSString *)message {
    [[self sharedInstance] osLogWithFullMessage:message];
}

+ (void)log:(nonnull NSString *)message
        key:(nonnull NSString *)key
      value:(nonnull NSString *)value
{
    [[self sharedInstance] osLogWithFullMessage:
     [NSString stringWithFormat:@"%@ { %@: %@ }", message, key, value]];
}

+ (void)log:(nonnull NSString *)message
   failDict:(nonnull NSDictionary<NSString *, id> *)failDict
{
    [[self sharedInstance] osLogWithFullMessage:
     [NSString stringWithFormat:@"%@ fail { %@ }", message,
      [self generateJsonStringFromFoundationDictionary:failDict]]];
}

// adapted from core sdk
- (void)osLogWithFullMessage:(nonnull NSString *)fullLogMessage {
    os_log_with_type(self.osLogLogger, OS_LOG_TYPE_DEBUG,
                     "%{public}s", fullLogMessage.UTF8String);
}

+ (nonnull NSString *)generateJsonStringFromFoundationDictionary:
    (nonnull NSDictionary<NSString *, id> *)foundationDictionary
{
    id _Nonnull jsonDataOrStringError =
        [self convertToJsonDataWithJsonFoundationValue:foundationDictionary];

    if ([jsonDataOrStringError isKindOfClass:[NSString class]]) {
        return (NSString *)jsonDataOrStringError;
    }

    NSString *_Nullable converted =
        [[NSString alloc] initWithData:(NSData *)jsonDataOrStringError
                              encoding:NSUTF8StringEncoding];

    if (converted == nil) {
        return [NSString stringWithFormat:
                @"Nil string converting data from foundation dictionary: %@",
                [foundationDictionary description]];
    }

    return converted;
}

+ (nonnull id)convertToJsonDataWithJsonFoundationValue:(nonnull id)jsonFoundationValue
{
    // todo check isValidJSONObject:
    @try {
        NSError *_Nullable errorPtr = nil;
        // If the object will not produce valid JSON then an exception will be thrown
        NSData *_Nullable data =
            [NSJSONSerialization dataWithJSONObject:jsonFoundationValue options:0 error:&errorPtr];

        if (data != nil) {
            return data;
        }

        return [NSString stringWithFormat:
                @"Nil data converting from foundation value with error: %@, original: %@",
                [errorPtr localizedDescription], [jsonFoundationValue description]];
    } @catch (NSException *exception) {
        return [NSString stringWithFormat:
                @"Exception converting from foundation value to data: %@, original: %@",
                [exception description], [jsonFoundationValue description]];
    }
}

@end
