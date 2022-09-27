//
//  ADJAttributionSubscriber.h
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJAttributionData.h"
#import "ADJPublisherBase.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJAttributionStatusCreated;
FOUNDATION_EXPORT NSString *const ADJAttributionStatusUpdated;
FOUNDATION_EXPORT NSString *const ADJAttributionStatusRead;
FOUNDATION_EXPORT NSString *const ADJAttributionStatusNotAvailableFromBackend;
FOUNDATION_EXPORT NSString *const ADJAttributionStatusWaiting;

NS_ASSUME_NONNULL_END

@protocol ADJAttributionSubscriber <NSObject>

- (void)didAttributionWithData:(nullable ADJAttributionData *)attributionData
             attributionStatus:(nonnull NSString *)attributionStatus;

@end

@interface ADJAttributionPublisher : ADJPublisherBase<id<ADJAttributionSubscriber>>
@end
