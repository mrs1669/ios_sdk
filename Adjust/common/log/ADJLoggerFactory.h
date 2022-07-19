//
//  ADJLoggerFactory.h
//  Adjust
//
//  Created by Aditi Agrawal on 13/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

@import Foundation;

#import "ADJLogger.h"

@protocol ADJLoggerFactory <NSObject>

- (nonnull ADJLogger *)createLoggerWithSource:(nonnull NSString *)source;

@end
