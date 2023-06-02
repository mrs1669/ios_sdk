//
//  ADJResult.m
//  Adjust
//
//  Created by Pedro Silva on 01.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJResult.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) V value;
 @property (readonly, assign, nonatomic) BOOL wasInputNil;
 @property (nullable, readonly, strong, nonatomic) ADJResultFail *fail;
*/

@implementation ADJResult
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (nonnull ADJResult *)okWithValue:(nonnull id)value {
    return [[ADJResult alloc] initWithValue:value];
}

+ (nonnull ADJResult *)nilInputWithMessage:(nonnull NSString *)nilInputMessage {
    return [[ADJResult alloc]
            initWithValue:nil
            wasInputNil:YES
            fail:[[ADJResultFail alloc] initWithMessage:nilInputMessage]];
}

+ (nonnull ADJResult *)failWithMessage:(nonnull NSString *)failMessage {
    return [[ADJResult alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage]];
}
+ (nonnull ADJResult *)failWithMessage:(nonnull NSString *)failMessage
                                   key:(nonnull NSString *)key
                           stringValue:(nonnull NSString *)stringValue
{
    return [[ADJResult alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage
                                               key:key
                                       stringValue:stringValue]];
}

+ (nonnull ADJResult *)failWithMessage:(nonnull NSString *)failMessage
                                   key:(nonnull NSString *)key
                             otherFail:(nonnull ADJResultFail *)otherFail
{
    return [[ADJResult alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage
                                               key:key
                                         otherFail:otherFail]];
}

+ (nonnull ADJResult *)failWithMessage:(nonnull NSString *)failMessage
                                 error:(nullable NSError *)error
{
    return [[ADJResult alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage
                                             error:error]];
}
+ (nonnull ADJResult *)failWithMessage:(nonnull NSString *)failMessage
                             exception:(nullable NSException *)exception
{
    return [[ADJResult alloc] initWithFail:
            [[ADJResultFail alloc] initWithMessage:failMessage
                                         exception:exception]];
}
+ (nonnull ADJResult *)
    failWithMessage:(nonnull NSString *)failMessage
    wasInputNil:(BOOL)wasInputNil
    builderBlock:(void (^ _Nonnull NS_NOESCAPE)(ADJResultFailBuilder *_Nonnull resultFailBuilder))
        builderBlock
{
    ADJResultFailBuilder *_Nonnull resultFailBuilder =
        [[ADJResultFailBuilder alloc] initWithMessage:failMessage];

    builderBlock(resultFailBuilder);

    return [[ADJResult alloc] initWithValue:nil
                                wasInputNil:wasInputNil
                                       fail:[resultFailBuilder build]];
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithValue:(nonnull id)value {
    return [self initWithValue:value wasInputNil:NO fail:nil];
}

- (nonnull instancetype)initWithFail:(nonnull ADJResultFail *)fail {
    return [self initWithValue:nil wasInputNil:NO fail:fail];
}

- (nonnull instancetype)
    initWithValue:(nullable id)value
    wasInputNil:(BOOL)wasInputNil
    fail:(nullable ADJResultFail *)fail
{
    self = [super init];
    _value = value;
    _wasInputNil = wasInputNil;
    _fail = fail;

    return self;
}

@end
