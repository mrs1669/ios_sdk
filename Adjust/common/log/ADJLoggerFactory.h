//
//  ADJLoggerFactory.h
//  Adjust
//
//  Created by Aditi Agrawal on 13/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLogger.h"

@protocol ADJLoggerFactory <NSObject>

- (nonnull ADJLogger *)createLoggerWithName:(nonnull NSString *)loggerName;

@end
