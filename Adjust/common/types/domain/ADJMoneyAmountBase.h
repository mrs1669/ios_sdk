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
    ADJPackageParamValueSerializable,
    ADJIoValueSerializable
>
// instantiation
+ (nonnull ADJResult<ADJMoneyAmountBase *> *)instanceFromIoValue:
    (nullable ADJNonEmptyString *)ioValue;

- (nonnull instancetype)init;

@end
