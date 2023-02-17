//
//  ADJAdjustAttributionCallback.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

@class ADJAdjustAttribution;
@protocol ADJAdjustCallback;

@protocol ADJAdjustAttributionCallback <ADJAdjustCallback>

- (void)didReadWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution;

@end
