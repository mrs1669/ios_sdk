//
//  ATLSingleThreadExecutor.h
//  AdjustTestLibrary
//
//  Created by Pedro S. on 23.07.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATLSingleThreadExecutor : NSObject

- (BOOL)executeInSequenceWithBlock:(nonnull void (^)(void))blockToExecute;

- (void)finalizeAtTeardown;

- (void)clearQueuedBlocks;

@end
