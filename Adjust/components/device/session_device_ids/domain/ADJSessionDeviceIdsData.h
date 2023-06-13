//
//  ADJSessionDeviceIdsData.h
//  Adjust
//
//  Created by Pedro S. on 26.07.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJAdjustDeviceIds.h"
#import "ADJNonEmptyString.h"
#import "ADJOptionalFails.h"

@interface ADJSessionDeviceIdsData : NSObject
// instantiation
- (nonnull instancetype)
    initWithAdvertisingIdentifier:(nullable ADJNonEmptyString *)advertisingIdentifier
    identifierForVendor:(nullable ADJNonEmptyString *)identifierForVendor;

//- (nonnull instancetype)initWithFailMessage:(nullable NSString *)failMessage;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
//@property (nullable, readonly, strong, nonatomic) NSString *failMessage;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *advertisingIdentifier;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *identifierForVendor;

// public API
- (nonnull ADJAdjustDeviceIds *)toAdjustDeviceIds;

- (nonnull ADJOptionalFails<NSDictionary<NSString *, id> *> *)
    buildInternalCallbackDataWithMethodName:(nonnull NSString *)methodName;

@end
