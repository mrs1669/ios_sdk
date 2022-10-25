//
//  ADJAdjustAttributionCallback.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

@class ADJAdjustAttribution;

@protocol ADJAdjustAttributionCallback <NSObject>

- (void)didReadWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution;

- (void)unableToReadAdjustAttributionWithMessage:(nonnull NSString *)message;

@end
