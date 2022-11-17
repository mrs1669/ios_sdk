//
//  ADJLogCollector.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <os/log.h>

#import "ADJLogMessageData.h"

@protocol ADJLogCollector <NSObject>

- (void)collectLogMessage:(nonnull ADJLogMessageData *)logMessageData;

@end
