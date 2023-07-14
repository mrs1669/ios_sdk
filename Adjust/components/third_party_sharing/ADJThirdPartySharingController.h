//
//  ADJThirdPartySharingController.h
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJClientActionHandler.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJMainQueueController.h"
#import "ADJClientThirdPartySharingData.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJThirdPartySharingControllerClientActionHandlerId;

NS_ASSUME_NONNULL_END

@interface ADJThirdPartySharingController : ADJCommonBase <ADJClientActionHandler>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController;

// public api
- (void)
    ccTrackThirdPartySharingWithClientData:
        (nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData
    storageAction:(nullable ADJSQLiteStorageActionBase *)storageAction;

- (void)ccDeactivateFromCoppa;

@end
