//
//  ADJThreadExecutorFactory.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSingleThreadExecutor.h"
#import "ADJLoggerFactory.h"

@protocol ADJThreadExecutorFactory <NSObject>

- (nonnull ADJSingleThreadExecutor *)createSingleThreadExecutorWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    sourceDescription:(nonnull NSString *)sourceDescription;

@end
