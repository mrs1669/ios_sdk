//
//  ADJUtilR.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJUtilR.h"

@implementation ADJUtilR

+ (nullable id)createDefaultInstanceWithClassName:(nonnull NSString *)className {
    Class _Nullable classFromName = [self classWithName:className];

    if (classFromName == nil) {
        return nil;
    }

    return [[classFromName alloc] init];
}

+ (Class _Nullable)classWithName:(nonnull NSString *)className {
    return NSClassFromString(className);
}

@end
