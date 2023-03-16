//
//  ADJEntryRootBag.h
//  Adjust
//
//  Created by Pedro Silva on 06.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADJEntryRootBag <NSObject>

@property (nullable, readonly, strong, nonatomic) NSString *sdkPrefix;

@end
