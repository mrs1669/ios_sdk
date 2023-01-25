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
#import "ADJInstanceIdData.h"

#pragma mark Fields
#pragma mark - Public properties

@interface ADJEntryRoot ()
@property (nonnull, readwrite, strong, nonatomic)
    NSMutableDictionary<NSString *, ADJInstanceRoot *> *instanceMap;
@property (nonnull, readwrite, strong, nonatomic) ADJSdkConfigData *sdkConfigData;
@end

@implementation ADJEntryRoot
#pragma mark Instantiation
- (nonnull instancetype)initWithClientId:(nullable NSString *)clientId
                        sdkConfigBuilder:(nullable ADJSdkConfigDataBuilder *)sdkConfigBuilder
{
    self = [super init];

    _instanceMap = [[NSMutableDictionary alloc] init];

    if (sdkConfigBuilder != nil) {
        _sdkConfigData = [[ADJSdkConfigData alloc] initWithBuilderData:sdkConfigBuilder];
    } else {
        _sdkConfigData = [[ADJSdkConfigData alloc] initWithDefaultValues];
    }

    ADJInstanceIdData *_Nonnull firstInstanceId =
        [[ADJInstanceIdData alloc] initFirstInstanceWithClientId:clientId];

    ADJInstanceRoot *instanceRoot = [[ADJInstanceRoot alloc] initWithConfigData:_sdkConfigData
                                                                     instanceId:firstInstanceId];

    [_instanceMap setObject:instanceRoot forKey:firstInstanceId.idString];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull ADJInstanceRoot *)instanceForClientId:(nullable NSString *)clientId {
    ADJInstanceRoot *_Nullable instanceRoot =
        [self.instanceMap objectForKey:[ADJInstanceIdData toIdStringWithClientId:clientId]];
    if (instanceRoot != nil) {
        return instanceRoot;
    }

    @synchronized ([ADJEntryRoot class]) {
        // repeat map query to detect duplicate concurrent access
        instanceRoot =
            [self.instanceMap objectForKey:[ADJInstanceIdData toIdStringWithClientId:clientId]];
        if (instanceRoot != nil) {
            return instanceRoot;
        }

        ADJInstanceIdData *_Nonnull newInstanceId =
            [[ADJInstanceIdData alloc] initNonFirstWithClientId:clientId];

        ADJInstanceRoot *newInstanceRoot =
            [[ADJInstanceRoot alloc] initWithConfigData:self.sdkConfigData
                                             instanceId:newInstanceId];

        [self.instanceMap setObject:newInstanceRoot forKey:newInstanceId.idString];

        return newInstanceRoot;
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
