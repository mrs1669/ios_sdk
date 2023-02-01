//
//  ADJMainQueueTrackedPackagesProvider.h
//  Adjust
//
//  Created by Pedro Silva on 31.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJNonNegativeInt.h"
#import "ADJInstallSessionTrackedSubscriber.h"
#import "ADJAsaClickTrackedSubscriber.h"

@protocol ADJMainQueueTrackedPackagesProvider <NSObject>

// public API
- (nullable ADJNonNegativeInt *)firstSessionCount;
- (nullable ADJNonNegativeInt *)asaClickCount;

/*
// publishers
@property (nonnull, readonly, strong, nonatomic)
    ADJInstallSessionTrackedPublisher *installSessionTrackedPublisher;
@property (nonnull, readonly, strong, nonatomic)
    ADJAsaClickTrackedPublisher *asaClickTrackedPublisher;
*/
@end
