//
//  ADJResultErr.m
//  Adjust
//
//  Created by Pedro Silva on 14.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJResultErr.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) S value;
 @property (nullable, readonly, strong, nonatomic) NSError *error;
 */

@implementation ADJResultErr
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (nonnull ADJResultErr *)okWithValue:(nonnull id)value {
    return [[ADJResultErr alloc] initWithValue:value error:nil];
}
+ (nonnull ADJResultErr *)okWithoutValue {
    static dispatch_once_t errInstanceToken;
    static ADJResultErr* errInstance;
    dispatch_once(&errInstanceToken, ^{
        errInstance = [[ADJResultErr alloc] initWithValue:nil error:nil];
    });
    return errInstance;
}
+ (nonnull ADJResultErr *)failWithError:(nonnull NSError *)error {
    return [[ADJResultErr alloc] initWithValue:nil error:error];
}
#pragma mark - Private constructors
- (nonnull instancetype)initWithValue:(nullable id)value
                                error:(nullable NSError *)error
{
    self = [super init];
    _value = value;
    _error = error;

    return self;
}

@end
