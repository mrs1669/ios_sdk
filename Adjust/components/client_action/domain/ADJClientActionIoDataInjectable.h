//
//  ADJClientActionIoDataInjectable.h
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataBuilder.h"

@protocol ADJClientActionIoDataInjectable <NSObject>

- (void)injectIntoClientActionIoDataBuilder:(nonnull ADJIoDataBuilder *)clientActionIoDataBuilder;

@end
