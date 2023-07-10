//
//  ADJAdjustIdentifierCallback.h
//  Adjust
//
//  Created by Pedro Silva on 13.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADJAdjustCallback;

@protocol ADJAdjustIdentifierCallback <ADJAdjustCallback>

- (void)didReadWithAdjustIdentifier:(nonnull NSString *)adid;

@end
