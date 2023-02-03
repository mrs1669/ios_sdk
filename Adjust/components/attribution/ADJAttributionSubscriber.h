//
//  ADJAttributionSubscriber.h
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJAttributionStateData.h"
#import "ADJPublisherBase.h"

@protocol ADJAttributionSubscriber <NSObject>

- (void)attributionWithStateData:(nonnull ADJAttributionStateData *)attributionStateData
             previousAttribution:(nullable ADJAttributionData *)previousAttribution;

@end

@interface ADJAttributionPublisher : ADJPublisherBase<id<ADJAttributionSubscriber>>
@end
