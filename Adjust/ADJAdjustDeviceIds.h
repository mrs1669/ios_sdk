//
//  ADJAdjustDeviceIds.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJAdjustDeviceIds : NSObject

- (nonnull instancetype)initWithAdvertisingIdentifier:(nullable NSString *)advertisingIdentifier
                                  identifierForVendor:(nullable NSString *)identifierForVendor;

@property (nullable, readonly, strong, nonatomic) NSString *advertisingIdentifier;
@property (nullable, readonly, strong, nonatomic) NSString *identifierForVendor;

@end

