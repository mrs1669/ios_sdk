//
//  ADJAdjustPublishers.h
//  Adjust
//
//  Created by Pedro S. on 15.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADJAdjustPackageSendingPublisher;
@protocol ADJAdjustForegroundPublisher;

@interface ADJAdjustPublishers : NSObject
// instantiation
- (nonnull instancetype)initWithPackageSendingPublisher:(nonnull id<ADJAdjustPackageSendingPublisher>)packageSendingPublisher
                                    foregroundPublisher:(nonnull id<ADJAdjustForegroundPublisher>)foregroundPublisher;

// publishers
@property (nonnull, readonly, strong, nonatomic) id<ADJAdjustPackageSendingPublisher> packageSendingPublisher;
@property (nonnull, readonly, strong, nonatomic) id<ADJAdjustForegroundPublisher> foregroundPublisher;

@end

