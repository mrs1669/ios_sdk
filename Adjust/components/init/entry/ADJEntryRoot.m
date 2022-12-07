//
//  ADJEntryRoot.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJEntryRoot.h"
#import "ADJInstanceRoot.h"
#import "ADJSdkConfigData.h"

#pragma mark Fields
#pragma mark - Public properties
// TODO: (Gena) - discuss this reference
NSString *const ADJDefaultInstanceId = @"ADJUST_DEFAULT_INSTANCE";

@interface ADJEntryRoot ()
@property (nonnull, readwrite, strong, nonatomic) NSMutableDictionary<NSString *, ADJInstanceRoot *> *instanceMap;
@property (nonnull, readwrite, strong, nonatomic) ADJSdkConfigData *sdkConfigData;
@end

@implementation ADJEntryRoot
#pragma mark Instantiation
- (nonnull instancetype)initWithInstanceId:(nullable NSString *)instanceId
                          sdkConfigBuilder:(nullable ADJSdkConfigDataBuilder *)sdkConfigBuilder {
    self = [super init];

    _instanceMap = [[NSMutableDictionary alloc] init];

    if (sdkConfigBuilder != nil) {
        _sdkConfigData = [[ADJSdkConfigData alloc] initWithBuilderData:sdkConfigBuilder];
    } else {
        _sdkConfigData = [[ADJSdkConfigData alloc] initWithDefaultValues];
    }

    // TODO: (Gena) instance id validation
    NSString *localInstanceid = (instanceId) ? : ADJDefaultInstanceId;
    ADJInstanceRoot *instanceRoot = [[ADJInstanceRoot alloc] initWithConfigData:_sdkConfigData
                                                                     instanceId:localInstanceid];
    [_instanceMap setObject:instanceRoot forKey:localInstanceid];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull ADJInstanceRoot *)instanceForId:(nullable NSString *)instanceId {
    @synchronized ([ADJEntryRoot class]) {

        NSString *localInstanceid = (instanceId) ? : ADJDefaultInstanceId;
        ADJInstanceRoot * instanceRoot = [self.instanceMap objectForKey:localInstanceid];
        if (!instanceRoot) {
            // TODO: (Gena) instance id validation
            instanceRoot = [[ADJInstanceRoot alloc] initWithConfigData:self.sdkConfigData
                                                            instanceId:localInstanceid];
            [self.instanceMap setObject:instanceRoot forKey:localInstanceid];
        }
        return instanceRoot;
    }
}

- (void)finalizeAtTeardownWithCloseStorageBlock:(nullable void (^)(void))closeStorageBlock {
    // TODO: (Gena) Implement the teardown logic
    /*
    __typeof(self) __weak weakSelf = self;
    BOOL canExecuteTask = [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        if (strongSelf.preSdkInitRootController != nil) {
            [strongSelf.preSdkInitRootController.storageRootController
                finalizeAtTeardownWithCloseStorageBlock:closeStorageBlock];
            [strongSelf.preSdkInitRootController.lifecycleController finalizeAtTeardown];
        }

        if (strongSelf.postSdkInitRootController != nil) {
            [strongSelf.postSdkInitRootController.reachabilityController finalizeAtTeardown];
        }

        [strongSelf.threadController finalizeAtTeardown];
    } source:@"finalize at teardown"];

    if (! canExecuteTask && closeStorageBlock != nil) {
        closeStorageBlock();
    }
     */
}

@end
