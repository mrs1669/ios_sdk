//
//  ADJAdjustPublishers.m
//  Adjust
//
//  Created by Pedro S. on 15.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJAdjustPublishers.h"

#pragma mark Fields
/* .h
 @property (nonnull, readonly, strong, nonatomic) id<ADJAdjustPackageSendingPublisher> packageSendingPublisher;
 @property (nonnull, readonly, strong, nonatomic) id<ADJAdjustForegroundPublisher> foregroundPublisher;
 */

@implementation ADJAdjustPublishers
#pragma mark Instantiation
- (nonnull instancetype)initWithPackageSendingPublisher:(nonnull id<ADJAdjustPackageSendingPublisher>)packageSendingPublisher
                                    foregroundPublisher:(nonnull id<ADJAdjustForegroundPublisher>)foregroundPublisher
{
    self = [super init];

    _packageSendingPublisher = packageSendingPublisher;
    _foregroundPublisher = foregroundPublisher;

    return self;
}

@end
