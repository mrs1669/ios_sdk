//
//  ADJSdkPackageSenderFactory.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkPackageSender.h"
#import "ADJLoggerFactory.h"
#import "ADJThreadExecutorFactory.h"

@protocol ADJSdkPackageSenderFactory <NSObject>

- (nonnull ADJSdkPackageSender *)
    createSdkPackageSenderWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    sourceLoggerName:(nonnull NSString *)sourceLoggerName
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory;

@end
