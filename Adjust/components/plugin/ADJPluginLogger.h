//
//  ADJPluginLogger.h
//  Adjust
//
//  Created by Pedro S. on 17.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJAdjustLogger.h"
#import "ADJLogger.h"

@interface ADJPluginLogger : NSObject<ADJAdjustLogger>

- (nonnull instancetype)initWithLogger:(nonnull ADJLogger *)logger;

@end
