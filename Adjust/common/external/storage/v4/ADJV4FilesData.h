//
//  ADJV4FilesData.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJLogger.h"
#import "ADJV4ActivityState.h"
#import "ADJV4Attribution.h"
#import "ADJV4ActivityPackage.h"
#import "ADJOptionalFails.h"

@interface ADJV4FilesData : NSObject
// instantiation
+ (nonnull ADJOptionalFails<ADJV4FilesData *> *)readV4Files;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJV4ActivityState *v4ActivityState;
@property (nullable, readonly, strong, nonatomic) ADJV4Attribution *v4Attribution;
@property (nullable, readonly, strong, nonatomic)
    NSArray<ADJV4ActivityPackage *> *v4ActivityPackageArray;
@property (nullable, readonly, strong, nonatomic)
    NSDictionary<NSString *, NSString *> *v4SessionCallbackParameters;
@property (nullable, readonly, strong, nonatomic)
    NSDictionary<NSString *, NSString *> *v4SessionPartnerParameters;

@end
