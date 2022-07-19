//
//  ADJIoDataSerializable.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADJNonEmptyString;

@protocol ADJIoValueSerializable <NSObject>

- (nonnull ADJNonEmptyString *)toIoValue;

@end
