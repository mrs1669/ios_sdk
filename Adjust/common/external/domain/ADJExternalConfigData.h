//
//  ADJExternalConfigData.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJTimeLengthMilli.h"

@interface ADJExternalConfigData : NSObject
// instantiation
- (nonnull instancetype)
    initWithTimeoutPerAttempt:(nullable ADJTimeLengthMilli *)timeoutPerAttempt
    libraryMaxReadAttempts:(nullable ADJNonNegativeInt *)libraryMaxReadAttempts
    delayBetweenAttempts:(nullable ADJTimeLengthMilli *)delayBetweenAttempts
    cacheValidityPeriod:(nullable ADJTimeLengthMilli *)cacheValidityPeriod;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *timeoutPerAttempt;
@property (nullable, readonly, strong, nonatomic) ADJNonNegativeInt *libraryMaxReadAttempts;
@property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *delayBetweenAttempts;
@property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *cacheValidityPeriod;

@end
