//
//  ADJAdjustDeeplinkCallback.h
//  Adjust
//
//  Created by Aditi Agrawal on 05/04/23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

@class ADJAdjustLaunchedDeeplink;
@protocol ADJAdjustCallback;

@protocol ADJAdjustLaunchedDeeplinkCallback <ADJAdjustCallback>

- (void)didReadWithAdjustLaunchedDeeplink:(nonnull NSString *)adjustLaunchedDeeplink;

@end

