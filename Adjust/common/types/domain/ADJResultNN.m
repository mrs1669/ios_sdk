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
 @property (nullable, readonly, strong, nonatomic) NSString *failMessage;
 */

@interface ADJResultNN ()

@property (readonly, assign, nonatomic) BOOL hasFailed;

@end

@implementation ADJResultNN
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

+ (nonnull ADJResultNN *)okWithValue:(nonnull id)value {
    return [[ADJResultNN alloc] initWithValue:value];
}

+ (nonnull ADJResultNN *)failWithMessage:(nonnull NSString *)failMessage {
    return [[ADJResultNN alloc] initWithFailMessage:failMessage
                                         failParams:nil
                                          failError:nil
                                      failException:nil];
}
+ (nonnull ADJResultNN *)failWithMessage:(nonnull NSString *)failMessage
                                     key:(nonnull NSString *)key
                                   value:(nullable id)value
{
    return [[ADJResultNN alloc]
            initWithFailMessage:failMessage
            failParams:
                [[NSDictionary alloc] initWithObjectsAndKeys:
                 [ADJUtilF idOrNsNull:value], key, nil]
            failError:nil
            failException:nil];
}
+ (nonnull ADJResultNN *)failWithException:(nonnull NSException *)exception {
    return [[ADJResultNN alloc] initWithFailMessage:nil
                                         failParams:nil
                                          failError:nil
                                      failException:exception];

}
+ (nonnull ADJResultNN *)failWithError:(nonnull NSError *)error
                               message:(nullable NSString *)failMessage
{
    return [[ADJResultNN alloc] initWithFailMessage:failMessage
                                         failParams:nil
                                          failError:error
                                      failException:nil];
}

+ (nonnull ADJResultNN *)
    failWithMessage:(nullable NSString *)failMessage
    failParams:(nullable NSDictionary<NSString *, id> *)failParams
    failError:(nullable NSError *)failError
    failException:(nullable NSException *)failException
{
    return [[ADJResultNN alloc] initWithFailMessage:failMessage
                                         failParams:failParams
                                          failError:failError
                                      failException:failException];
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

+ (nonnull NSDictionary<NSString *, id> *)generateFoundationDictionaryFromResultFail:
    (nonnull id<ADJResultFail>)resultFail
{
    NSMutableDictionary *_Nonnull resultFailDictionary =
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:
         resultFail.message, ADJLogMessageKey,  nil];

    if (resultFail.error != nil) {
        [resultFailDictionary setObject:
         [self generateFoundationDictionaryFromNsError:resultFail.error]
                                 forKey:ADJLogErrorKey];
    }
    if (resultFail.exception != nil) {
        [resultFailDictionary setObject:
         [self generateFoundationDictionaryFromNsException:resultFail.exception]
                                 forKey:ADJLogExceptionKey];
    }
    if (resultFail.params != nil) {
        [resultFailDictionary setObject:resultFail.params
                                 forKey:ADJLogParamsKey];
    }

    return resultFailDictionary;
}

#pragma mark Internal Methods
+ (nonnull NSDictionary<NSString *, id> *)generateFoundationDictionaryFromNsError:(nonnull NSError *)nsError {
    NSMutableDictionary *_Nonnull errorFoundationDictionary =
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:
         nsError.domain, @"domain",
         [ADJUtilF integerFormat:nsError.code], @"code",  nil];

    if (nsError.userInfo != nil) {
        [errorFoundationDictionary
         setObject:[ADJUtilConv convertToFoundationObject:nsError.userInfo]
         forKey:@"userInfo"];
    }

    return errorFoundationDictionary;
}

+ (nonnull NSDictionary<NSString *, id> *)generateFoundationDictionaryFromNsException:
    (nonnull NSException *)nsException
{
    NSMutableDictionary *_Nonnull exceptionFoundationDictionary =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     nsException.name, @"name", nil];

    if (nsException.reason != nil) {
        [exceptionFoundationDictionary setObject:nsException.reason
                                          forKey:@"reason"];
    }

    if (nsException.userInfo != nil) {
        [exceptionFoundationDictionary
         setObject:[ADJUtilConv convertToFoundationObject:nsException.userInfo]
         forKey:@"userInfo"];
    }

    return exceptionFoundationDictionary;
}
@end
