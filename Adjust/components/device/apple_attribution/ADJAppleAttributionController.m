//
//  ADJAppleAttributionController.m
//  Adjust
//
//  Created by Pedro S. on 04.08.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJAppleAttributionController.h"

#import "ADJNonEmptyString.h"

@implementation ADJAppleAttributionController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory {
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"ADJAppleAttributionController"];
    
    return self;
}

// return
- (nullable ADJNonEmptyString *)readAdsAttributionToken {
    return nil;
}

@end

