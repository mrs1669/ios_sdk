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

FOUNDATION_EXPORT NSString *const ADJAttributionStateStatusWaitingForSessionResponse;
FOUNDATION_EXPORT NSString *const ADJAttributionStateStatusReceivedSessionResponse;
FOUNDATION_EXPORT NSString *const ADJAttributionStateStatusAskingFromSdk;
FOUNDATION_EXPORT NSString *const ADJAttributionStateStatusAskingFromBackend;
FOUNDATION_EXPORT NSString *const ADJAttributionStateStatusAskingFromBackendAndSdk;
FOUNDATION_EXPORT NSString *const ADJAttributionStateStatusHasAttribution;
FOUNDATION_EXPORT NSString *const ADJAttributionStateStatusUnavailable;

NS_ASSUME_NONNULL_END

@interface ADJAttributionStateData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger;

- (nonnull instancetype)initWithIntialState;

- (nonnull instancetype)initWithAttributionData:(nullable ADJAttributionData *)attributionData
                        receivedSessionResponse:(BOOL)receivedSessionResponse
                         unavailableAttribution:(BOOL)unavailableAttribution
                                  askingFromSdk:(BOOL)askingFromSdk
                              askingFromBackend:(BOOL)askingFromBackend
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (readonly, assign, nonatomic) BOOL receivedSessionResponse;
@property (readonly, assign, nonatomic) BOOL unavailableAttribution;
@property (readonly, assign, nonatomic) BOOL askingFromSdk;
@property (readonly, assign, nonatomic) BOOL askingFromBackend;
@property (nullable, readonly, strong, nonatomic) ADJAttributionData *attributionData;

// public api
- (nonnull NSString *)attributionStateStatus;

- (BOOL)askingFromBackendAndSdkStatus;
- (BOOL)askingFromSdkStatus;
- (BOOL)askingFromBackendStatus;
- (BOOL)unavailableStatus;
- (BOOL)hasAttributionStatus;
- (BOOL)receivedSessionResponseStatus;
- (BOOL)waitingForSessionResponseStatus;

@end
