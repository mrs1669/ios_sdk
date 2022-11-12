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

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJLogMessageKey = @"message";
NSString *const ADJLogLevelKey = @"level";
NSString *const ADJLogIssueKey = @"issue";
NSString *const ADJLogErrorKey = @"error";
NSString *const ADJLogExceptionKey = @"exception";
NSString *const ADJLogParamsKey = @"params";
NSString *const ADJLogSourceKey = @"source";
NSString *const ADJLogCallerThreadIdKey = @"callerId";
NSString *const ADJLogRunningThreadIdKey = @"runningId";
NSString *const ADJLogCallerDescriptionKey = @"callerDescription";
NSString *const ADJLogInstanceIdKey = @"instanceId";
NSString *const ADJLogIsPreSdkInitKey = @"isPreSdkInit";

#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJInputLogMessageData *inputData;
 @property (nonnull, readonly, strong, nonatomic) NSString *sourceDescription;
 @property (nullable, readonly, strong, nonatomic) NSString *runningThreadId;
 @property (nullable, readonly, strong, nonatomic) NSString *instanceId;
 */

@implementation ADJLogMessageData
// instantiation
- (nonnull instancetype)
    initWithInputData:(nonnull ADJInputLogMessageData *)inputData
    sourceDescription:(nonnull NSString *)sourceDescription
    runningThreadId:(nullable NSString *)runningThreadId
    instanceId:(nullable NSString *)instanceId
{
    self = [super init];

    _inputData = inputData;
    _sourceDescription = sourceDescription;
    _runningThreadId = runningThreadId;
    _instanceId = instanceId;

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
    
    if (self.inputData.messageParams != nil) {
        [foundationDictionary setObject:self.inputData.messageParams forKey:ADJLogParamsKey];
    }
    
    if (self.instanceId != nil) {
        [foundationDictionary setObject:self.instanceId forKey:ADJLogInstanceIdKey];
    } else {
        [foundationDictionary setObject:[NSNull null] forKey:ADJLogInstanceIdKey];
    }
    
    return foundationDictionary;
}

+ (nonnull NSDictionary<NSString *, id> *)
    generateFoundationDictionaryFromNsError:(nonnull NSError *)nsError
{
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

+ (nonnull NSDictionary<NSString *, id> *)
    generateFoundationDictionaryFromNsException:(nonnull NSException *)nsException
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


+ (nonnull NSString *)generateJsonFromFoundationDictionary:
    (nonnull NSDictionary<NSString *, id> *)foundationDictionary
{
    NSError *error;

    NSData *_Nullable jsonData =
        [ADJUtilConv convertToJsonDataWithJsonFoundationValue:foundationDictionary
                                                     errorPtr:&error];

    if (error != nil) {
        return [NSString stringWithFormat:
                @"{\"errorJsonConv\": \"%@\", \"originalDictionary\": \"%@\"}",
                error, foundationDictionary];
    }

    if (jsonData == nil) {
        return [NSString stringWithFormat:
                @"{\"nullJsonData\": true, \"originalDictionary\": \"%@\"}",
                foundationDictionary];
    }

    NSString *_Nullable jsonString = [ADJUtilF jsonDataFormat:jsonData];

    if (jsonString == nil) {
        return [NSString stringWithFormat:
                @"{\"nullJsonString\": true, \"originalDictionary\": \"%@\"}",
                foundationDictionary];
    }

    return jsonString;
}

@end
