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

/*
 - (void)didLogMessage:(nonnull NSString *)logMessage
 source:(nonnull NSString *)source
 adjustLogLevel:(nonnull NSString *)adjustLogLevel
 osLogLogger:(nonnull os_log_t)osLogLogger
 API_AVAILABLE(macos(10.12), ios(10.0), watchos(3.0), tvos(10.0));
 */

@end
