//
//  ADJSdkPackageBaseData.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkPackageData.h"
#import "ADJIoDataSerializable.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJSdkPackageDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJSdkPackageBaseData : NSObject<ADJSdkPackageData, ADJIoDataSerializable>
// instantiation
+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger;

- (nonnull instancetype)initWithPath:(nonnull NSString *)path
                           clientSdk:(nonnull NSString *)clientSdk
        isPostOrElseGetNetworkMethod:(BOOL)isPostOrElseGetNetworkMethod
                          parameters:(nonnull ADJStringMap *)parameters
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// protected abstract
- (nonnull ADJNonEmptyString *)concreteGenerateShortDescription;

@end
