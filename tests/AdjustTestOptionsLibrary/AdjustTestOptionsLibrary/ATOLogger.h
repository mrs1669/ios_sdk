//
//  ATOLogger.h
//  AdjustTestApp
//
//  Created by Pedro S. on 28.05.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJ5Logger.h"
#import "ADJ5LogCollector.h"

@interface ATOLogger : ADJ5Logger<ADJ5LogCollector>

+ (nonnull instancetype)sharedInstance;

@end
