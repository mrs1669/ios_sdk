//
//  ADJPublisherBase.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJPublisherBase.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSHashTable<T> *subscriberSet;
 */

@implementation ADJPublisherBase
#pragma mark Instantiation
- (nonnull instancetype)init {
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJPublisherBase class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }

    self = [super init];

    _subscriberSet = [NSHashTable weakObjectsHashTable];

    return self;
}

#pragma mark Public API
- (void)addSubscriber:(nonnull id)subscriber {
    [self.subscriberSet addObject:subscriber];
}

- (void)removeSubscriber:(nonnull id)subscriber {
    [self.subscriberSet removeObject:subscriber];
}

- (BOOL)hasSubscribers {
    return self.subscriberSet.count != 0;
}
- (void)
    notifySubscribersWithSubscriberBlock:(void (^_Nonnull)(id _Nonnull subscriber))subscriberBlock
{
    [ADJPublisherBase
        notifySubscribersWithSubscriberBlock:subscriberBlock
        subscriberSet:self.subscriberSet];
}

+ (void)
    notifySubscribersWithSubscriberBlock:(void (^_Nonnull)(id _Nonnull subscriber))subscriberBlock
    subscriberSet:(nonnull NSHashTable *)subscriberSet
{
    for (id subscriber in subscriberSet) {
        // TODO: figure out if released references still show up in fast enumeration
        if (subscriber) {
            subscriberBlock(subscriber);
        }
    }
}

@end

