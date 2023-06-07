//
//  ADJConsoleLogger.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJNonEmptyString.h"
#import "ADJSdkConfigData.h"
#import "ADJLogMessageData.h"
#import "ADJInputLogMessageData.h"

//#import <os/log.h>

@interface ADJConsoleLogger : NSObject
// instantiation
- (nonnull instancetype)initWithSdkConfigData:(nonnull ADJSdkConfigData *)sdkConfigData
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)didLogMessage:(nonnull ADJLogMessageData *)logMessageData;

- (void)didSdkInitWithIsSandboxEnvironment:(BOOL)isSandboxEnvironment
                                  doLogAll:(BOOL)doLogAll
                               doNotLogAny:(BOOL)doNotLogAny;

+ (nonnull NSString *)clientCallbackFormatMessageWithLog:
    (nonnull ADJInputLogMessageData *)inputLogMessageData;

@end
