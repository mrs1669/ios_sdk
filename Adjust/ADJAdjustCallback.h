//
//  ADJAdjustCallback.h
//  Adjust
//
//  Created by Pedro Silva on 18.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADJAdjustCallback <NSObject>

- (void)didFailWithAdjustCallbackMessage:(nonnull NSString *)message;

@end
