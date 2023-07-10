//
//  ADJFlag.h
//  Adjust
//
//  Created by Pedro Silva on 10.07.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoValueSerializable.h"
#import "ADJPackageParamValueSerializable.h"
#import "ADJBooleanWrapper.h"

@interface ADJFlag : NSObject <
    ADJIoValueSerializable,
    ADJPackageParamValueSerializable
>

+ (nullable ADJFlag *)instanceFromBool:(BOOL)boolValue;

+ (nonnull ADJResult<ADJFlag *> *)instanceFromBoolWrapper:
    (nullable ADJBooleanWrapper *)boolWrapperValue;

+ (nonnull ADJResult<ADJFlag *> *)instanceFromNumberBoolean:
    (nullable NSNumber *)numberBooleanValue;

+ (nonnull ADJResult<ADJFlag *> *)instanceFromIoValue:
    (nullable ADJNonEmptyString *)ioValue;

+ (nonnull ADJResult<ADJFlag *> *)instanceFromString:(nullable NSString *)stringValue;

+ (nonnull ADJResult<ADJFlag *> *)instanceFromObject:(nullable id)objectValue;

- (nullable instancetype)init NS_UNAVAILABLE;

@end
