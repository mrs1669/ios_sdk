//
//  ADJSdkInitSubscriber.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"
#import "ADJClientConfigData.h"

@protocol ADJSdkInitSubscriber <NSObject>

- (void)ccOnSdkInitWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData;

@end

@interface ADJSdkInitPublisher : ADJPublisherBase<id<ADJSdkInitSubscriber>>
@end
