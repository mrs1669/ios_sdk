//
//  ADJSdkActiveState.h
//  AdjustV5
//
//  Created by Pedro S. on 28.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSdkActiveStateData.h"
#import "ADJLogger.h"
#import "ADJValueWO.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *ADJSdkActiveStatus NS_TYPED_ENUM;
FOUNDATION_EXPORT NSString *const ADJSdkActiveStatusActive;
FOUNDATION_EXPORT NSString *const ADJSdkActiveStatusInactive;
FOUNDATION_EXPORT NSString *const ADJSdkActiveStatusForgotten;

NS_ASSUME_NONNULL_END

@interface ADJActivityStateOutputData : NSObject
- (nonnull instancetype)initWithStateData:(nonnull ADJSdkActiveStateData *)stateData
                          sdkActiveStatus:(nonnull ADJSdkActiveStatus)sdkActiveStatus;
- (nonnull instancetype)initWithSdkActiveStatus:(nonnull ADJSdkActiveStatus)sdkActiveStatus;

@property (nullable, readonly, strong, nonatomic) ADJSdkActiveStateData * changedStateData;
@property (nullable, readonly, strong, nonatomic) ADJSdkActiveStatus sdkActiveStatus;
@end

@interface ADJSdkActiveState : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                           sdkActiveStateData:(nonnull ADJSdkActiveStateData *)sdkActiveStateData
                              isGdprForgotten:(BOOL)isGdprForgotten;
- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (BOOL)trySdkInit;

- (nullable NSString *)canPerformActionOrElseMessageWithClientSource:
    (nonnull NSString *)clientSource;

- (nullable ADJActivityStateOutputData *)inactivateSdk;
- (nullable ADJActivityStateOutputData *)reactivateSdk;

- (nullable ADJActivityStateOutputData *)forgottenFromClient;
- (nullable ADJActivityStateOutputData *)forgottenFromEvent;

- (nonnull ADJSdkActiveStatus)sdkActiveStatus;

@end
