//
//  ADJAdjustPlugin.h
//  Adjust
//
//  Created by Pedro S. on 15.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADJAdjustPublishers;
@protocol ADJAdjustLogger;

@protocol ADJAdjustPlugin <NSObject>

- (void)setPluginDependenciesWithLoggerFactory:(nonnull id<ADJAdjustLogger>)logger;

- (nonnull NSString *)source;

- (void)subscribeWithPublishers:(nonnull ADJAdjustPublishers *)adjustPublishers;

@end
