//
//  ADJV4UserDefaultsData.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJLogger.h"

@interface ADJV4UserDefaultsData : NSObject
// instantiation
- (nonnull instancetype)initWithLogger:(nonnull ADJLogger *)logger
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

- (BOOL)isMigrationCompleted;
- (void)setMigrationCompleted;

// public properties
@property (nullable, readonly, strong, nonatomic) NSData *pushTokenData;
@property (nullable, readonly, strong, nonatomic) NSString *pushTokenString;
@property (nullable, readonly, strong, nonatomic) NSNumber *installTrackedNumberBool;
@property (nullable, readonly, strong, nonatomic) NSNumber *gdprForgetMeNumberBool;
@property (nullable, readonly, strong, nonatomic) NSURL *deeplinkUrl;
@property (nullable, readonly, strong, nonatomic) NSDate *deeplinkClickTime;
@property (nullable, readonly, strong, nonatomic) NSNumber *disableThirdPartySharingNumberBool;
@property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, NSNumber *> *iAdErrors;
@property (nullable, readonly, strong, nonatomic) NSNumber *adServicesTrackedNumberBool;
@property (nullable, readonly, strong, nonatomic) NSDate * skadRegisterCallTimestamp;
@property (nullable, readonly, strong, nonatomic) NSNumber *migrationCompletedNumberBool;

@end
