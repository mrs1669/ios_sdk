//
//  ADJV4RestMigration.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJV4RestMigration.h"

#import "ADJAdjust.h"

@implementation ADJV4RestMigration
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"ADJV4RestMigration"];

    return self;
}

#pragma mark Public API
- (void)migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    [self migrateV4DeeplinkWithV4UserDefaultsData:v4UserDefaultsData];

    [self migrateV4PushTokenWithV4FilesData:v4FilesData
                         v4UserDefaultsData:v4UserDefaultsData];
}

#pragma mark Internal Methods
- (void)migrateV4DeeplinkWithV4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    NSURL *_Nullable v4DeeplinkUrl = v4UserDefaultsData.deeplinkUrl;

    if (v4DeeplinkUrl == nil) {
        [self.logger debug:@"Deeplink not found in v4 user defaults"];
        return;
    }

    ADJAdjustLaunchedDeeplink *_Nonnull adjustLaunchedDeeplink = [[ADJAdjustLaunchedDeeplink alloc] initWithUrl:v4DeeplinkUrl];

    [ADJAdjust trackLaunchedDeeplink:adjustLaunchedDeeplink];
}

- (void)migrateV4PushTokenWithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                       v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    ADJV4ActivityState *_Nullable v4ActivityState = [v4FilesData v4ActivityState];
    if (v4ActivityState != nil) {
        [self.logger debug:@"Activity state v4 file found"];

        if (v4ActivityState.deviceToken != nil) {
            [self.logger debug:@"Push token found in v4 Activity state"];
            ADJAdjustPushToken *_Nonnull adjustPushToken = [[ADJAdjustPushToken alloc] initWithStringPushToken:
                                                            v4ActivityState.deviceToken];
            [ADJAdjust trackPushToken:adjustPushToken];
            return;
        }

        [self.logger debug:@"Push token not found in v4 Activity state"];
    } else {
        [self.logger debug:@"Activity state v4 file not found"];
    }

    NSString *_Nullable pushTokenString = v4UserDefaultsData.pushTokenString;
    if (pushTokenString != nil) {
        [self.logger debug:@"Push token string found in v4 user defaults"];
        ADJAdjustPushToken *_Nonnull adjustPushToken = [[ADJAdjustPushToken alloc] initWithStringPushToken:pushTokenString];
        [ADJAdjust trackPushToken:adjustPushToken];
        return;
    }

    [self.logger debug:@"Push token string not found in v4 user defaults"];

    NSData *_Nullable pushTokenData = v4UserDefaultsData.pushTokenData;
    if (pushTokenData != nil) {
        [self.logger debug:@"Push token data found in v4 user defaults"];
        ADJAdjustPushToken *_Nonnull adjustPushToken = [[ADJAdjustPushToken alloc] initWithDataPushToken:pushTokenData];
        [ADJAdjust trackPushToken:adjustPushToken];
        return;
    }

    [self.logger debug:@"Push token data not found in v4 user defaults"];
}

@end



