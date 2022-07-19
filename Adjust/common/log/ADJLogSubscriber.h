//
//  ADJLogSubscriber.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"
#import "ADJAdjustLogMessageData.h"

@protocol ADJLogSubscriber <NSObject>

- (void)didLogWithMessage:(nonnull NSString *)logMessage
                   source:(nonnull NSString *)source
           adjustLogLevel:(nonnull NSString *)adjustLogLevel;

- (void)didLogMessagesPreInitWithArray:
    (nonnull NSArray<ADJAdjustLogMessageData *> *)preInitLogMessageArray;

@end

@interface ADJLogPublisher : ADJPublisherBase<id<ADJLogSubscriber>>
@end

