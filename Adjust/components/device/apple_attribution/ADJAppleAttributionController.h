//
//  ADJAppleAttributionController.h
//  Adjust
//
//  Created by Pedro S. on 04.08.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"

@interface ADJAppleAttributionController : ADJCommonBase
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory;


@end
