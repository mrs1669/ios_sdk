//
//  ADJTimerOnce.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJTimeLengthMilli.h"

@interface ADJTimerOnce : NSObject
// instantiation
- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;

// public api
- (void)executeWithDelayTimeMilli:(nonnull ADJTimeLengthMilli *)timeLengthInterval
                            block:(nonnull dispatch_block_t)block;

- (BOOL)cancelDelay;

- (BOOL)isInDelay;

@end
