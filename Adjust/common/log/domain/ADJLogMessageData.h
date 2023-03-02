//
//  ADJLogMessageData.h
//  Adjust
//
//  Created by Pedro Silva on 27.10.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJInputLogMessageData.h"

@interface ADJLogMessageData : NSObject
// instantiation
- (nonnull instancetype)initWithInputData:(nonnull ADJInputLogMessageData *)inputData
    sourceDescription:(nonnull NSString *)sourceDescription
    runningThreadId:(nullable NSString *)runningThreadId
    idString:(nullable NSString *)idString

NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJInputLogMessageData *inputData;
@property (nonnull, readonly, strong, nonatomic) NSString *sourceDescription;
@property (nullable, readonly, strong, nonatomic) NSString *runningThreadId;
@property (nullable, readonly, strong, nonatomic) NSString *idString;

// public API
- (nonnull NSMutableDictionary <NSString *, id>*)generateFoundationDictionary;

//+ (nonnull NSDictionary<NSString *, id> *)generateFoundationDictionaryFromResultFail:
//    (nonnull id<ADJResultFail>)resultFail;
//+ (nonnull NSDictionary<NSString *, id> *)generateFoundationDictionaryFromNsError:(nonnull NSError *)nsError;
//+ (nonnull NSDictionary<NSString *, id> *)generateFoundationDictionaryFromNsException:(nonnull NSException *)nsException;

+ (nonnull NSString *)generateJsonStringFromFoundationDictionary:
    (nonnull NSDictionary<NSString *, id> *)foundationDictionary;

@end
