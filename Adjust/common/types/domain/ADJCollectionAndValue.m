//
//  ADJCollectionAndValue.m
//  Adjust
//
//  Created by Pedro Silva on 03.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJCollectionAndValue.h"

@implementation ADJCollectionAndValue
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (nonnull instancetype)initWithCollection:(nonnull NSArray<id> *)collection
                                     value:(nonnull id)value
{
    self = [super init];
    _collection = collection;
    _value = value;

    return self;
}

@end
