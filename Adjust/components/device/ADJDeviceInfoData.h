//
//  ADJDeviceInfoData.h
//  Adjust
//
//  Created by Pedro S. on 23.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJNonEmptyString.h"
#import "ADJLogger.h"

@interface ADJDeviceInfoData : NSObject
// instantiation
- (nonnull instancetype)initWithLogger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *fbAnonymousId;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *bundeIdentifier;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *bundleVersion;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *bundleShortVersion;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deviceType;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deviceName;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *osName;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *systemVersion;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *languageCode;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *countryCode;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *machineModel;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *cpuTypeSubtype;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *osBuild;

@end

