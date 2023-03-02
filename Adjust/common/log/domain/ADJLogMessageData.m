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
 @property (nonnull, readonly, strong, nonatomic) NSString *sourceDescription;
 @property (nullable, readonly, strong, nonatomic) NSString *runningThreadId;
 @property (nullable, readonly, strong, nonatomic) NSString *idString;
 */

@implementation ADJLogMessageData
// instantiation
- (nonnull instancetype)initWithInputData:(nonnull ADJInputLogMessageData *)inputData
                        sourceDescription:(nonnull NSString *)sourceDescription
                          runningThreadId:(nullable NSString *)runningThreadId
                                 idString:(nullable NSString *)idString
{
    self = [super init];

    _inputData = inputData;
    _sourceDescription = sourceDescription;
    _runningThreadId = runningThreadId;
    _idString = idString;

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
         self.sourceDescription, ADJLogSourceKey, nil];

    if (self.inputData.callerThreadId != nil) {
        [foundationDictionary setObject:self.inputData.callerThreadId
                                 forKey:ADJLogCallerThreadIdKey];
    }

    if (self.inputData.callerDescription != nil) {
        [foundationDictionary setObject:self.inputData.callerDescription
                                 forKey:ADJLogCallerDescriptionKey];
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
    /*
    if (self.inputData.nsError != nil) {
        NSDictionary<NSString *, id> *_Nonnull errorFoundationDictionary =
        [ADJLogMessageData generateFoundationDictionaryFromNsError:self.inputData.nsError];

        [foundationDictionary setObject:errorFoundationDictionary forKey:ADJLogErrorKey];
    }

    if (self.inputData.nsException != nil) {
        NSDictionary<NSString *, id> *_Nonnull exceptionFoundationDictionary =
        [ADJLogMessageData generateFoundationDictionaryFromNsException:
         self.inputData.nsException];

        [foundationDictionary setObject:exceptionFoundationDictionary forKey:ADJLogExceptionKey];
    }

    */
    if (self.inputData.messageParams != nil) {
        [foundationDictionary setObject:[ADJUtilConv convertToFoundationObject:
                                         self.inputData.messageParams]
                                 forKey:ADJLogParamsKey];
    }

    if (self.idString != nil) {
        [foundationDictionary setObject:self.idString forKey:ADJLogInstanceIdKey];
    } else {
        [foundationDictionary setObject:[NSNull null] forKey:ADJLogInstanceIdKey];
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
    ADJResultNL<NSData *> *_Nonnull jsonDataResult =
        [ADJUtilConv convertToJsonDataWithJsonFoundationValue:foundationDictionary];
    if (jsonDataResult.error != nil) {
        return [NSString stringWithFormat:
                @"{ \"message\": \"Error converting dictionary to json data\", "
                "\"error\": \"%@\", "
                "\"original_dictionary\": \"%@\" }",
        [ADJUtilF errorFormat:jsonDataResult.error],
        [ADJUtilObj formatInlineKeyValuesWithName:@"" stringKeyDictionary:foundationDictionary]];
    }

    if (jsonDataResult.value == nil) {
        return [NSString stringWithFormat:
                @"{ \"message\": \"Nil result converting dictionary to json data\", "
                "\"original_dictionary\": \"%@\" }",
        [ADJUtilObj formatInlineKeyValuesWithName:@"" stringKeyDictionary:foundationDictionary]];
    }

    NSString *_Nullable jsonString = [ADJUtilF jsonDataFormat:jsonDataResult.value];
    if (jsonString == nil) {
        return [NSString stringWithFormat:
                @"{ \"message\": \"Nil result converting json data to string\", "
                "\"original_dictionary\": \"%@\" }",
        [ADJUtilObj formatInlineKeyValuesWithName:@"" stringKeyDictionary:foundationDictionary]];
    }

    return jsonString;
}

@end
