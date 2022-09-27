//
//  ADJPluginLogger.m
//  Adjust
//
//  Created by Pedro S. on 17.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJPluginLogger.h"

@interface ADJPluginLogger ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic)ADJLogger *logger;

#pragma mark - Internal variables
@end

@implementation ADJPluginLogger
#pragma mark Instantiation
- (nonnull instancetype)initWithLogger:(nonnull ADJLogger *)logger {
    self = [super init];

    _logger = logger;

    return self;
}

#pragma mark Public API
#pragma mark - ADJAdjustLogger
- (nonnull NSString *)debug:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);

    return [self.logger debug:message parameters:parameters];
}

- (nonnull NSString *)info:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);

    return [self.logger info:message parameters:parameters];
}

- (nonnull NSString *)error:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);

    return [self.logger error:message parameters:parameters];
}

- (nonnull NSString *)errorWithNSError:(nonnull NSError *)error
                               message:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);

    return [self.logger errorWithNSError:error message:message parameters:parameters];
}

@end
