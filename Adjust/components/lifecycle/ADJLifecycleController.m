//
//  ADJLifecycleController.m
//  Adjust
//
//  Created by Pedro Silva on 25.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLifecycleController.h"

// TODO: check that we can replace this different import
@import UIKit;
#import "ADJSingleThreadExecutor.h"
#import "ADJAtomicBoolean.h"
#import "ADJUtilF.h"
#import "ADJConstants.h"

#pragma mark Private class
@implementation ADJLifecyclePublisher @end

#pragma mark Fields
#pragma mark - Private constants
NSString *const kApplicationStateActive = @"ApplicationStateActive";
NSString *const kApplicationStateInactive = @"ApplicationStateInactive";
NSString *const kApplicationStateBackground = @"ApplicationStateBackground";

NSString *const kClientForeground = @"ClientForeground";
NSString *const kClientBackground = @"ClientBackground";

NSString *const kSdkInitForeground = @"SdkInitForeground";
NSString *const kSdkInitBackground = @"SdkInitBackground";

NSString *const kApplicationDidBecomeActiveNotification =
    @"ApplicationDidBecomeActiveNotification";
NSString *const kApplicationWillResignActiveNotification =
    @"ApplicationWillResignActiveNotification";

NSString *const kApplicationWillEnterForegroundNotification =
    @"ApplicationWillEnterForegroundNotification";
NSString *const kApplicationDidEnterBackgroundNotification =
    @"ApplicationDidEnterBackgroundNotification";

NSString *const kSceneDidActivateNotification =
    @"SceneDidActivateNotification";
NSString *const kSceneWillDeactivateNotification =
    @"SceneWillDeactivateNotification";

NSString *const kSceneWillEnterForegroundNotification =
    @"SceneWillEnterForegroundNotification";
NSString *const kSceneDidEnterBackgroundNotification =
    @"SceneDidEnterBackgroundNotification";

#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJLifecyclePublisher *lifecyclePublisher;
 */

@interface ADJLifecycleController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJThreadController *threadControllerWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nonnull, readonly, strong, nonatomic) ADJAtomicBoolean *isInForegroundAtomic;
@property (nonnull, readonly, strong, nonatomic) ADJAtomicBoolean *canPublishAtomic;

@end

@implementation ADJLifecycleController {
#pragma mark - Unmanaged variables
    volatile NSString *_cachedLifecycleStateChangeSource;
}

#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadController:(nonnull ADJThreadController *)threadController
    doNotReadCurrentLifecycleStatus:(BOOL)doNotReadCurrentLifecycleStatus
{
    self = [super initWithLoggerFactory:loggerFactory source:@"LifecycleController"];
    _threadControllerWeak = threadController;

    _lifecyclePublisher = [[ADJLifecyclePublisher alloc] init];

    _executor = [threadController createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                            sourceDescription:self.source];

    _isInForegroundAtomic = [[ADJAtomicBoolean alloc]
                                //initWithRelaxedValue:ADJIsSdkInForegroundWhenStarting];
                                initSeqCstMemoryOrderWithInitialBoolValue:
                                    ADJIsSdkInForegroundWhenStarting];

    //_canPublishAtomic = [[ADJAtomicBoolean alloc] initWithRelaxedValue:NO];
    _canPublishAtomic = [[ADJAtomicBoolean alloc] initSeqCstMemoryOrderWithInitialBoolValue:NO];

    _cachedLifecycleStateChangeSource = nil;

    if (! doNotReadCurrentLifecycleStatus) {
        [self readInitialApplicationState];
    } else {
        [self.logger debug:@"Configured to not read current lifecycle"];
    }

    [self subscribeToSystemLifecycleEvents];

    return self;
}

#pragma mark Public API
- (void)ccForeground {
    [self didForegroundWithSource:kClientForeground];
}

- (void)ccBackground {
    [self didBackgroundWithSource:kClientBackground];
}

#pragma mark - NSNotificationCenter subscriptions
// Application DidFinishLaunching Notification
- (void)applicationDidFinishLaunchingNotification {
}

// Application DidBecomeActive/WillResignActive Notification
- (void)applicationDidBecomeActiveNotification {
    //[self didForegroundWithSource:kApplicationDidBecomeActiveNotification];
}
- (void)applicationWillResignActiveNotification {
    // It can be inactive in the foreground, so do not consider it for lifecycle change
    //[self didBackgroundWithSource:kApplicationWillResignActiveNotification];
}

// Application WillEnterForeground/DidEnterBackground Notification
- (void)applicationWillEnterForegroundNotification {
    [self didForegroundWithSource:kApplicationWillEnterForegroundNotification];
}
- (void)applicationDidEnterBackgroundNotification {
    [self didBackgroundWithSource:kApplicationDidEnterBackgroundNotification];
}

// Scene SceneDidActivate/WillDeactivate Notification
- (void)sceneDidActivateNotification {
    //[self didForegroundWithSource:kSceneDidActivateNotification];
}
- (void)sceneWillDeactivateNotification {
    // It can be inactive in the foreground, so do not consider it for lifecycle change
    //[self didBackgroundWithSource:kSceneWillDeactivateNotification];
}

// Scene WillEnterForeground/DidEnterBackground Notification
- (void)sceneWillEnterForegroundNotification {
    [self didForegroundWithSource:kSceneWillEnterForegroundNotification];

}
- (void)sceneDidEnterBackgroundNotification {
    [self didBackgroundWithSource:kSceneDidEnterBackgroundNotification];
}
/*
- (void)applicationWillTerminateNotification {
    [self.logger debug:@"Removing observing of lifecycle notifications"];

    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center removeObserver:self];
}
 */

#pragma mark - ADJPublishingGateSubscriber
- (void)ccAllowedToPublishNotifications {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf publishWhenGatesOpen];
    }];
}

#pragma mark - Subscriptions
- (void)
    ccSubscribeToPublishersWithPublishingGatePublisher:
        (nonnull ADJPublishingGatePublisher *)publishingGatePublisher
{
    [publishingGatePublisher addSubscriber:self];
}

#pragma mark - ADJTeardownFinalizer
- (void)finalizeAtTeardown {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - NSObject
- (void)dealloc {
    [self finalizeAtTeardown];
}

#pragma mark Internal Methods
- (void)didForegroundWithSource:(nonnull NSString *)source {
    if (self->_cachedLifecycleStateChangeSource == nil) {
        @synchronized (self) {
            if (self->_cachedLifecycleStateChangeSource == nil) {
                [self.isInForegroundAtomic setBoolValue:YES];
                self->_cachedLifecycleStateChangeSource = source;

                [self publishDidForegroundAfterSdkInitWithSource:source];
                return;
            }
        }
    }

    if ([self.isInForegroundAtomic compareTo:NO andSetDesired:YES]) {
        self->_cachedLifecycleStateChangeSource = source;

        [self publishDidForegroundAfterSdkInitWithSource:source];
    } else {
        [self.logger debug:
            @"Did not change to the foreground from %@, since it did previously from %@",
            source, self->_cachedLifecycleStateChangeSource];
    }
}

- (void)publishDidForegroundAfterSdkInitWithSource:(nonnull NSString *)source {
    if ([self.canPublishAtomic boolValue]) {
        __typeof(self) __weak weakSelf = self;
        [self.executor executeInSequenceWithBlock:^{
            __typeof(weakSelf) __strong strongSelf = weakSelf;
            if (strongSelf == nil) { return; }

            [strongSelf.lifecyclePublisher notifySubscribersWithSubscriberBlock:
             ^(id<ADJLifecycleSubscriber> _Nonnull subscriber)
            {
                [subscriber onForegroundWithIsFromClientContext:source == kClientForeground];
            }];
        }];
    } else {
        [self.logger debug:@"Cannot publish foreground before sdk init"];
    }
}

- (void)didBackgroundWithSource:(nonnull NSString *)source {
    if (self->_cachedLifecycleStateChangeSource == nil) {
        @synchronized (self) {
            if (self->_cachedLifecycleStateChangeSource == nil) {
                [self.isInForegroundAtomic setBoolValue:NO];

                self->_cachedLifecycleStateChangeSource = source;

                [self publishDidBackgroundAfterSdkInitWithSource:source];
                return;
            }
        }
    }

    if ([self.isInForegroundAtomic compareTo:YES andSetDesired:NO]) {
        self->_cachedLifecycleStateChangeSource = source;

        [self publishDidBackgroundAfterSdkInitWithSource:source];
    } else {
        [self.logger debug:
            @"Did not change to the background from %@, since it did previously from %@",
            source, self->_cachedLifecycleStateChangeSource];
    }
}

- (void)publishDidBackgroundAfterSdkInitWithSource:(nonnull NSString *)source {
    if ([self.canPublishAtomic boolValue]) {
        __typeof(self) __weak weakSelf = self;
        [self.executor executeInSequenceWithBlock:^{
            __typeof(weakSelf) __strong strongSelf = weakSelf;
            if (strongSelf == nil) { return; }

            [strongSelf.lifecyclePublisher notifySubscribersWithSubscriberBlock:
             ^(id<ADJLifecycleSubscriber> _Nonnull subscriber)
            {
                [subscriber onBackgroundWithIsFromClientContext:source == kClientBackground];
            }];
        }];
    } else {
        [self.logger debug:@"Cannot publish background before sdk init"];
    }
}

- (void)publishWhenGatesOpen {
    [self.canPublishAtomic setBoolValue:YES];

    if (self->_cachedLifecycleStateChangeSource == nil) {
        @synchronized (self) {
            if (self->_cachedLifecycleStateChangeSource == nil) {
                // nothing to publish, since it has not detected a change
                return;
            }
        }
    }

    if (self.isInForegroundAtomic.boolValue) {
        [self.lifecyclePublisher notifySubscribersWithSubscriberBlock:
         ^(id<ADJLifecycleSubscriber> _Nonnull subscriber)
        {
            [subscriber onForegroundWithIsFromClientContext:NO];
        }];
    } else {
        [self.lifecyclePublisher notifySubscribersWithSubscriberBlock:
         ^(id<ADJLifecycleSubscriber> _Nonnull subscriber)
        {
            [subscriber onBackgroundWithIsFromClientContext:NO];
        }];
    }
}

- (void)subscribeToSystemLifecycleEvents {
    NSNotificationCenter *_Nonnull center = NSNotificationCenter.defaultCenter;

    // Application DidFinishLaunching Notification
    [center addObserver:self
               selector:@selector(applicationDidFinishLaunchingNotification)
                   name:UIApplicationDidFinishLaunchingNotification
                 object:nil];

    // Application DidBecomeActive/WillResignActive Notification
    [center addObserver:self
               selector:@selector(applicationDidBecomeActiveNotification)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(applicationWillResignActiveNotification)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];

    // Application WillEnterForeground/DidEnterBackground Notification
    [center addObserver:self
               selector:@selector(applicationWillEnterForegroundNotification)
                   name:UIApplicationWillEnterForegroundNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(applicationDidEnterBackgroundNotification)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];

    if (@available(iOS 13.0, *)) {
        // Scene SceneDidActivate/WillDeactivate Notification
        [center addObserver:self
                   selector:@selector(sceneDidActivateNotification)
                       name:UISceneDidActivateNotification
                     object:nil];

        [center addObserver:self
                   selector:@selector(sceneWillDeactivateNotification)
                       name:UISceneWillDeactivateNotification
                     object:nil];

        // Scene WillEnterForeground/DidEnterBackground Notification
        [center addObserver:self
                   selector:@selector(sceneWillEnterForegroundNotification)
                       name:UISceneWillEnterForegroundNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(sceneDidEnterBackgroundNotification)
                       name:UISceneDidEnterBackgroundNotification
                     object:nil];
    }

    // Application WillTerminate Notification
    /*
    [center addObserver:self
               selector:@selector(applicationWillTerminateNotification)
                   name:UIApplicationWillTerminateNotification
                 object:nil];
     */

    // TODO detect if it started in viewController/AppDelegate
}

- (void)readInitialApplicationState {
    ADJThreadController *threadController = self.threadControllerWeak;

    if (threadController == nil) {
        [self.logger error:@"Cannot read initial application state"
            " without thread controller reference"];
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [threadController executeInMainThreadWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        // neither foreground or background need to be set, since it has already been set
        // no need to syncronize, since after it's not nil, it will conitnue not nill
        if (strongSelf->_cachedLifecycleStateChangeSource != nil) {
            return;
        }

        UIApplication *_Nonnull application = UIApplication.sharedApplication;

        UIApplicationState applicationState = application.applicationState;

        if (UIApplicationStateBackground == applicationState) {
            [strongSelf didBackgroundWithSource:kApplicationStateBackground];
        } else if (UIApplicationStateActive == applicationState) {
            [strongSelf didForegroundWithSource:kApplicationStateActive];
        } else if (UIApplicationStateInactive == applicationState) {
            [strongSelf didForegroundWithSource:kApplicationStateInactive];
        } else {
            [strongSelf.logger debug:
                @"Could not detect applicationState from main thread with value %@",
                [ADJUtilF integerFormat:applicationState]];
        }
    }];
}

@end
