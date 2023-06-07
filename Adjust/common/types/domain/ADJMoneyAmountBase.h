//
//  ADJMoneyAmountBase.h
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPackageParamValueSerializable.h"
#import "ADJIoValueSerializable.h"
#import "ADJNonEmptyString.h"

@interface ADJMoneyAmountBase : NSObject<
    NSCopying,
    ADJPackageParamValueSerializable,
    ADJIoValueSerializable
>
// instantiation
+ (nonnull ADJResultNN<ADJMoneyAmountBase *> *)instanceFromIoValue:
    (nullable ADJNonEmptyString *)ioValue;

+ (nonnull ADJResultNL<ADJMoneyAmountBase *> *)instanceFromOptionalIoValue:
    (nullable ADJNonEmptyString *)ioValue;

- (nonnull instancetype)init;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSNumber *numberValue;
@property (readonly, assign, nonatomic) double doubleValue;

@end

