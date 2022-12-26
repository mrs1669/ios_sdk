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
            toPublisher:@"ADJSdkPackageCreatingPublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJLogSubscriber)
            toPublisher:@"ADJLogPublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJSdkPackageSendingSubscriber)
            toPublisher:@"ADJSdkPackageSendingPublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJSdkResponseSubscriber)
            toPublisher:@"ADJSdkResponsePublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJSdkActiveSubscriber)
            toPublisher:@"ADJSdkActivePublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJAttributionSubscriber)
            toPublisher:@"ADJAttributionPublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJGdprForgetSubscriber)
            toPublisher:@"ADJGdprForgetPublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJSubscribingGateSubscriber)
            toPublisher:@"ADJSubscribingGatePublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJPublishingGateSubscriber)
            toPublisher:@"ADJPublishingGatePublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJSdkInitSubscriber)
            toPublisher:@"ADJSdkInitPublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJKeepAliveSubscriber)
            toPublisher:@"ADJKeepAlivePublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJLifecycleSubscriber)
            toPublisher:@"ADJLifecyclePublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJPreFirstMeasurementSessionStartSubscriber)
            toPublisher:@"ADJPreFirstMeasurementSessionStartPublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJMeasurementSessionStartSubscriber)
            toPublisher:@"ADJMeasurementSessionStartPublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJOfflineSubscriber)
            toPublisher:@"ADJOfflinePublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJPausingSubscriber)
            toPublisher:@"ADJPausingPublisher"];

    [self addSubscriber:subscriber
            forProtocol:@protocol(ADJReachabilitySubscriber)
            toPublisher:@"ADJReachabilityPublisher"];
}


@end
