//
//  ADJGdprForgetPublisher.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

@protocol ADJGdprForgetSubscriber <NSObject>

- (void)didGdprForget;

@end

@interface ADJGdprForgetPublisher : ADJPublisherBase<id<ADJGdprForgetSubscriber>>
@end
