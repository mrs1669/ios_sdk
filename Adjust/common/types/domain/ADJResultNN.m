//
//  ADJResultNN.m
//  Adjust
//
//  Created by Pedro Silva on 07.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJResultNN.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) S value;
 @property (nullable, readonly, strong, nonatomic) NSString *failMessage;
 */

@implementation ADJResultNN
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (nonnull ADJResultNN *)okWithValue:(nonnull id)value {
    return [[ADJResultNN alloc] initWithValue:value failMessage:nil];
}
+ (nonnull ADJResultNN *)failWithMessage:(nonnull NSString *)failMessage {
    return [[ADJResultNN alloc] initWithValue:nil failMessage:failMessage];
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithValue:(nullable id)value
                          failMessage:(nullable NSString *)failMessage
{
    self = [super init];
    _value = value;
    _failMessage = failMessage;

    return self;
}

#pragma mark Public API
- (void)okBlock:(void (^ _Nonnull NS_NOESCAPE)(id _Nonnull value))okBlock
      failBlock:(void (^ _Nonnull NS_NOESCAPE)(NSString *_Nonnull failMessage))failBlock
{
    if (self.failMessage == nil) {
        okBlock(self.value);
    } else {
        failBlock(self.failMessage);
    }
}

@end
