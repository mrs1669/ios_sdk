//
//  ADJResultNL.m
//  Adjust
//
//  Created by Pedro Silva on 07.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJResultNL.h"

#import "ADJUtilF.h"

#import "ADJResultNN.h"
//#import "ADJResultFail.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) S value;
 @property (nullable, readonly, strong, nonatomic) ADJResultFail *fail;
 */

@implementation ADJResultNL
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (nonnull ADJResultNL *)okWithValue:(nonnull id)value {
    return [[ADJResultNL alloc] initWithValue:value];
}
+ (nonnull ADJResultNL *)okWithoutValue {
    static dispatch_once_t nlInstanceToken;
    static ADJResultNL* nlInstance;
    dispatch_once(&nlInstanceToken, ^{
        nlInstance = [[ADJResultNL alloc] initWithValue:nil fail:nil];
    });
    return nlInstance;
}

+ (nonnull ADJResultNL *)failWithMessage:(nonnull NSString *)failMessage {
    return [[ADJResultNL alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage]];
}
+ (nonnull ADJResultNL *)failWithMessage:(nonnull NSString *)failMessage
                                     key:(nonnull NSString *)key
                             stringValue:(nonnull NSString *)stringValue
{
    return [[ADJResultNL alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage
                                               key:key
                                       stringValue:stringValue]];
}
+ (nonnull ADJResultNL *)failWithMessage:(nonnull NSString *)failMessage
                                        key:(nonnull NSString *)key
                                  otherFail:(nonnull ADJResultFail *)otherFail
{
    return [[ADJResultNL alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage
                                               key:key
                                         otherFail:otherFail]];
}
+ (nonnull ADJResultNL *)failWithMessage:(nonnull NSString *)failMessage
                                   error:(nullable NSError *)error
{
    return [[ADJResultNL alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage
                                             error:error]];
}
+ (nonnull ADJResultNL *)failWithMessage:(nonnull NSString *)failMessage
                               exception:(nullable NSException *)exception
{
    return [[ADJResultNL alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage
                                         exception:exception]];
}

+ (nonnull ADJResultNL *)
    failWithMessage:(nonnull NSString *)failMessage
    builderBlock:(void (^ _Nonnull NS_NOESCAPE)(ADJResultFailBuilder *_Nonnull resultFailBuilder))
        builderBlock
{
    ADJResultFailBuilder *_Nonnull resultFailBuilder =
        [[ADJResultFailBuilder alloc] initWithMessage:failMessage];

    builderBlock(resultFailBuilder);

    return [[ADJResultNL alloc] initWithFail:[resultFailBuilder build]];
}

+ (nonnull ADJResultNL *)
    instanceFromNN:
        (ADJResultNN<id> *_Nonnull (^ _Nonnull NS_NOESCAPE)(id _Nullable value))nnBlock
    nlValue:(nullable id)nlValue
{
    if (nlValue == nil) {
        return [ADJResultNL okWithoutValue];
    }

    ADJResultNN<id> *_Nonnull resultNN = nnBlock(nlValue);

    if (resultNN.fail != nil) {
        return [[ADJResultNL alloc] initWithFail:resultNN.fail];
    }

    return [ADJResultNL okWithValue:resultNN.value];
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
