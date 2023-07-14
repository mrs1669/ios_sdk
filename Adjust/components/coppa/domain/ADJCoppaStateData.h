//
//  ADJCoppaStateData.h
//  Adjust
//
//  Created by Pedro Silva on 28.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataSerializable.h"
#import "ADJIoData.h"
#import "ADJBooleanWrapper.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJCoppaStateDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJCoppaStateData : NSObject<ADJIoDataSerializable>
// public properties
@property (nonnull, readonly, strong, nonatomic) ADJBooleanWrapper *isCoppaEnabled;

// instantiation
+ (nonnull ADJResult<ADJCoppaStateData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData;

- (nonnull instancetype)initWithInitialState;

- (nonnull instancetype)initWithIsCoppaEnabled:(nonnull ADJBooleanWrapper *)isCoppaEnabled;

- (nullable instancetype)init NS_UNAVAILABLE;

@end
