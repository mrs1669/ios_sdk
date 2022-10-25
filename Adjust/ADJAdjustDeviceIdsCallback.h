//
//  ADJAdjustDeviceIdsCallback.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

@class ADJAdjustDeviceIds;

@protocol ADJAdjustDeviceIdsCallback <NSObject>

- (void)didReadWithAdjustDeviceIds:(nonnull ADJAdjustDeviceIds *)adjustDeviceIds;

- (void)unableToReadAdjustDeviceIdsWithMessage:(nonnull NSString *)message;

@end
