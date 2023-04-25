//
//  ADJLifecycleController.m
//  Adjust
//
//  Created by Pedro Silva on 25.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ADJLifecycleController.h"

#import "ADJBooleanWrapper.h"
#import "ADJUtilF.h"
#import "ADJConstants.h"

#pragma mark Private class
@implementation ADJLifecyclePublisher @end

#pragma mark Fields
#pragma mark - Private constants
NSString *const kImStartForeground = @"ImStartForeground";

NSString *const kApplicationStateActive = @"ApplicationStateActive";
NSString *const kApplicationStateInactive = @"ApplicationStateInactive";
NSString *const kApplicationStateBackground = @"ApplicationStateBackground";

NSString *const kClientForeground = @"ClientForeground";
NSString *const kClientBackground = @"ClientBackground";

NSString *const kSdkInitForeground = @"SdkInitForeground";
NSString *const kSdkInitBackground = @"SdkInitBackground";

NSString *const kApplicationDidBecomeActiveNotification = @"ApplicationDidBecomeActiveNotification";
NSString *const kApplicationWillResignActiveNotification = @"ApplicationWillResignActiveNotification";

NSString *const kApplicationWillEnterForegroundNotification = @"ApplicationWillEnterForegroundNotification";
NSString *const kApplicationDidEnterBackgroundNotification = @"ApplicationDidEnterBackgroundNotification";

NSString *const kSceneDidActivateNotification = @"SceneDidActivateNotification";
NSString *const kSceneWillDeactivateNotification = @"SceneWillDeactivateNotification";

NSString *const kSceneWillEnterForegroundNotification = @"SceneWillEnterForegroundNotification";
NSString *const kSceneDidEnterBackgroundNotification = @"SceneDidEnterBackgroundNotification";

#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJLifecyclePublisher *lifecyclePublisher;
 */

@interface ADJLifecycleController ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJThreadController *threadController;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *clientExecutor;

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL canPublish;
@property (nullable, readwrite, assign, nonatomic) ADJBooleanWrapper *foregroundOrElseBackground;

@end

@implementation ADJLifecycleController {
#pragma mark - Unmanaged variables
    volatile NSString *_cachedLifecycleStateChangeSource;
}

#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             threadController:(nonnull ADJThreadController *)threadController
              doNotReadCurrentLifecycleStatus:(BOOL)doNotReadCurrentLifecycleStatus
                               clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
                          publisherController:(nonnull ADJPublisherController *)publisherController
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"LifecycleController"];
    _threadController = threadController;
    _clientExecutor = clientExecutor;

    _lifecyclePublisher = [[ADJLifecyclePublisher alloc]
                           initWithSubscriberProtocol:@protocol(ADJLifecycleSubscriber)
                           controller:publisherController];

    _canPublish = NO;

    _foregroundOrElseBackground = nil;

    if (! doNotReadCurrentLifecycleStatus) {
#if defined(ADJUST_IM)
        [self ccChangeTo:YES onlyChangeFromNil:NO from:kImStartForeground];
#else
        [self ccReadInitialApplicationState];
#endif
    } else {
        [self.logger debugDev:@"Configured to not read current lifecycle"];
    }

    [self subscribeToSystemLifecycleEvents];

    return self;
}

#pragma mark Public API
- (void)ccForeground {
    [self ccChangeTo:YES onlyChangeFromNil:NO from:kClientForeground];
}

- (void)ccBackground {
    [self ccChangeTo:NO onlyChangeFromNil:NO from:kClientBackground];
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
    [self putInForegroundWithSource:kApplicationWillEnterForegroundNotification];
}
- (void)applicationDidEnterBackgroundNotification {
    [self putInBackgroundWithSource:kApplicationDidEnterBackgroundNotification];
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
    [self putInForegroundWithSource:kSceneWillEnterForegroundNotification];
}

- (void)sceneDidEnterBackgroundNotification {
    [self putInBackgroundWithSource:kSceneDidEnterBackgroundNotification];
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
    self.canPublish = YES;

    [self ccPublish];
}

#pragma mark - ADJTeardownFinalizer
- (void)finalizeAtTeardown {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - NSObject
- (void)dealloc {
    [self finalizeAtTeardown];
}

#pragma mark - Internal Methods
- (void)putInForegroundWithSource:(nonnull NSString *)source {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithLogger:self.logger
                                                    from:@"put in foreground"
                                                   block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf ccChangeTo:YES onlyChangeFromNil:NO from:source];
    }];
}
- (void)putInBackgroundWithSource:(nonnull NSString *)source {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithLogger:self.logger
                                                    from:@"put in background"
                                                   block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf ccChangeTo:NO onlyChangeFromNil:NO from:source];
    }];
}

- (void)
    ccChangeTo:(BOOL)foregroundOrElseBackground
    onlyChangeFromNil:(BOOL)onlyChangeFromNil
    from:(nonnull NSString *)from
{
    if (self.foregroundOrElseBackground != nil
        && self.foregroundOrElseBackground.boolValue == foregroundOrElseBackground)
    {
        [self.logger debugDev:
            @"Did not change, since it was already in the same lifecycle state"
                         from:from
                          key:@"lifecycle state"
                  stringValue:foregroundOrElseBackground ? @"foreground" : @"background"];
        return;
    }

    if (onlyChangeFromNil && self.foregroundOrElseBackground != nil) {
        return;
    }

    self.foregroundOrElseBackground =
        [ADJBooleanWrapper instanceFromBool:foregroundOrElseBackground];

    [self ccPublish];
}

- (void)ccPublish {
    if (! self.canPublish) { return; }

    if (self.foregroundOrElseBackground == nil) {
        [self.logger debugDev:@"Cannot publish because it does not have lifecycle information"];
        return;
    }

    if (self.foregroundOrElseBackground.boolValue) {
        [self.lifecyclePublisher notifySubscribersWithSubscriberBlock:
         ^(id<ADJLifecycleSubscriber> _Nonnull subscriber)
         {
            [subscriber ccDidForeground];
        }];
    } else {
        [self.lifecyclePublisher notifySubscribersWithSubscriberBlock:
         ^(id<ADJLifecycleSubscriber> _Nonnull subscriber)
         {
            [subscriber ccDidBackground];
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

    // TODO: detect if it started in viewController/AppDelegate
}

- (void)ccReadInitialApplicationState {
    __typeof(self) __weak weakSelf = self;
    [self.threadController executeInMainThreadWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        UIApplication *_Nonnull application = UIApplication.sharedApplication;

        [strongSelf.logger debugDev:@"Shared UIApplication state to read"
                                key:@"UIApplicationState"
                        stringValue:[ADJUtilF integerFormat:application.applicationState]];

        UIApplicationState applicationState = application.applicationState;

        [strongSelf.clientExecutor executeAsyncWithLogger:strongSelf.logger
                                                     from:@"ReadInitialApplicationState"
                                                    block:^{
            if (UIApplicationStateBackground == applicationState) {
                [strongSelf ccChangeTo:NO
                     onlyChangeFromNil:YES
                                from:kApplicationStateBackground];
            } else if (UIApplicationStateActive == applicationState) {
                [strongSelf ccChangeTo:YES
                     onlyChangeFromNil:YES
                                from:kApplicationStateActive];
            } else if (UIApplicationStateInactive == applicationState) {
                [strongSelf ccChangeTo:YES
                     onlyChangeFromNil:YES
                                from:kApplicationStateInactive];
            } else {
                [strongSelf.logger debugDev:
                 @"Could not detect applicationState from main thread"
                                  issueType:ADJIssueInvalidInput];
            }
        }];
    }];
}

@end
