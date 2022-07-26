//
//  ADJSdkPackageData.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataSerializable.h"
#import "ADJNonEmptyString.h"
#import "ADJStringMap.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJSdkPackageDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@protocol ADJSdkPackageData <ADJIoDataSerializable>

// public properties
@property (nonnull, readonly, strong, nonatomic) NSString *path;
@property (nonnull, readonly, strong, nonatomic) NSString *clientSdk;
@property (readonly, assign, nonatomic) BOOL isPostOrElseGetNetworkMethod;
@property (nonnull, readonly, strong, nonatomic) ADJStringMap *parameters;

// public api
- (nonnull ADJNonEmptyString *)generateShortDescription;

- (nonnull ADJNonEmptyString *)generateExtendedDescription;

@end
