//
//  ADJAdjustIdentifierSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 13.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADJAdjustIdentifierSubscriber <NSObject>

- (void)didReadWithAdjustIdentifier:(nonnull NSString *)adid;

- (void)didUpdateWithAdjustIdentifier:(nonnull NSString *)adid;

@end
