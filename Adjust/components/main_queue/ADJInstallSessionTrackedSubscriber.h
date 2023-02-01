//
//  ADJInstallSessionTrackedSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 31.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSessionResponseData.h"

@protocol ADJInstallSessionTrackedSubscriber <NSObject>
- (void)ccInstallSessionTrackedWithSessionResponse:
    (nullable ADJSessionResponseData *)sessionResponse;

@end

@interface ADJInstallSessionTrackedPublisher :
    ADJPublisherBase<id<ADJInstallSessionTrackedSubscriber>>
@end
