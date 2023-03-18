//
//  ADJOptionalFailsNL.m
//  Adjust
//
//  Created by Pedro Silva on 17.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJOptionalFailsNL.h"

@implementation ADJOptionalFailsNL
#pragma mark Instantiation
- (nonnull instancetype)initWithOptionalFails:(nullable NSArray<ADJResultFail *> *)optionalFails
                                        value:(nullable id)value
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
