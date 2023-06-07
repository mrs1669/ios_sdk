//
//  ADJV4RestMigration.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJV4RestMigration.h"

#import "ADJAdjust.h"
#import "ADJAdjustInstance.h"
#import "ADJAdjustLaunchedDeeplink.h"
#import "ADJAdjustPushToken.h"

@interface ADJV4RestMigration ()
@property (nonnull, readonly, strong, nonatomic) ADJInstanceIdData *instanceId;
@end

@implementation ADJV4RestMigration
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                   instanceId:(nonnull ADJInstanceIdData *)instanceId
{
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"ADJV4RestMigration"];
    _instanceId = instanceId;
    return self;
}

#pragma mark Public API
- (void)migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    // TODO: should it be injected some other way, instead of these "client" facing ones?
    [self migrateV4DeeplinkWithV4UserDefaultsData:v4UserDefaultsData];

    [self migrateV4PushTokenWithV4FilesData:v4FilesData
                         v4UserDefaultsData:v4UserDefaultsData];
}

#pragma mark Internal Methods
- (void)migrateV4DeeplinkWithV4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    NSURL *_Nullable v4DeeplinkUrl = v4UserDefaultsData.deeplinkUrl;

    if (v4DeeplinkUrl == nil) {
        [self.logger debugDev:@"Deeplink not found in v4 user defaults"];
        return;
    }

    ADJAdjustLaunchedDeeplink *_Nonnull adjustLaunchedDeeplink = [[ADJAdjustLaunchedDeeplink alloc] initWithUrl:v4DeeplinkUrl];
    [[ADJAdjust instanceForId:self.instanceId.idString] trackLaunchedDeeplink:adjustLaunchedDeeplink];
}

- (void)migrateV4PushTokenWithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                       v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    ADJV4ActivityState *_Nullable v4ActivityState = [v4FilesData v4ActivityState];
    if (v4ActivityState != nil) {
        [self.logger debugDev:@"Activity state v4 file found"];

        if (v4ActivityState.deviceToken != nil) {
            [self.logger debugDev:@"Push token found in v4 Activity state"];
            ADJAdjustPushToken *_Nonnull adjustPushToken = [[ADJAdjustPushToken alloc] initWithStringPushToken:v4ActivityState.deviceToken];
            [[ADJAdjust instanceForId:self.instanceId.idString] trackPushToken:adjustPushToken];
            return;
        }

        [self.logger debugDev:@"Push token not found in v4 Activity state"];
    } else {
        [self.logger debugDev:@"Activity state v4 file not found"];
    }

    NSString *_Nullable pushTokenString = v4UserDefaultsData.pushTokenString;
    if (pushTokenString != nil) {
        [self.logger debugDev:@"Push token string found in v4 user defaults"];
        ADJAdjustPushToken *_Nonnull adjustPushToken = [[ADJAdjustPushToken alloc] initWithStringPushToken:pushTokenString];
        [[ADJAdjust instanceForId:self.instanceId.idString] trackPushToken:adjustPushToken];
        return;
    }

    [self.logger debugDev:@"Push token string not found in v4 user defaults"];

    NSData *_Nullable pushTokenData = v4UserDefaultsData.pushTokenData;
    if (pushTokenData != nil) {
        [self.logger debugDev:@"Push token data found in v4 user defaults"];
        ADJAdjustPushToken *_Nonnull adjustPushToken = [[ADJAdjustPushToken alloc] initWithDataPushToken:pushTokenData];
        [[ADJAdjust instanceForId:self.instanceId.idString] trackPushToken:adjustPushToken];
        return;
    }

    [self.logger debugDev:@"Push token data not found in v4 user defaults"];
}

@end
