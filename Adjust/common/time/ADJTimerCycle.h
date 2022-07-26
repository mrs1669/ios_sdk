//
//  ADJTimerCycle.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJTimeLengthMilli.h"

@interface ADJTimerCycle : NSObject
// instantiation
- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;

// public api
- (void)cycleWithDelayTimeMilli:(nonnull ADJTimeLengthMilli *)delayTimeMilli
                  cycleInterval:(nonnull ADJTimeLengthMilli *)cycleIntervalMilli
                          block:(nonnull dispatch_block_t)block;

- (BOOL)cancelDelayAndCycle;

@end
