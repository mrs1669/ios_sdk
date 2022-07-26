//
//  ADJOfflineSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

@protocol ADJOfflineSubscriber <NSObject>

- (void)didSdkBecomeOnline;
- (void)didSdkBecomeOffline;

@end

@interface ADJOfflinePublisher : ADJPublisherBase<id<ADJOfflineSubscriber>>
@end
