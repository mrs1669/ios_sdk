//
//  ADJLogMessageData.m
//  Adjust
//
//  Created by Pedro Silva on 27.10.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLogMessageData.h"

#import "ADJUtilConv.h"
#import "ADJUtilF.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

//#import "ADJResultFail.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJInputLogMessageData *inputData;
 @property (nonnull, readonly, strong, nonatomic) NSString *loggerName;
 @property (nonnull, readonly, strong, nonatomic) NSString *idString;
 @property (nullable, readonly, strong, nonatomic) NSString *runningThreadId;
 */

@implementation ADJLogMessageData
// instantiation
- (nonnull instancetype)initWithInputData:(nonnull ADJInputLogMessageData *)inputData
                               loggerName:(nonnull NSString *)loggerName
                                 idString:(nonnull NSString *)idString
                          runningThreadId:(nullable NSString *)runningThreadId
{
    self = [super init];

    _inputData = inputData;
    _loggerName = loggerName;
    _idString = idString;
    _runningThreadId = runningThreadId;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (nonnull NSMutableDictionary <NSString *, id>*)generateFoundationDictionary {
    NSMutableDictionary *_Nonnull foundationDictionary =
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:
         self.inputData.message, ADJLogMessageKey,
         self.inputData.level, ADJLogLevelKey,
         self.loggerName, ADJLogLoggerNameKey,
         self.idString, ADJLogInstanceIdKey,
         nil];

    if (self.inputData.callerThreadId != nil) {
        [foundationDictionary setObject:self.inputData.callerThreadId
                                 forKey:ADJLogCallerThreadIdKey];
    }

    if (self.inputData.fromCaller != nil) {
        [foundationDictionary setObject:self.inputData.fromCaller
                                 forKey:ADJLogFromCallerKey];
    }

    if (self.inputData.runningThreadId != nil) {
        [foundationDictionary setObject:self.inputData.runningThreadId
                                 forKey:ADJLogRunningThreadIdKey];
    } else if (self.runningThreadId != nil) {
        [foundationDictionary setObject:self.runningThreadId forKey:ADJLogRunningThreadIdKey];
    }

    if (self.inputData.issueType != nil) {
        [foundationDictionary setObject:self.inputData.issueType
                                 forKey:ADJLogIssueKey];
    }

    if (self.inputData.resultFail != nil) {
        [foundationDictionary setObject:[self.inputData.resultFail foundationDictionary]
                                 forKey:ADJLogFailKey];
    }

    if (self.inputData.messageParams != nil) {
        [foundationDictionary setObject:[ADJUtilConv convertToFoundationObject:
                                         self.inputData.messageParams]
                                 forKey:ADJLogParamsKey];
    }

    if (self.inputData.sdkPackageParams != nil) {
        [foundationDictionary setObject:[ADJUtilConv convertToFoundationObject:
                                         self.inputData.sdkPackageParams]
                                 forKey:ADJLogSdkPackageParamsKey];
    }

    return foundationDictionary;
}
/*
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

+ (nonnull NSDictionary<NSString *, id> *)generateFoundationDictionaryFromNsError:(nonnull NSError *)nsError {
    NSMutableDictionary *_Nonnull errorFoundationDictionary =
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:
         nsError.domain, @"domain",
         @(nsError.code), @"code",  nil];

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
*/
+ (nonnull NSString *)generateJsonStringFromFoundationDictionary:
    (nonnull NSDictionary<NSString *, id> *)foundationDictionary
{
    ADJResult<NSData *> *_Nonnull jsonDataResult =
        [ADJUtilConv convertToJsonDataWithJsonFoundationValue:foundationDictionary];
    if (jsonDataResult.fail != nil) {
        return [NSString stringWithFormat:
                @"{ \"message\": \"Error converting dictionary to json data\", "
                "\"fail\": \"%@\", "
                "\"original_dictionary\": \"%@\" }",
                [ADJUtilObj formatInlineKeyValuesWithName:@""
                                      stringKeyDictionary:
                 [jsonDataResult.fail foundationDictionary]],
                [ADJUtilObj formatInlineKeyValuesWithName:@""
                                      stringKeyDictionary:foundationDictionary]];
    }

    ADJResult<NSString *> *_Nonnull jsonStringResult =
        [ADJUtilF jsonDataFormat:jsonDataResult.value];
    if (jsonStringResult.fail != nil) {
        return [NSString stringWithFormat:
                @"{ \"message\": \"Error converting json data to string\", "
                "\"fail\": \"%@\", "
                "\"original_dictionary\": \"%@\" }",
                [ADJUtilObj formatInlineKeyValuesWithName:@""
                                      stringKeyDictionary:
                 [jsonStringResult.fail foundationDictionary]],
                [ADJUtilObj formatInlineKeyValuesWithName:@""
                                      stringKeyDictionary:foundationDictionary]];
    }

    return jsonStringResult.value;
}

@end
