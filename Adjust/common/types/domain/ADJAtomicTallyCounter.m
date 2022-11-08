//
//  ADJAtomicTallyCounter.m
//  Adjust
//
//  Created by Pedro Silva on 06.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAtomicTallyCounter.h"

#import <stdatomic.h>

#pragma mark Fields
@implementation ADJAtomicTallyCounter {
#pragma mark - Unmanaged variables
#if __LP64__
    volatile atomic_ulong _atomicUI;
#else
    volatile atomic_uint _atomicUI;
#endif
    memory_order _memoryOrder;
}
#pragma mark Instantiation
- (nonnull instancetype)initSeqCstMemoryOrderStartingAtZero {
    return [self initWithInitialUIntValue:0 memoryOrder:__ATOMIC_SEQ_CST];
}

- (nonnull instancetype)initSeqCstMemoryOrderStartingAtOne {
    return [self initWithInitialUIntValue:1 memoryOrder:__ATOMIC_SEQ_CST];
}


- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private Constructors
- (nonnull instancetype)initWithInitialUIntValue:(NSUInteger)initialUIntValue
                                     memoryOrder:(memory_order)memoryOrder
{
    self = [super init];

    atomic_init(&_atomicUI, initialUIntValue);
    _memoryOrder = memoryOrder;
    
    return self;
}

// public api
- (NSUInteger)incrementAndGetPreviousValue {
    // returns previously held value
    //  meaning that the first return will be the initial value
    return atomic_fetch_add_explicit(&_atomicUI, 1, _memoryOrder);
}

@end
