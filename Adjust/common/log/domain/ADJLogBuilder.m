//
//  ADJLogBuilder.m
//  Adjust
//
//  Created by Pedro Silva on 28.10.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLogBuilder.h"
#import "ADJInputLogMessageData.h"

#pragma mark - Public properties
/* .h
 @property(nonnull, nonatomic, copy, readonly)
     ADJLogBuilder *_Nonnull (^wIssue)(ADJIssue _Nonnull issueType);
 @property(nonnull, nonatomic, copy, readonly)
     ADJLogBuilder *_Nonnull (^wKv)
         (NSString *_Nonnull key, NSString * _Nullable value);
 @property(nonnull, nonatomic, copy, readonly)
     ADJLogBuilder *_Nonnull (^wError)(NSString * _Nonnull nsError);
 @property(nonnull, nonatomic, copy, readonly)
     ADJLogBuilder *_Nonnull (^wException)(NSException * _Nonnull nsException);

 @property(nonnull, nonatomic, copy, readonly)
     ADJLogBuilder *_Nonnull (^log)(void);
 */

@interface ADJLogBuilder ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic)id <ADJLogBuildCallback> logBuildCallback;
@property (nonnull, readonly, strong, nonatomic) NSString *logLevel;
@property (nonnull, readonly, strong, nonatomic) NSString *message;

#pragma mark - Internal variables
@property (nullable, readwrite, strong, nonatomic)
    NSMutableDictionary <NSString *, NSString *> *params;
@property (nullable, readwrite, strong, nonatomic) ADJIssue issueType;
@property (nullable, readwrite, strong, nonatomic) NSError *nsError;
@property (nullable, readwrite, strong, nonatomic) NSException *nsException;
//@property (readwrite, assign, nonatomic) BOOL hasLogged;

@end

@implementation ADJLogBuilder
#pragma mark Instantiation
- (nonnull instancetype)initWithLevel:(nonnull NSString *)logLevel
                              message:(nonnull NSString *)message
                     logBuildCallback:(nonnull id<ADJLogBuildCallback>)logBuildCallback
{
    self = [super init];
    
    _logLevel = logLevel;
    _message = message;
    _logBuildCallback = logBuildCallback;
    
    _params = nil;
    _issueType = nil;
    _nsError = nil;
    _nsException = nil;
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (ADJLogBuilder * (^)(ADJIssue _Nonnull))wIssue
{
    return ^(ADJIssue _Nonnull issueType) {
        self.issueType = issueType;
        return self;
    };
}

- (ADJLogBuilder * (^)(NSString * _Nonnull, NSString * _Nullable))wKv
{
    return ^(NSString *_Nonnull key, NSString * _Nullable value) {
        if (self.params == nil) {
            self.params = [[NSMutableDictionary alloc] init];
        }
        [self.params setObject:value forKey:key];
        return self;
    };
}

- (ADJLogBuilder * (^)(NSError * _Nonnull))wError
{
    return ^(NSError * _Nonnull nsError) {
        self.nsError = nsError;
        return self;
    };
}
- (ADJLogBuilder * (^)(NSException * _Nonnull))wException
{
    return ^(NSException * _Nonnull nsException) {
        self.nsException = nsException;
        return self;
    };
}

- (ADJLogBuilder * (^)(void))end
{
    // self.hasLogged = YES;
    return ^(void) {
        [self.logBuildCallback logWithInput:
             [[ADJInputLogMessageData alloc]
              initWithMessage:self.message
              level:self.logLevel
              issueType:self.issueType
              nsError:self.nsError
              nsException:self.nsException
              messageParams:self.params]];
        return self;
    };
}
/*
#pragma mark - NSObject
- (void)dealloc {
    if (_hasLogged) {
        return;
    }
    self.end();
}
*/
@end
