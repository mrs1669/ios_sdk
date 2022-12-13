//
//  ADJAtomicTallyCounter.h
//  Adjust
//
//  Created by Pedro Silva on 06.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJAtomicTallyCounter : NSObject
// instantiation
- (nonnull instancetype)initSeqCstMemoryOrderStartingAtZero;
- (nonnull instancetype)initSeqCstMemoryOrderStartingAtOne;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (NSUInteger)incrementAndGetPreviousValue;

@end
