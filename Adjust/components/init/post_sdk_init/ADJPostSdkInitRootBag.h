//
//  ADJPostSdkInitRootBag.h
//  Adjust
//
//  Created by Genady Buchatsky on 24.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJSdkPackageBuilder.h"
#import "ADJSdkPackageSenderController.h"
#import "ADJMainQueueController.h"

@protocol ADJPostSdkInitRootBag <NSObject>
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilder;
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageSenderController *sdkPackageSenderController;
@property (nonnull, readonly, strong, nonatomic) ADJMainQueueController *mainQueueController;
@end
