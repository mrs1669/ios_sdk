//
//  ADJResultNN.m
//  Adjust
//
//  Created by Pedro Silva on 07.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJResultNN.h"

#import "ADJUtilF.h"
#import "ADJConstants.h"
#import "ADJUtilConv.h"

//#import "ADJResultFail.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) S value;
 @property (nullable, readonly, strong, nonatomic) ADJResultFail *fail;
*/

@implementation ADJResultNN
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (nonnull ADJResultNN *)okWithValue:(nonnull id)value {
    return [[ADJResultNN alloc] initWithValue:value];
}

+ (nonnull ADJResultNN *)failWithMessage:(nonnull NSString *)failMessage {
    return [[ADJResultNN alloc] initWithFail:
                [[ADJResultFail alloc] initWithMessage:failMessage
                                                params:nil
                                                 error:nil
                                             exception:nil]];
}
+ (nonnull ADJResultNN *)failWithMessage:(nonnull NSString *)failMessage
                                     key:(nonnull NSString *)key
                                   value:(nullable id)value
{
    return [[ADJResultNN alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage
                                            params:
             [[NSDictionary alloc] initWithObjectsAndKeys:
              [ADJUtilF idOrNsNull:value], key, nil]
                                             error:nil
                                         exception:nil]];
}
+ (nonnull ADJResultNN *)failWithMessage:(nonnull NSString *)failMessage
                                   error:(nullable NSError *)error
{
    return [[ADJResultNN alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage
                                            params:nil
                                             error:error
                                         exception:nil]];
}
+ (nonnull ADJResultNN *)failWithMessage:(nonnull NSString *)failMessage
                               exception:(nullable NSException *)exception
{
    return [[ADJResultNN alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage
                                            params:nil
                                             error:nil
                                         exception:exception]];
}
+ (nonnull ADJResultNN *)
    failWithMessage:(nonnull NSString *)failMessage
    builderBlock:(void (^ _Nonnull NS_NOESCAPE)(ADJResultFailBuilder *_Nonnull resultFailBuilder))
        builderBlock
{
    ADJResultFailBuilder *_Nonnull resultFailBuilder =
        [[ADJResultFailBuilder alloc] initWithMessage:failMessage];

    builderBlock(resultFailBuilder);

    return [[ADJResultNN alloc] initWithFail:[resultFailBuilder build]];
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithValue:(nonnull id)value {
    return [self initWithValue:value fail:nil];
}

- (nonnull instancetype)initWithFail:(nonnull ADJResultFail *)fail {
    return [self initWithValue:nil fail:fail];
}

- (nonnull instancetype)
    initWithValue:(nullable id)value
    fail:(nullable ADJResultFail *)fail
{
    self = [super init];
    _value = value;
    _fail = fail;

    return self;
}

@end
