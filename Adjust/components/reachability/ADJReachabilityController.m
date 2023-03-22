//
//  ADJReachabilityController.m
//  Adjust
//
// adapted from
//  https://github.com/tonymillion/Reachability
//  https://developer.apple.com/library/archive/samplecode/Reachability/Introduction/Intro.html
//  https://github.com/ashleymills/Reachability.swift
//  Created by Pedro S. on 07.03.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJReachabilityController.h"

#import "ADJSingleThreadExecutor.h"

#import <SystemConfiguration/SCNetworkReachability.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#pragma mark Private class
@implementation ADJReachabilityPublisher @end

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kNotReachable = @"NotReachable";
static NSString *const kReachableViaWiFi = @"reachableViaWiFi";
static NSString *const kReachableViaWWAN = @"reachableViaWWAN";

#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic)
 ADJReachabilityPublisher *reachabilityPublisher;
 */

@interface ADJReachabilityController ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) NSString *targetEndpoint;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
//@property (nullable, readwrite, strong, nonatomic) NSString *reachableNetwork;
@property (nullable, readwrite, strong, nonatomic) NSNumber *isReachableNumberBool;

// visibility for static method
- (void)reachabilityChangedWithFlags:(SCNetworkReachabilityFlags)flags;

@end

#pragma mark Static C Methods
static void ADJReachabilityCallback(SCNetworkReachabilityRef target,
                                    SCNetworkReachabilityFlags flags,
                                    void *info) {
    ADJReachabilityController *reachabilityController =
    ((__bridge ADJReachabilityController*)info);

    if (reachabilityController) {
        [reachabilityController reachabilityChangedWithFlags:flags];
    }
}

@implementation ADJReachabilityController {
#pragma mark - Unmanaged variables
    SCNetworkReachabilityRef _reachabilityRef;
}

#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             threadController:(nonnull ADJThreadController *)threadController
                               targetEndpoint:(nonnull NSString *)targetEndpoint
                          publisherController:(nonnull ADJPublisherController *)publisherController
{
    self = [super initWithLoggerFactory:loggerFactory source:@"ReachabilityController"];
    _targetEndpoint = targetEndpoint;

    _executor = [threadController createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                            sourceDescription:self.source];

    _reachabilityPublisher = [[ADJReachabilityPublisher alloc]
                              initWithSubscriberProtocol:@protocol(ADJReachabilitySubscriber)
                              controller:publisherController];

    //_reachableNetwork = nil;

    _isReachableNumberBool = nil;

    return self;
}

#pragma mark Public API
#pragma mark - ADJSdkStartSubscriber
- (void)ccSdkStart {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeAsyncWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        // TODO: possibly use private queue
        [strongSelf startNetworkReachabilityWithDispatchQueue:
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)];
    } source:@"sdk start"];
}

#pragma mark Internal Methods
- (void)startNetworkReachabilityWithDispatchQueue:(nonnull dispatch_queue_t)dispatchQueue {
    _reachabilityRef = [self createReachabilityRef];

    BOOL didSubscribeToSystemReachability =
        [self subscribeToSystemReachabilityWithDispatchQueue:dispatchQueue];

    // when it cannot subscribe to the system reachability service
    //  do not publish even if it could on demand
    if (! didSubscribeToSystemReachability) {
        return;
    }

    // read reachability on demand to publish the current reachability status
    //  that might be updated from the system reachability service
    NSString *_Nullable readReachability = [self readReachabilitySync];

    [self updateAndPublishWithReachability:readReachability];
}

- (SCNetworkReachabilityRef)createReachabilityRef {
    // init reachabilityRef from url name or ip address (for test server)
    NSURL *endpointNSUrl = [NSURL URLWithString:self.targetEndpoint];

    struct in_addr pin;
    if (endpointNSUrl
        && endpointNSUrl.host
        && endpointNSUrl.port
        && (1 == inet_aton(endpointNSUrl.host.UTF8String, &pin)))
    {
        struct sockaddr_in address;
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;
        address.sin_port = htons(endpointNSUrl.port.intValue);
        address.sin_addr.s_addr = inet_addr(endpointNSUrl.host.UTF8String);

        return
        SCNetworkReachabilityCreateWithAddress
        (kCFAllocatorDefault, (const struct sockaddr*)&address);
    } else {
        return SCNetworkReachabilityCreateWithName(NULL, self.targetEndpoint.UTF8String);
    }
}

- (BOOL)subscribeToSystemReachabilityWithDispatchQueue:(nonnull dispatch_queue_t)dispatchQueue {
    SCNetworkReachabilityRef localStrongReachabilityRef = _reachabilityRef;
    if (! localStrongReachabilityRef) {
        [self.logger debugDev:@"Cannot subscribe to system reachability with nil reachabilityRef"
                    issueType:ADJIssueExternalApi];
        return NO;
    }

    SCNetworkReachabilityContext context = { 0, NULL, NULL, NULL, NULL };
    context.info = (__bridge void *)self;

    // retains 'self' in callback, needs to be set NULL to release
    if(! SCNetworkReachabilitySetCallback(localStrongReachabilityRef,
                                          ADJReachabilityCallback,
                                          &context))
    {
        [self.logger debugDev:@"Could not set reachability callback"
                    issueType:ADJIssueExternalApi];
        return NO;
    }

    // dispatch queue will be retained, needs to be set NULL to release
    if(! SCNetworkReachabilitySetDispatchQueue(localStrongReachabilityRef, dispatchQueue)) {
        [self.logger debugDev:@"Could not set dispatch queue"
                    issueType:ADJIssueExternalApi];

        // remove callback and release 'self'
        SCNetworkReachabilitySetCallback(localStrongReachabilityRef, NULL, NULL);

        return NO;
    }

    return YES;
}

- (nullable NSString *)readReachabilitySync {
    SCNetworkReachabilityRef localStrongReachabilityRef = _reachabilityRef;
    if (! localStrongReachabilityRef) {
        [self.logger debugDev:@"Cannot read reachability with nil reachabilityRef"
                    issueType:ADJIssueExternalApi];

        return nil;
    }

    SCNetworkReachabilityFlags currentFlags;

    if(! SCNetworkReachabilityGetFlags(localStrongReachabilityRef, &currentFlags)) {
        return nil;
    }

    return [self reachableNetworkWithFlags:currentFlags];
}

- (nonnull NSString *)reachableNetworkWithFlags:(SCNetworkReachabilityFlags)flags {
    NSString *reachableNetworkTM = [self reachableNetworkWithFlagsTM:flags];

    return reachableNetworkTM;
    /*
     NSString *reachableNetworkAS = [self reachableNetworkWithFlagsAS:flags];

     if (reachableNetworkTM == reachableNetworkAS) {
     return reachableNetworkTM;
     }

     [self.logger debug:@"Detected different reachable network, with TM: %@ and AS:%@",
     reachableNetworkTM, reachableNetworkAS];

     // if they are different, return the one that is reachable
     //  if both are reachable, prefer the AS network
     if (reachableNetworkTM == ADJReachabilityStateNotReachable) {
     return reachableNetworkAS;
     } else {
     return reachableNetworkTM;
     }
     */
}

// adapted from https://github.com/tonymillion/Reachability
- (nonnull NSString *)reachableNetworkWithFlagsTM:(SCNetworkReachabilityFlags)flags {
    if(! (flags & kSCNetworkReachabilityFlagsReachable)) {
        return kNotReachable;
    }

    if((flags & (kSCNetworkReachabilityFlagsConnectionRequired
                 | kSCNetworkReachabilityFlagsTransientConnection))
       == (kSCNetworkReachabilityFlagsConnectionRequired
           | kSCNetworkReachabilityFlagsTransientConnection) )
    {
        return kNotReachable;
    }

    if(flags & kSCNetworkReachabilityFlagsIsWWAN) {
        return kReachableViaWWAN;
    } else {
        return kReachableViaWiFi;
    }
}
/*
 // adapted from
 //  https://developer.apple.com/library/archive/samplecode/Reachability/Introduction/Intro.html
 - (nonnull NSString *)reachableNetworkWithFlagsAS:(SCNetworkReachabilityFlags)flags {
 if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
 return ADJReachabilityStateNotReachable;
 }

 if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
 return ADJReachabilityStateReachableViaWWAN;
 }

 if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
 return ADJReachabilityStateReachableViaWiFi;
 }

 if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
 {
 if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
 return ADJReachabilityStateReachableViaWiFi;
 }
 }

 return ADJReachabilityStateNotReachable;
 }
 */

- (nonnull NSString *)reachabilityFlagsDescription:(SCNetworkReachabilityFlags)flags {
    return [NSString stringWithFormat:@"%c%c %c%c%c%c%c%c%c",
            // if/when Mac OS is supported, add @available check
            (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
            (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
            (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
            (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
            (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
}

- (void)updateAndPublishWithReachability:(nullable NSString *)networkReachability {
    BOOL newReachabilityIsTrue =
    networkReachability == kReachableViaWWAN || networkReachability == kReachableViaWiFi;
    BOOL newReachabilityIsFalse = networkReachability == kNotReachable;

    if (! newReachabilityIsTrue && ! newReachabilityIsFalse ) {
        [self stopNetworkReachability];
        return;
    }

    if (self.isReachableNumberBool != nil
        && self.isReachableNumberBool.boolValue == newReachabilityIsTrue)
    {
        return;
    }

    self.isReachableNumberBool = @(newReachabilityIsTrue);

    if (self.isReachableNumberBool.boolValue) {
        [self.reachabilityPublisher notifySubscribersWithSubscriberBlock:
         ^(id<ADJReachabilitySubscriber> _Nonnull subscriber)
         {
            [subscriber didBecomeReachable];
        }];
    } else {
        [self.reachabilityPublisher notifySubscribersWithSubscriberBlock:
         ^(id<ADJReachabilitySubscriber> _Nonnull subscriber)
         {
            [subscriber didBecomeUnreachable];
        }];
    }
}

- (void)reachabilityChangedWithFlags:(SCNetworkReachabilityFlags)flags {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        NSString *_Nullable reachableNetworkFromFlags =
        [strongSelf reachableNetworkWithFlags:flags];

        [strongSelf updateAndPublishWithReachability:reachableNetworkFromFlags];
    } source:@"reachability changed"];
}

- (void)stopNetworkReachability {
    [self.reachabilityPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJReachabilitySubscriber> _Nonnull subscriber)
     {
        [subscriber didBecomeReachable];
    }];

    SCNetworkReachabilityRef localStrongReachabilityRef = _reachabilityRef;
    _reachabilityRef = NULL;
    if (! localStrongReachabilityRef) {
        return;
    }

    // remove callback and release 'self'
    SCNetworkReachabilitySetCallback(localStrongReachabilityRef, NULL, NULL);

    // release set dispatch queue
    SCNetworkReachabilitySetDispatchQueue(localStrongReachabilityRef, NULL);

    CFRelease(localStrongReachabilityRef);
}

#pragma mark - ADJTeardownFinalizer
- (void)finalizeAtTeardown {
    [self stopNetworkReachability];
}

#pragma mark - NSObject
- (void)dealloc {
    [self finalizeAtTeardown];
}

@end

