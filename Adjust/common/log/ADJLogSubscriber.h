//
//  ADJLogSubscriber.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"
#import "ADJLogMessageData.h"

@protocol ADJLogSubscriber <NSObject>

- (void)didLogMessage:(nonnull ADJLogMessageData *)logMessageData;

- (void)didLogMessagesPreInitWithArray:(nonnull NSArray<ADJLogMessageData *> *)preInitLogMessageArray;

@end

@interface ADJLogPublisher : ADJPublisherBase<id<ADJLogSubscriber>>

@end

