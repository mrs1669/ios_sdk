//
//  ADJIoDataSerializable.h
//  Adjust
//
//  Created by Aditi Agrawal on 14/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADJIoData;

@protocol ADJIoDataSerializable <NSObject>

- (nonnull ADJIoData *)toIoData;

@end

