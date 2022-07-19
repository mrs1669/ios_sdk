//
//  ADJV4ActivityState.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJV4ActivityState : NSObject<NSCoding>

//@property (nonatomic, assign) BOOL enabled;
@property (nullable, readonly, strong, nonatomic) NSNumber *enableNumberBool;
//@property (nonatomic, assign) BOOL isGdprForgotten;
@property (nullable, readonly, strong, nonatomic) NSNumber *isGdprForgottenNumberBool;
//@property (nonatomic, assign) BOOL askingAttribution;
@property (nullable, readonly, strong, nonatomic) NSNumber *askingAttributionNumberBool;
//@property (nonatomic, assign) BOOL isThirdPartySharingDisabled;
@property (nullable, readonly, strong, nonatomic) NSNumber *isThirdPartySharingDisabledNumberBool;
//@property (nonatomic, copy) NSString *uuid;
@property (nullable, readonly, strong, nonatomic) NSString *uuid;
//@property (nonatomic, copy) NSString *deviceToken;
@property (nullable, readonly, strong, nonatomic) NSString *deviceToken;
//@property (nonatomic, assign) BOOL updatePackages;
@property (nullable, readonly, strong, nonatomic) NSNumber *updatePackagesNumberBool;
//@property (nonatomic, copy) NSString *adid;
@property (nullable, readonly, strong, nonatomic) NSString *adid;
//@property (nonatomic, strong) NSDictionary *attributionDetails;
@property (nullable, readonly, strong, nonatomic) NSDictionary *attributionDetails;
//@property (nonatomic, assign) int eventCount;
@property (nullable, readonly, strong, nonatomic) NSNumber *eventCountNumberInt;
//@property (nonatomic, assign) int sessionCount;
@property (nullable, readonly, strong, nonatomic) NSNumber *sessionCountNumberInt;
//@property (nonatomic, assign) int subsessionCount;
@property (nullable, readonly, strong, nonatomic) NSNumber *subsessionCountNumberInt;
//@property (nonatomic, assign) double timeSpent;
@property (nullable, readonly, strong, nonatomic) NSNumber *timeSpentNumberDouble;
//@property (nonatomic, assign) double lastActivity;      // Entire time in seconds since 1970
@property (nullable, readonly, strong, nonatomic) NSNumber *lastActivityNumberDouble;
//@property (nonatomic, assign) double sessionLength;     // Entire duration in seconds
@property (nullable, readonly, strong, nonatomic) NSNumber *sessionLengthNumberDouble;
//@property (nonatomic, strong) NSMutableArray *transactionIds;
@property (nullable, readonly, strong, nonatomic) NSMutableArray *transactionIds;

@end
