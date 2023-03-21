//
//  ADJV4ActivityState.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJV4ActivityState.h"

#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kEnabledKey = @"enabled";
static NSString *const kIsGdprForgottenKey = @"isGdprForgotten";
static NSString *const kAskingAttributionKey = @"askingAttribution";
static NSString *const kIsThirdPartySharingDisabledKey = @"isThirdPartySharingDisabled";
static NSString *const kUuidKey = @"uuid";
static NSString *const kDeviceTokenKey = @"deviceToken";
static NSString *const kPushTokenKey = @"pushToken";
static NSString *const kUpdatePackagesKey = @"updatePackages";
static NSString *const kAdidKey = @"adid";
static NSString *const kAttributionDetailsKey = @"attributionDetails";
static NSString *const kEventCountKey = @"eventCount";
static NSString *const kSessionCountKey = @"sessionCount";
static NSString *const kSubsessionCountKey = @"subsessionCount";
static NSString *const kTimeSpentKey = @"timeSpent";
static NSString *const kLastActivityKey = @"lastActivity";
static NSString *const kSessionLengthKey = @"sessionLength";
static NSString *const kTransactionIdsKey = @"transactionIds";
static NSString *const kLaunchedDeeplinkKey = @"launchedDeeplink";

#pragma mark - Public properties
/* .h
 //@property (nonatomic, assign) BOOL enabled;
 @property (nullable, readonly, strong, nonatomic) NSNumber *enableNumberBool;
 //@property (nonatomic, assign) BOOL isGdprForgotten;
 @property (nullable, readonly, strong, nonatomic) NSNumber *isGdprForgottenNumberBool;
 //@property (nonatomic, assign) BOOL askingAttribution;
 @property (nullable, readonly, strong, nonatomic) NSNumber *askingAttributionNumberBool;
 //@property (nonatomic, assign) BOOL isThirdPartySharingDisabled;
 @property (nullable, readonly, strong, nonatomic) NSNumber *isThirdPartySharingDisabledNumberBool;
 //@property (nonatomic, copy) NSString *uuid;
 @property (nullable, readonly, strong, nonatomic) NSString *uuid;
 //@property (nonatomic, copy) NSString *deviceToken;
 @property (nullable, readonly, strong, nonatomic) NSString *deviceToken;
 //@property (nonatomic, copy) NSString *pushToken;
 @property (nullable, readonly, strong, nonatomic) NSString *pushToken;
 //@property (nonatomic, assign) BOOL updatePackages;
 @property (nullable, readonly, strong, nonatomic) NSNumber *updatePackagesNumberBool;
 //@property (nonatomic, copy) NSString *adid;
 @property (nullable, readonly, strong, nonatomic) NSString *adid;
 //@property (nonatomic, strong) NSDictionary *attributionDetails;
 @property (nullable, readonly, strong, nonatomic) NSDictionary *attributionDetails;
 //@property (nonatomic, assign) int eventCount;
 @property (nullable, readonly, strong, nonatomic) NSNumber *eventCountNumberInt;
 //@property (nonatomic, assign) int sessionCount;
 @property (nullable, readonly, strong, nonatomic) NSNumber *sessionCountNumberInt;
 //@property (nonatomic, assign) int subsessionCount;
 @property (nullable, readonly, strong, nonatomic) NSNumber *subsessionCountNumberInt;
 //@property (nonatomic, assign) double timeSpent;
 @property (nullable, readonly, strong, nonatomic) NSNumber *timeSpentNumberDouble;
 //@property (nonatomic, assign) double lastActivity;      // Entire time in seconds since 1970
 @property (nullable, readonly, strong, nonatomic) NSNumber *lastActivityNumberDouble;
 //@property (nonatomic, assign) double sessionLength;     // Entire duration in seconds
 @property (nullable, readonly, strong, nonatomic) NSNumber *sessionLengthNumberDouble;
 //@property (nonatomic, strong) NSMutableArray *transactionIds;
 @property (nullable, readonly, strong, nonatomic) NSMutableArray *transactionIds;
 //@property (nonatomic, copy) NSString *launchedDeeplink;
 @property (nullable, readonly, strong, nonatomic) NSString *launchedDeeplink;
 */

@implementation ADJV4ActivityState
#pragma mark Instantiation
- (id)init {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    return self;
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    if ([decoder containsValueForKey:kEventCountKey]) {
        _eventCountNumberInt = [NSNumber numberWithInt:[decoder decodeIntForKey:kEventCountKey]];
    }
    if ([decoder containsValueForKey:kSessionCountKey]) {
        _sessionCountNumberInt =
        [NSNumber numberWithInt:[decoder decodeIntForKey:kSessionCountKey]];
    }
    if ([decoder containsValueForKey:kSubsessionCountKey]) {
        _subsessionCountNumberInt =
        [NSNumber numberWithInt:[decoder decodeIntForKey:kSubsessionCountKey]];
    }
    if ([decoder containsValueForKey:kSessionLengthKey]) {
        _sessionLengthNumberDouble =
        [NSNumber numberWithInt:[decoder decodeDoubleForKey:kSessionLengthKey]];
    }
    if ([decoder containsValueForKey:kTimeSpentKey]) {
        _timeSpentNumberDouble =
        [NSNumber numberWithInt:[decoder decodeDoubleForKey:kTimeSpentKey]];
    }
    if ([decoder containsValueForKey:kLastActivityKey]) {
        _lastActivityNumberDouble =
        [NSNumber numberWithInt:[decoder decodeDoubleForKey:kLastActivityKey]];
    }
    if ([decoder containsValueForKey:kUuidKey]) {
        _uuid = [decoder decodeObjectForKey:kUuidKey];
    }
    if ([decoder containsValueForKey:kPushTokenKey]) {
        _pushToken = [decoder decodeObjectForKey:kPushTokenKey];
    }
    if ([decoder containsValueForKey:kTransactionIdsKey]) {
        _transactionIds = [decoder decodeObjectForKey:kTransactionIdsKey];
    }
    if ([decoder containsValueForKey:kEnabledKey]) {
        _enableNumberBool = [NSNumber numberWithBool:[decoder decodeBoolForKey:kEnabledKey]];
    }
    if ([decoder containsValueForKey:kIsGdprForgottenKey]) {
        _isGdprForgottenNumberBool =
        [NSNumber numberWithBool:[decoder decodeBoolForKey:kIsGdprForgottenKey]];
    }
    if ([decoder containsValueForKey:kAskingAttributionKey]) {
        _askingAttributionNumberBool =
        [NSNumber numberWithBool:[decoder decodeBoolForKey:kAskingAttributionKey]];
    }
    if ([decoder containsValueForKey:kIsThirdPartySharingDisabledKey]) {
        _isThirdPartySharingDisabledNumberBool =
        [NSNumber numberWithBool:[decoder decodeBoolForKey:kIsThirdPartySharingDisabledKey]];
    }
    if ([decoder containsValueForKey:kDeviceTokenKey]) {
        _deviceToken = [decoder decodeObjectForKey:kDeviceTokenKey];
    }
    if ([decoder containsValueForKey:kUpdatePackagesKey]) {
        _updatePackagesNumberBool =
        [NSNumber numberWithBool:[decoder decodeBoolForKey:kUpdatePackagesKey]];
    }
    if ([decoder containsValueForKey:kAdidKey]) {
        _adid = [decoder decodeObjectForKey:kAdidKey];
    }
    if ([decoder containsValueForKey:kAttributionDetailsKey]) {
        _attributionDetails = [decoder decodeObjectForKey:kAttributionDetailsKey];
    }
    if ([decoder containsValueForKey:kLaunchedDeeplinkKey]) {
        _launchedDeeplink = [decoder decodeObjectForKey:kLaunchedDeeplinkKey];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {

}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            @"ADJV4ActivityState",
            kEnabledKey, self.enableNumberBool,
            kEnabledKey, self.enableNumberBool,
            kIsGdprForgottenKey, self.isGdprForgottenNumberBool,
            kAskingAttributionKey, self.askingAttributionNumberBool,
            kIsThirdPartySharingDisabledKey, self.isThirdPartySharingDisabledNumberBool,
            kUuidKey, self.uuid,
            kDeviceTokenKey, self.deviceToken,
            kPushTokenKey, self.pushToken,
            kUpdatePackagesKey, self.updatePackagesNumberBool,
            kAdidKey, self.adid,
            kAttributionDetailsKey, self.attributionDetails,
            kEventCountKey, self.eventCountNumberInt,
            kSessionCountKey, self.sessionCountNumberInt,
            kSubsessionCountKey, self.subsessionCountNumberInt,
            kTimeSpentKey, self.timeSpentNumberDouble,
            kLastActivityKey, self.lastActivityNumberDouble,
            kSessionLengthKey, self.sessionLengthNumberDouble,
            kTransactionIdsKey, self.transactionIds,
            kLaunchedDeeplinkKey, self.launchedDeeplink,
            nil];
}

@end

