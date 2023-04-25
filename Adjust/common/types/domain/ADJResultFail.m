//
//  ADJResultFail.m
//  Adjust
//
//  Created by Pedro Silva on 01.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJResultFail.h"

#import "ADJConstants.h"
#import "ADJUtilF.h"
#import "ADJUtilConv.h"

#pragma mark Fields
#pragma mark - Public properties
/*
 @property (nonnull, readonly, strong, nonatomic) NSString *message;
 @property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, id> *params;
 @property (nullable, readonly, strong, nonatomic) NSError *error;
 @property (nullable, readonly, strong, nonatomic) NSException *exception;
 */

@implementation ADJResultFail
#pragma mark Instantiation
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message {
    return [self initWithMessage:message params:nil error:nil exception:nil];
}
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                    key:(nonnull NSString *)key
                            stringValue:(nonnull NSString *)stringValue
{
    return [self initWithMessage:message
                          params:
            [[NSDictionary alloc] initWithObjectsAndKeys:stringValue, key, nil]
                           error:nil
                       exception:nil];
}
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                    key:(nonnull NSString *)key
                              otherFail:(nonnull ADJResultFail *)otherFail
{
    return [self initWithMessage:message
                          params:[[NSDictionary alloc] initWithObjectsAndKeys:
                                  [otherFail toJsonDictionary], key, nil]
                           error:nil
                       exception:nil];
}
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  error:(nullable NSError *)error
{
    return [self initWithMessage:message
                          params:nil
                           error:error
                       exception:nil];
}
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                              exception:(nullable NSException *)exception
{
    return [self initWithMessage:message
                          params:nil
                           error:nil
                       exception:exception];
}

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                 params:(nullable NSDictionary<NSString *, id> *)params
                                  error:(nullable NSError *)error
                              exception:(nullable NSException *)exception
{
    self = [super init];
    _message = message;
    _params = params;
    _error = error;
    _exception = exception;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull NSDictionary<NSString *, id> *)toJsonDictionary {
    NSMutableDictionary *_Nonnull resultFailDictionary =
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.message, ADJLogMessageKey,  nil];

    if (self.error != nil) {
        [resultFailDictionary setObject:
         [ADJResultFail jsonDictionaryFromNsError:self.error]
                                 forKey:ADJLogErrorKey];
    }
    if (self.exception != nil) {
        [resultFailDictionary setObject:
         [ADJResultFail jsonDictionaryFromNsException:self.exception]
                                 forKey:ADJLogExceptionKey];
    }
    if (self.params != nil) {
        [resultFailDictionary setObject:self.params
                                 forKey:ADJLogParamsKey];
    }

    return resultFailDictionary;
}

#pragma mark Internal Methods
+ (nonnull NSDictionary<NSString *, id> *)jsonDictionaryFromNsError:(nonnull NSError *)nsError {
    NSMutableDictionary<NSString *, id> *_Nonnull errorFoundationDictionary =
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:
         nsError.domain, @"domain",
         [ADJUtilF integerFormat:nsError.code], @"code", nil];

    if (nsError.userInfo != nil) {
        [errorFoundationDictionary setObject:[ADJUtilJson toJsonDictionary:nsError.userInfo]
                                      forKey:@"userInfo"];
    }

    return errorFoundationDictionary;
}

+ (nonnull NSDictionary<NSString *, id> *)jsonDictionaryFromNsException:
    (nonnull NSException *)nsException
{
    NSMutableDictionary *_Nonnull exceptionFoundationDictionary =
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:nsException.name, @"name", nil];

    if (nsException.reason != nil) {
        [exceptionFoundationDictionary setObject:nsException.reason forKey:@"reason"];
    }

    if (nsException.userInfo != nil) {
        [exceptionFoundationDictionary setObject:
         [ADJUtilJson toJsonDictionary:nsException.userInfo] forKey:@"userInfo"];
    }

    return exceptionFoundationDictionary;
}

@end

#pragma mark Fields
@interface ADJResultFailBuilder ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) NSString *message;

#pragma mark - Internal variables
@property (nullable, readwrite, strong, nonatomic) NSMutableDictionary<NSString *, id> *paramsMut;
@property (nullable, readwrite, strong, nonatomic) NSError *error;
@property (nullable, readwrite, strong, nonatomic) NSException *exception;
@end

@implementation ADJResultFailBuilder
#pragma mark Instantiation
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message {
    self = [super init];
    _message = message;

    _paramsMut = nil;
    _error = nil;
    _exception = nil;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (void)withError:(nonnull NSError *)error {
    self.error = error;
}
- (void)withException:(nonnull NSException *)exception {
    self.exception = exception;
}
- (void)withKey:(nonnull NSString *)key
      otherFail:(nonnull ADJResultFail *)otherFail
{
    if (self.paramsMut == nil) {
        self.paramsMut = [[NSMutableDictionary alloc] init];
    }

    [self.paramsMut setObject:[otherFail toJsonDictionary]
                       forKey:key];
}
- (void)withKey:(nonnull NSString *)key
    stringValue:(nonnull NSString *)stringValue
{
    if (self.paramsMut == nil) {
        self.paramsMut = [[NSMutableDictionary alloc] init];
    }

    [self.paramsMut setObject:stringValue
                       forKey:key];
}

- (nonnull ADJResultFail *)build {
    return [[ADJResultFail alloc] initWithMessage:self.message
                                           params:self.paramsMut
                                            error:self.error
                                        exception:self.exception];
}

@end
