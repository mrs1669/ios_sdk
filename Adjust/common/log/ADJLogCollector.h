//
//  ADJLogCollector.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <os/log.h>

@protocol ADJLogCollector <NSObject>

- (void)collectLogMessage:(nonnull NSString *)logMessage
                   source:(nonnull NSString *)source
           messageLogLevel:(nonnull NSString *)messageLogLevel;
/*
- (void)collectLogMessage:(nonnull NSString *)logMessage
                   source:(nonnull NSString *)source
           adjustLogLevel:(nonnull NSString *)adjustLogLevel
              osLogLogger:(nonnull os_log_t)osLogLogger
API_AVAILABLE(macos(10.12), ios(10.0), watchos(3.0), tvos(10.0));
 */
@end
