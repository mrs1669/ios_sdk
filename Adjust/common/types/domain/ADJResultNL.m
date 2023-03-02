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
 @property (nullable, readonly, strong, nonatomic) NSString *failMessage;
 */

@interface ADJResultNL ()

@property (readonly, assign, nonatomic) BOOL hasFailed;

@end

@implementation ADJResultNL
#pragma mark - Synthesize protocol properties
@synthesize message = _message;
@synthesize params = _params;
@synthesize error = _error;
@synthesize exception = _exception;

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
        nlInstance = [[ADJResultNL alloc] initWithValue:nil];
    });
    return nlInstance;
}

+ (nonnull ADJResultNL *)failWithMessage:(nonnull NSString *)failMessage {
    return [[ADJResultNL alloc] initWithFailMessage:failMessage
                                         failParams:nil
                                          failError:nil
                                      failException:nil];
}
+ (nonnull ADJResultNL *)failWithMessage:(nonnull NSString *)failMessage
                                     key:(nonnull NSString *)key
                                   value:(nullable id)value
{
    return [[ADJResultNL alloc]
            initWithFailMessage:failMessage
            failParams:
                [[NSDictionary alloc] initWithObjectsAndKeys:
                 [ADJUtilF idOrNsNull:value], key, nil]
            failError:nil
            failException:nil];
}
+ (nonnull ADJResultNL *)failWithException:(nonnull NSException *)exception {
    return [[ADJResultNL alloc] initWithFailMessage:nil
                                         failParams:nil
                                          failError:nil
                                      failException:exception];
}
+ (nonnull ADJResultNL *)failWithError:(nonnull NSError *)error {
    return [[ADJResultNL alloc] initWithFailMessage:nil
                                         failParams:nil
                                          failError:error
                                      failException:nil];
}
+ (nonnull ADJResultNL *)failWithError:(nonnull NSError *)error
                               message:(nullable NSString *)failMessage
{
    return [[ADJResultNL alloc] initWithFailMessage:failMessage
                                         failParams:nil
                                          failError:error
                                      failException:nil];
}

+ (nonnull ADJResultNL *)
    failWithMessage:(nullable NSString *)failMessage
    failParams:(nullable NSDictionary<NSString *, id> *)failParams
    failError:(nullable NSError *)failError
    failException:(nullable NSException *)failException
{
    return [[ADJResultNL alloc] initWithFailMessage:failMessage
                                         failParams:failParams
                                          failError:failError
                                      failException:failException];
}

+ (nonnull id<ADJResultFail>)resultFailWithError:(nonnull NSError *)error
                                         message:(nullable NSString *)failMessage
{
    return [[ADJResultNL alloc] initWithFailMessage:failMessage
                                         failParams:nil
                                          failError:error
                                      failException:nil];
}

+ (nonnull ADJResultNL *)failWitAnotherFail:(nonnull id<ADJResultFail>)anotherFail {
    return [[ADJResultNL alloc] initWithFailMessage:anotherFail.message
                                         failParams:anotherFail.params
                                          failError:anotherFail.error
                                      failException:anotherFail.exception];
}

+ (nonnull ADJResultNL *)instanceFromNN:
    (ADJResultNN<id> *_Nonnull (^ _Nonnull NS_NOESCAPE)(id _Nullable value))nnBlock
                                nlValue:(nullable id)nlValue
{
    if (nlValue == nil) {
        return [ADJResultNL okWithoutValue];
    }

    ADJResultNN<id> *_Nonnull resultNN = nnBlock(nlValue);

    if (resultNN.fail != nil) {
        return [[ADJResultNL alloc] initWithFailMessage:resultNN.fail.message
                                             failParams:resultNN.fail.params
                                              failError:resultNN.fail.error
                                          failException:resultNN.fail.exception];
    }

    return [ADJResultNL okWithValue:resultNN.value];
}

- (nullable id<ADJResultFail>)fail {
    return self.hasFailed ? self : nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithValue:(nullable id)value {
    return [self initWithHasFailed:NO
                             value:value
                       failMessage:nil
                        failParams:nil
                         failError:nil
                     failException:nil];
}

- (nonnull instancetype)
    initWithFailMessage:(nullable NSString *)failMessage
    failParams:(nullable NSDictionary<NSString *, id> *)failParams
    failError:(nullable NSError *)failError
    failException:(nullable NSException *)failException
{
    return [self initWithHasFailed:YES
                             value:nil
                       failMessage:failMessage
                        failParams:failParams
                         failError:failError
                     failException:failException];
}

- (nonnull instancetype)
    initWithHasFailed:(BOOL)hasFailed
    value:(nullable id)value
    failMessage:(nullable NSString *)failMessage
    failParams:(nullable NSDictionary<NSString *, id> *)failParams
    failError:(nullable NSError *)failError
    failException:(nullable NSException *)failException

{
    self = [super init];
    _hasFailed = hasFailed;
    _value = value;
    _message = failMessage;
    _params = failParams;
    _error = failError;
    _exception = failException;

    return self;
}

#pragma mark Public API
- (nonnull NSDictionary<NSString *, id> *)foundationDictionary {
    return [ADJResultNN generateFoundationDictionaryFromResultFail:self];
}

/*
- (void)okBlock:(void (^ _Nonnull NS_NOESCAPE)(id _Nullable value))okBlock
      failBlock:(void (^ _Nonnull NS_NOESCAPE)(NSString *_Nonnull failMessage))failBlock
{
    if (self.failMessage == nil) {
        okBlock(self.value);
    } else {
        failBlock(self.failMessage);
    }
}
*/
@end
