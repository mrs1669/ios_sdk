//
//  ADJExternalConfigData.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJExternalConfigData.h"

#pragma mark Fields
#pragma mark - Public properties
/*
 @property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *timeoutPerAttempt;
 @property (nullable, readonly, strong, nonatomic) ADJNonNegativeInt *libraryMaxReadAttempts;
 @property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *delayBetweenAttempts;
 @property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *cacheValidityPeriod;
 */

@implementation ADJExternalConfigData
#pragma mark Instantiation
- (nonnull instancetype)initWithTimeoutPerAttempt:(nullable ADJTimeLengthMilli *)timeoutPerAttempt
                           libraryMaxReadAttempts:(nullable ADJNonNegativeInt *)libraryMaxReadAttempts
                             delayBetweenAttempts:(nullable ADJTimeLengthMilli *)delayBetweenAttempts
                              cacheValidityPeriod:(nullable ADJTimeLengthMilli *)cacheValidityPeriod {
    self = [super init];
    
    _timeoutPerAttempt = timeoutPerAttempt;
    _libraryMaxReadAttempts = libraryMaxReadAttempts;
    _delayBetweenAttempts = delayBetweenAttempts;
    _cacheValidityPeriod = cacheValidityPeriod;
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
