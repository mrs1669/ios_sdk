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
                               loggerName:(nonnull NSString *)loggerName
                                 idString:(nonnull NSString *)idString
                          runningThreadId:(nullable NSString *)runningThreadId
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJInputLogMessageData *inputData;
@property (nonnull, readonly, strong, nonatomic) NSString *loggerName;
@property (nonnull, readonly, strong, nonatomic) NSString *idString;
@property (nullable, readonly, strong, nonatomic) NSString *runningThreadId;

// public API
- (nonnull NSMutableDictionary <NSString *, id>*)generateFoundationDictionary;

+ (nonnull NSString *)generateJsonStringFromFoundationDictionary:
    (nonnull NSDictionary<NSString *, id> *)foundationDictionary;

@end
