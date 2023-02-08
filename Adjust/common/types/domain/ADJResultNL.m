//
//  ADJResultNL.m
//  Adjust
//
//  Created by Pedro Silva on 07.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJResultNL.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) S value;
 @property (nullable, readonly, strong, nonatomic) NSString *failMessage;
 */

@implementation ADJResultNL
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (nonnull ADJResultNL *)okWithValue:(nullable id)value {
    return [[ADJResultNL alloc] initWithValue:value failMessage:nil];
}
+ (nonnull ADJResultNL *)failWithMessage:(nonnull NSString *)failMessage {
    return [[ADJResultNL alloc] initWithValue:nil failMessage:failMessage];
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
- (void)okBlock:(void (^ _Nonnull NS_NOESCAPE)(id _Nullable value))okBlock
      failBlock:(void (^ _Nonnull NS_NOESCAPE)(NSString *_Nonnull failMessage))failBlock
{
    if (self.failMessage == nil) {
        okBlock(self.value);
    } else {
        failBlock(self.failMessage);
    }
}

@end
