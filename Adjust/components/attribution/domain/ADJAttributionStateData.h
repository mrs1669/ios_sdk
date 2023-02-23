//
//  ADJAttributionStateData.h
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataSerializable.h"
#import "ADJIoData.h"
#import "ADJLogger.h"
#import "ADJAttributionData.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJAttributionStateDataMetadataTypeValue;

typedef NSString *ADJAttributionStateStatus NS_TYPED_ENUM;
FOUNDATION_EXPORT ADJAttributionStateStatus const ADJAttributionStateStatusWaitingForInstallSessionTracking;
FOUNDATION_EXPORT ADJAttributionStateStatus const ADJAttributionStateStatusCanAsk;
FOUNDATION_EXPORT ADJAttributionStateStatus const ADJAttributionStateStatusIsAsking;
FOUNDATION_EXPORT ADJAttributionStateStatus const ADJAttributionStateStatusHasAttribution;
FOUNDATION_EXPORT ADJAttributionStateStatus const ADJAttributionStateStatusUnavailable;

NS_ASSUME_NONNULL_END

@interface ADJAttributionStateData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger;

- (nonnull instancetype)initWithIntialState;

- (nonnull instancetype)initWithAttributionData:(nullable ADJAttributionData *)attributionData
                          installSessionTracked:(BOOL)installSessionTracked
                         unavailableAttribution:(BOOL)unavailableAttribution
                                       isAsking:(BOOL)isAsking
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (readonly, assign, nonatomic) BOOL installSessionTracked;
@property (readonly, assign, nonatomic) BOOL unavailableAttribution;
@property (readonly, assign, nonatomic) BOOL isAsking;
@property (nullable, readonly, strong, nonatomic) ADJAttributionData *attributionData;

// public api
- (nonnull ADJAttributionStateStatus)attributionStateStatus;

- (BOOL)isAskingStatus;
- (BOOL)unavailableStatus;
- (BOOL)hasAttributionStatus;
- (BOOL)canAskStatus;
- (BOOL)waitingForInstallSessionTrackingStatus;

- (BOOL)hasAcceptedResponseFromBackend;

- (nonnull ADJAttributionStateData *)withNewIsAsking:(BOOL)newIsAsking;
- (nonnull ADJAttributionStateData *)withInstallSessionTracked;
- (nonnull ADJAttributionStateData *)withUnavailableAttribution;
- (nonnull ADJAttributionStateData *)withAvailableAttribution:
    (nonnull ADJAttributionData *)attributionData;

@end
