//
//  ADJCoppaCompliantController.h
//  Adjust
//
//  Created by Pedro Silva on 28.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJThirdPartySharingController.h"
#import "ADJCoppaStateStorage.h"

@interface ADJCoppaCompliantController : ADJCommonBase<
    // subscriptions
    ADJSdkInitSubscriber
>
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    thirdPartySharingController:
        (nonnull ADJThirdPartySharingController *)thirdPartySharingController
    coppaStateStorage:(nonnull ADJCoppaStateStorage *)coppaStateStorage;


@end
