//
//  ADJBooleanWrapper.h
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoValueSerializable.h"
#import "ADJPackageParamValueSerializable.h"
#import "ADJNonEmptyString.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJBooleanTrueString;
FOUNDATION_EXPORT NSString *const ADJBooleanFalseString;

NS_ASSUME_NONNULL_END

@interface ADJBooleanWrapper : NSObject<
    ADJIoValueSerializable,
    ADJPackageParamValueSerializable
>
// instantiation
+ (nonnull instancetype)instanceFromBool:(BOOL)boolValue;

+ (nullable instancetype)instanceFromNumberBoolean:(nullable NSNumber *)numberBooleanValue;

+ (nonnull ADJResultNN<ADJBooleanWrapper *> *)instanceFromIoValue:
    (nullable ADJNonEmptyString *)ioValue;
+ (nonnull ADJResultNL<ADJBooleanWrapper *> *)instanceFromOptionalIoValue:
    (nullable ADJNonEmptyString *)ioValue;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonatomic, readonly, assign) BOOL boolValue;

@end

