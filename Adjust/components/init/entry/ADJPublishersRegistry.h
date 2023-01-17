//
//  ADJPublishersRegistry.h
//  Adjust
//
//  Created by Genady Buchatsky on 23.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJPublisherBase.h"

@interface ADJPublishersRegistry : NSObject
- (void)addPublisher:(nonnull ADJPublisherBase *)publisher;
- (void)addSubscriberToPublishers:(nonnull NSObject *)subscriber;
@end
