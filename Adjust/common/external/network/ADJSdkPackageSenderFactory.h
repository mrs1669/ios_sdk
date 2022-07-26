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
#import "ADJThreadPool.h"

@protocol ADJSdkPackageSenderFactory <NSObject>

- (nonnull ADJSdkPackageSender *) createSdkPacakgeSenderWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                                        sourceDescription:(nonnull NSString *)sourceDescription
                                                               threadpool:(nonnull id<ADJThreadPool>)threadpool;

@end
