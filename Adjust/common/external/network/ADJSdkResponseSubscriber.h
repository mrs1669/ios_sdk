//
//  ADJSdkResponseSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseData.h"
#import "ADJPublisherBase.h"

@protocol ADJSdkResponseSubscriber <NSObject>

- (void)didReceiveSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData;

@end

@interface ADJSdkResponsePublisher : ADJPublisherBase<id<ADJSdkResponseSubscriber>>
@end
