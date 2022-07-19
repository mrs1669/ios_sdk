//
//  ADJThreadPool.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJTimeLengthMilli.h"

@protocol ADJThreadPool <NSObject>

- (BOOL)executeAsyncWithBlock:(nonnull void (^)(void))blockToExecute;

- (BOOL)scheduleAsyncWithBlock:(nonnull void (^)(void))blockToSchedule
                delayTimeMilli:(nonnull ADJTimeLengthMilli *)delayTimeMilli;

- (BOOL)
    executeSynchronouslyWithTimeout:(nonnull ADJTimeLengthMilli *)timeout
    blockToExecute:(nonnull void (^)(void))blockToExecute;

- (nonnull dispatch_queue_t)backgroundAsyncDispatchQueue;

@end
