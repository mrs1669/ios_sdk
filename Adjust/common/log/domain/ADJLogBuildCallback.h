//
//  ADJLogBuildCallback.h
//  Adjust
//
//  Created by Pedro Silva on 01.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJInputLogMessageData.h"

@protocol ADJLogBuildCallback <NSObject>

- (void)endInputLog:(nonnull ADJInputLogMessageData *)inputLogMessageData;

@end

