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
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties

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

    NSString *localInstanceid = (instanceId) ? : ADJDefaultInstanceId;
    ADJInstanceRoot * instanceRoot = [self.instanceMap objectForKey:localInstanceid];
    if(instanceRoot != nil) {
        return instanceRoot;
    }

    @synchronized ([ADJEntryRoot class]) {
        instanceRoot = [self.instanceMap objectForKey:localInstanceid];
        if (instanceRoot != nil) {
            return instanceRoot;
        }

        // TODO: (Gena) instance id validation
        instanceRoot = [[ADJInstanceRoot alloc] initWithConfigData:self.sdkConfigData
                                                        instanceId:localInstanceid];
        [self.instanceMap setObject:instanceRoot forKey:localInstanceid];
        return instanceRoot;
    }
}

- (void)finalizeAtTeardownWithCloseStorageBlock:(nullable void (^)(void))closeStorageBlock {
    @synchronized ([ADJEntryRoot class]) {
        [self.instanceMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            ADJInstanceRoot * instanceRoot = (ADJInstanceRoot *)obj;
            [instanceRoot finalizeAtTeardownWithBlock:closeStorageBlock];
        }];
    }
}

@end
