//
//  ADJAtomicBoolean.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAtomicBoolean.h"

#import <stdatomic.h>
#import <stdbool.h>

#pragma mark Fields
@implementation ADJAtomicBoolean {
#pragma mark - Unmanaged variables
    volatile atomic_bool _atomicB;
    memory_order _memoryOrder;
}

#pragma mark Instantiation
/*
 - (nonnull instancetype)initWithRelaxedValue:(BOOL)value {
 return [self initWithValue:value memoryOrder:__ATOMIC_RELAXED];
 }
 
 - (nonnull instancetype)initWithSeqCstValue:(BOOL)value {
 return [self initWithValue:value memoryOrder:__ATOMIC_SEQ_CST];
 }
 */
- (nonnull instancetype)initSeqCstMemoryOrderWithInitialBoolValue:(BOOL)initialBoolValue {
    return [self initWithInitialBoolValue:initialBoolValue memoryOrder:__ATOMIC_SEQ_CST];
}

#pragma mark - Private Constructors
- (nonnull instancetype)initWithInitialBoolValue:(BOOL)initialBoolValue
                                     memoryOrder:(memory_order)memoryOrder {
    self = [super init];
    
    if (initialBoolValue) {
        atomic_init(&_atomicB, true);
    } else {
        atomic_init(&_atomicB, false);
    }
    
    _memoryOrder = memoryOrder;
    
    return self;
}

#pragma mark Public API
- (BOOL)boolValue {
    return atomic_load_explicit(&_atomicB, _memoryOrder) ? YES : NO;
}

- (void)setBoolValue:(BOOL)boolValue {
    if (boolValue) {
        atomic_store_explicit(&_atomicB, true, _memoryOrder);
    } else {
        atomic_store_explicit(&_atomicB, false, _memoryOrder);
    }
}

// atomically sets a desired value if the current value matches the expected value.
//  Returns YES if successful, NO otherwise
- (BOOL)compareTo:(BOOL)expected andSetDesired:(BOOL)desired {
    bool expectedB = expected ? true : false;
    bool desiredB = desired ? true : false;
    
    return
    atomic_compare_exchange_strong_explicit(&_atomicB,
                                            &expectedB,
                                            desiredB,
                                            _memoryOrder,
                                            _memoryOrder)
    ? YES : NO;
    /* The behavior of atomic_compare_exchange_* family is
     as if the following was executed atomically:
     
     if (memcmp(obj, expected, sizeof *obj) == 0) {
     memcpy(obj, &desired, sizeof *obj);
     return true;
     } else {
     memcpy(expected, obj, sizeof *obj);
     return false;
     }
     */
}

- (BOOL)testAndSetTrue {
    return atomic_exchange_explicit(&_atomicB, true, _memoryOrder) ? YES : NO;
}

@end
