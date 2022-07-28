//
//  ATOLogger.h
//  AdjustTestApp
//
//  Created by Pedro S. on 28.05.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJLogger.h"
#import "ADJLogCollector.h"

@interface ATOLogger : ADJLogger<ADJLogCollector>

+ (nonnull instancetype)sharedInstance;

@end
