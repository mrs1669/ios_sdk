//
//  ATAAdjustDeeplinkCallback.h
//  AdjustTestApp
//
//  Created by Aditi Agrawal on 26/04/23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJAdjustLaunchedDeeplinkCallback.h"
#import "ADJAdjustCallback.h"
#import "ATLTestLibrary.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATAAdjustDeeplinkCallback : NSObject<ADJAdjustLaunchedDeeplinkCallback, ADJAdjustCallback>

- (nonnull instancetype)initWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
                                  extraPath:(nonnull NSString *)extraPath;

@end

NS_ASSUME_NONNULL_END
