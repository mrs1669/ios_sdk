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

FOUNDATION_EXPORT NSString *const ADJBooleanTrueJsonString;
FOUNDATION_EXPORT NSString *const ADJBooleanFalseJsonString;

NS_ASSUME_NONNULL_END

@interface ADJBooleanWrapper : NSObject<
    ADJIoValueSerializable,
    ADJPackageParamValueSerializable
>
// instantiation
+ (nonnull instancetype)instanceFromBool:(BOOL)boolValue;

+ (nonnull ADJResult<ADJBooleanWrapper *> *)instanceFromNumberBoolean:
    (nullable NSNumber *)numberBooleanValue;

+ (nonnull ADJResult<ADJBooleanWrapper *> *)instanceFromIoValue:
    (nullable ADJNonEmptyString *)ioValue;

+ (nonnull ADJResult<ADJBooleanWrapper *> *)instanceFromString:(nullable NSString *)stringValue;

+ (nonnull ADJResult<ADJBooleanWrapper *> *)instanceFromObject:(nullable id)objectValue;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (readonly, assign, nonatomic) BOOL boolValue;
@property (nonnull, readonly, strong, nonatomic) NSNumber *numberBoolValue;
@property (nonnull, readonly, strong, nonatomic) NSString *jsonString;

@end
