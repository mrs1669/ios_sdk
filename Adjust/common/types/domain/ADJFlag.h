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

- (nullable instancetype)init NS_UNAVAILABLE;

@end
