//
//  ADJAtomicBoolean.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJAtomicBoolean : NSObject
// instantiation
//- (nonnull instancetype)initWithRelaxedValue:(BOOL)value;
//- (nonnull instancetype)initWithSeqCstValue:(BOOL)value;
- (nonnull instancetype)initSeqCstMemoryOrderWithInitialBoolValue:(BOOL)initialBoolValue;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
@property (assign, atomic) BOOL boolValue;

// atomically sets a new value if the current value matches the expected value.
//  Returns YES if successful, NO otherwise
- (BOOL)compareTo:(BOOL)expected andSetDesired:(BOOL)desired;

// atomically changes the value to true and returns the value it held before.
- (BOOL)testAndSetTrue;

@end
