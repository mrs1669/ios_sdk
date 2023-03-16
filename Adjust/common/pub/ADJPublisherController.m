//
//  ADJPublisherController.m
//  Adjust
//
//  Created by Pedro Silva on 13.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJPublisherController.h"

@interface ADJPubSubPair : NSObject
- (nonnull instancetype)initWithSubscriberProtocol:(nonnull Protocol *)subscriberProtocol
                                         publisher:(nonnull ADJPublisherBase *)publisher;

@property (nonnull, readonly, strong, nonatomic) Protocol *subscriberProtocol;
@property (nonnull, readonly, strong, nonatomic) ADJPublisherBase *publisher;

@end

@interface ADJPublisherController ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) NSMutableArray<ADJPubSubPair *> *pubSubPairs;

@end

@implementation ADJPublisherController
#pragma mark Instantiation
- (nonnull instancetype)init {
    self = [super init];

    _pubSubPairs = [[NSMutableArray alloc] init];

    return self;
}

- (void)addPairWithSubscriberProtocol:(nonnull Protocol *)subscriberProtocol
                            publisher:(nonnull ADJPublisherBase *)publisher
{
    [self.pubSubPairs addObject:
     [[ADJPubSubPair alloc] initWithSubscriberProtocol:subscriberProtocol publisher:publisher]];
}

- (void)subscribeToPublisher:(nonnull id)subscriber {
    for (ADJPubSubPair *_Nonnull pubSubPair in self.pubSubPairs) {
        if ([subscriber conformsToProtocol:pubSubPair.subscriberProtocol]) {
            [pubSubPair.publisher addSubscriber:subscriber];
        }
    }
}

@end

@implementation ADJPubSubPair
- (nonnull instancetype)initWithSubscriberProtocol:(nonnull Protocol *)subscriberProtocol
                                         publisher:(nonnull ADJPublisherBase *)publisher
{
    self = [super init];

    _subscriberProtocol = subscriberProtocol;
    _publisher = publisher;

    return self;
}

@end
