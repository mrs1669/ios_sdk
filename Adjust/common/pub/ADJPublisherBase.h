//
//  ADJPublisherBase.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

//import "ADJPublisherController.h"
@class ADJPublisherController;

@interface ADJPublisherBase<T> : NSObject
// instantiation
- (nonnull instancetype)initWithSubscriberProtocol:(nonnull Protocol *)subscriberProtocol
                                        controller:(nonnull ADJPublisherController *)controller;

- (nonnull instancetype)initWithoutSubscriberProtocol;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSHashTable<T> *subscriberSet;

// public api
- (void)addSubscriber:(nonnull T)subscriber;

- (void)removeSubscriber:(nonnull T)subscriber;

- (BOOL)hasSubscribers;

- (void)notifySubscribersWithSubscriberBlock:(void (^_Nonnull)(T _Nonnull subscriber))subscriberBlock;

+ (void)notifySubscribersWithSubscriberBlock:(void (^_Nonnull)(T _Nonnull subscriber))subscriberBlock
                               subscriberSet:(nonnull NSHashTable<T> *)subscriberSet;

@end

