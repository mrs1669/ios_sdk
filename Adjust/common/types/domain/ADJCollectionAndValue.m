//
//  ADJCollectionAndValue.m
//  Adjust
//
//  Created by Pedro Silva on 03.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJCollectionAndValue.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSArray<C> *collection;
 @property (nonnull, readonly, strong, nonatomic) V value;
 */

@implementation ADJCollectionAndValue
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (nonnull instancetype)initWithValue:(nonnull id)value {
    return [self initWithCollection:nil value:value];
}

- (nonnull instancetype)initWithCollection:(nullable NSArray<id> *)collection
                                     value:(nonnull id)value
{

    self = [super init];
    static dispatch_once_t emptyArrayToken;
    static NSArray<id> *emptyArray;
    dispatch_once(&emptyArrayToken, ^{
        emptyArray = [NSArray array];
    });

    _collection = collection ?: emptyArray;
    _value = value;

    return self;
}

@end
