//
//  ADJIoDataMapBuilderInjectable.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJStringMapBuilder.h"

@protocol ADJIoDataMapBuilderInjectable <NSObject>
/* Should also implement constructor with the reverse operation
 + (nullable instancetype)instanceFromIoDataMap:(nonnull ADJStringMap *)ioDataMap
                                         logger:(nonnull ADJLogger *)logger;
 */
- (void)injectIntoIoDataMapBuilder:(nonnull ADJStringMapBuilder *)ioDataMapBuilder;

@end
