//
//  ADJPublishersRegistry.m
//  Adjust
//
//  Created by Genady Buchatsky on 23.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJPublishersRegistry.h"
#import "ADJSdkPackageCreatingSubscriber.h"
#import "ADJLogSubscriber.h"
#import "ADJSdkPackageSendingSubscriber.h"
#import "ADJSdkResponseSubscriber.h"
#import "ADJSdkActiveSubscriber.h"
#import "ADJAttributionSubscriber.h"
#import "ADJGdprForgetSubscriber.h"
#import "ADJSubscribingGateSubscriber.h"
#import "ADJPublishingGateSubscriber.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJKeepAliveSubscriber.h"
#import "ADJLifecycleSubscriber.h"
#import "ADJPreFirstMeasurementSessionStartSubscriber.h"
#import "ADJMeasurementSessionStartSubscriber.h"
#import "ADJOfflineSubscriber.h"
#import "ADJPausingSubscriber.h"
#import "ADJReachabilitySubscriber.h"

@interface ADJPublishersRegistry ()
@property (nonnull, readwrite, strong, nonatomic) NSMutableDictionary *publishersMap;
@end

@implementation ADJPublishersRegistry

- (instancetype)init {
    self = [super init];
    _publishersMap = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)addPublisher:(nonnull ADJPublisherBase *)publisher {

    NSString *className = NSStringFromClass([publisher class]);
    if ([self.publishersMap objectForKey:className]) {
        NSString *exReason = [NSString stringWithFormat:@"The same publisher [%@] cannot be added twice",
                               NSStringFromClass([publisher class])];
        @throw [NSException exceptionWithName:@"Unique publisher violation"
                                       reason:exReason
                                     userInfo:nil];
        return;
    }

    [self.publishersMap setObject:publisher forKey:className];
}

- (void)addSubscriber:(nonnull NSObject *)subscriber
          forProtocol:(Protocol *)protocol
          toPublisher:(NSString *)publisherName {

    if ([subscriber conformsToProtocol:protocol]) {
        ADJPublisherBase *publisher = [self.publishersMap objectForKey:publisherName];
        if(! publisher) {
            NSString *exReason = [NSString stringWithFormat:@"The publisher [%@] cannot be found.", publisherName];
            @throw [NSException exceptionWithName:@"Missing publisher"
                                           reason:exReason
                                         userInfo:nil];
        }

// TODO: (Gena) - Add the following log to a Verbose log level after merging latest Logger changes
//        NSString *subscriptionText = [NSString stringWithFormat:@"Subscribing [%@] to [%@]...",
//                                      NSStringFromClass([subscriber class]),
//                                      NSStringFromClass([publisher class])];
//        NSLog(@"* * * %@", subscriptionText);

        [publisher addSubscriber:subscriber];
    }
}


- (void)addSubscriberToPublishers:(nonnull NSObject *)subscriber {

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJSdkPackageCreatingSubscriber)
            toPublisher:NSStringFromClass([ADJSdkPackageCreatingPublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJLogSubscriber)
            toPublisher:NSStringFromClass([ADJLogPublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJSdkPackageSendingSubscriber)
            toPublisher:NSStringFromClass([ADJSdkPackageSendingPublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJSdkResponseSubscriber)
            toPublisher:NSStringFromClass([ADJSdkResponsePublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJSdkActiveSubscriber)
            toPublisher:NSStringFromClass([ADJSdkActivePublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJAttributionSubscriber)
            toPublisher:NSStringFromClass([ADJAttributionPublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJGdprForgetSubscriber)
            toPublisher:NSStringFromClass([ADJGdprForgetPublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJSubscribingGateSubscriber)
            toPublisher:NSStringFromClass([ADJSubscribingGatePublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJPublishingGateSubscriber)
            toPublisher:NSStringFromClass([ADJPublishingGatePublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJSdkInitSubscriber)
            toPublisher:NSStringFromClass([ADJSdkInitPublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJKeepAliveSubscriber)
            toPublisher:NSStringFromClass([ADJKeepAlivePublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJLifecycleSubscriber)
            toPublisher:NSStringFromClass([ADJLifecyclePublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJPreFirstMeasurementSessionStartSubscriber)
            toPublisher:NSStringFromClass([ADJPreFirstMeasurementSessionStartPublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJMeasurementSessionStartSubscriber)
            toPublisher:NSStringFromClass([ADJMeasurementSessionStartPublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJOfflineSubscriber)
            toPublisher:NSStringFromClass([ADJOfflinePublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJPausingSubscriber)
            toPublisher:NSStringFromClass([ADJPausingPublisher class])];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJReachabilitySubscriber)
            toPublisher:NSStringFromClass([ADJReachabilityPublisher class])];
}


@end
