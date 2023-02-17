//
//  ADJAdjustDeviceIdsCallback.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//


@class ADJAdjustDeviceIds;
@protocol ADJAdjustCallback;

@protocol ADJAdjustDeviceIdsCallback <ADJAdjustCallback>

- (void)didReadWithAdjustDeviceIds:(nonnull ADJAdjustDeviceIds *)adjustDeviceIds;

@end
