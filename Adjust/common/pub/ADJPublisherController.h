//
//  ADJPublisherController.h
//  Adjust
//
//  Created by Pedro Silva on 13.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

@interface ADJPublisherController : NSObject

- (void)addPairWithSubscriberProtocol:(nonnull Protocol *)subscriberProtocol
                            publisher:(nonnull ADJPublisherBase *)publisher;

- (void)subscribeToPublisher:(nonnull id)subscriber;

@end
