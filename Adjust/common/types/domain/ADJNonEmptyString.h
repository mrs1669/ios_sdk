//
//  ADJNonEmptyString.h
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPackageParamValueSerializable.h"
#import "ADJIoValueSerializable.h"
#import "ADJLogger.h"
#import "ADJResultNN.h"
#import "ADJResultNL.h"

@interface ADJNonEmptyString : NSObject<
    NSCopying,
    ADJPackageParamValueSerializable,
    ADJIoValueSerializable
>
// instantiation
+ (nonnull ADJResultNN<ADJNonEmptyString *> *)
    instanceFromString:(nullable NSString *)stringValue;
+ (nonnull ADJResultNN<ADJNonEmptyString *> *)
    instanceFromObject:(nullable id)objectValue;

+ (nonnull ADJResultNL<ADJNonEmptyString *> *)
    instanceFromOptionalString:(nullable NSString *)stringValue;
+ (nonnull ADJResultNL<ADJNonEmptyString *> *)
    instanceFromOptionalObject:(nullable id)objectValue;

- (nonnull instancetype)initWithConstStringValue:(nonnull NSString *)constStringValue
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSString *stringValue;

@end
