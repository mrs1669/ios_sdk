//
//  ADJAdjustDeviceIds.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustDeviceIds.h"

@implementation ADJAdjustDeviceIds

- (nonnull instancetype)initWithAdvertisingIdentifier:(nullable NSString *)advertisingIdentifier
                                  identifierForVendor:(nullable NSString *)identifierForVendor
{
    self = [super init];

    _advertisingIdentifier = advertisingIdentifier;
    _identifierForVendor = identifierForVendor;

    return self;
}

@end
