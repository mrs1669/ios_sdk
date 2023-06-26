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
#import "ADJUtilJson.h"
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

- (nullable NSString *)runningThreadIdCoalesce {
    return self.inputData.runningThreadId ?: self.runningThreadId;
}

// TODO: not used anywhere at the moment, but will be needed when sending/storing
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

    NSString *_Nullable runningThreadId = [self runningThreadIdCoalesce];
    if (runningThreadId != nil) {
        [foundationDictionary setObject:runningThreadId
                                 forKey:ADJLogRunningThreadIdKey];
    }

    if (self.inputData.issueType != nil) {
        [foundationDictionary setObject:self.inputData.issueType
                                 forKey:ADJLogIssueKey];
    }

    if (self.inputData.resultFail != nil) {
        [foundationDictionary setObject:[self.inputData.resultFail toJsonDictionary]
                                 forKey:ADJLogFailKey];
    }

    if (self.inputData.messageParams != nil) {
        [foundationDictionary
         setObject:[ADJUtilJson toJsonDictionary:self.inputData.messageParams].value
         forKey:ADJLogParamsKey];
    }

    if (self.inputData.sdkPackageParams != nil) {
        [foundationDictionary setObject:self.inputData.sdkPackageParams
                                 forKey:ADJLogSdkPackageParamsKey];
    }

    return foundationDictionary;
}

@end
