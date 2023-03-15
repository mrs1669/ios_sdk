//
//  ADJOptionalFailsNN.m
//  Adjust
//
//  Created by Pedro Silva on 14.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJOptionalFailsNN.h"

#pragma mark Fields
#pragma mark - Public properties
/*
 @property (nonnull, readonly, strong, nonatomic) NSArray<ADJResultFail *> *optionalFails;
 @property (nonnull, readonly, strong, nonatomic) V value;
 */

@implementation ADJOptionalFailsNN
#pragma mark Instantiation
- (nonnull instancetype)initWithOptionalFails:(nullable NSArray<ADJResultFail *> *)optionalFails
                                        value:(nonnull id)value
{
    self = [super init];
    static dispatch_once_t emptyArrayToken;
    static NSArray<ADJResultFail *> *emptyArray;
    dispatch_once(&emptyArrayToken, ^{
        emptyArray = [NSArray array];
    });

    _optionalFails = optionalFails ?: emptyArray;
    _value = value;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
