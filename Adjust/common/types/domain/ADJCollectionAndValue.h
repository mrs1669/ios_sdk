//
//  ADJCollectionAndValue.h
//  Adjust
//
//  Created by Pedro Silva on 03.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJCollectionAndValue<C, V> : NSObject
// public properties
@property (nonnull, readonly, strong, nonatomic) NSArray<C> *collection;
@property (nonnull, readonly, strong, nonatomic) V value;

// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;

- (nonnull instancetype)initWithCollection:(nullable NSArray<C> *)collection
                                     value:(nonnull V)value;

- (nonnull instancetype)initWithValue:(nonnull V)value;

@end
