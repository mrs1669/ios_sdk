//
//  ADJCommonBase.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJCommonBase.h"

@implementation ADJCommonBase

#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                   loggerName:(nonnull NSString *)loggerName
{
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJCommonBase class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    
    self = [super init];
    
    _logger = [loggerFactory createLoggerWithName:loggerName];
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
