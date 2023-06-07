//
//  ADJV4ActivityPackage.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJV4SessionPath;
FOUNDATION_EXPORT NSString *const ADJV4EventPath;
FOUNDATION_EXPORT NSString *const ADJV4InfoPath;
FOUNDATION_EXPORT NSString *const ADJV4AdRevenuePath;
FOUNDATION_EXPORT NSString *const ADJV4ClickPath;
FOUNDATION_EXPORT NSString *const ADJV4AttributionPath;
FOUNDATION_EXPORT NSString *const ADJV4GdprForgetDevicePath;
FOUNDATION_EXPORT NSString *const ADJV4DisableThirdPartySharingPath;
FOUNDATION_EXPORT NSString *const ADJV4ThirdPartySharingPath;
FOUNDATION_EXPORT NSString *const ADJV4MeasuringConsentPath;
FOUNDATION_EXPORT NSString *const ADJV4PurchasePath;

NS_ASSUME_NONNULL_END

@interface ADJV4ActivityPackage : NSObject<NSCoding>

@property (nullable, readonly, strong, nonatomic) NSString *path;
@property (nullable, readonly, strong, nonatomic) NSString *clientSdk;
@property (nullable, readonly, strong, nonatomic) NSNumber *retriesNumberInt;
@property (nullable, readonly, strong, nonatomic) NSMutableDictionary *parameters;
@property (nullable, readonly, strong, nonatomic) NSDictionary *partnerParameters;
@property (nullable, readonly, strong, nonatomic) NSDictionary *callbackParameters;
@property (nullable, readonly, strong, nonatomic) NSString *suffix;
@property (nullable, readonly, strong, nonatomic) NSString *kind;

@end

